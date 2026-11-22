// Porta única do app para a pedaleira. Converte exceções do protocolo em
// [Resultado] e registra a causa real no log. Ler, gravar e listar recebem a
// área (firmware 1.18+) de quem chama, a cada pedido: uma área guardada aqui
// mudaria por baixo de um preset aberto (reconexão, troca de área) e o
// "Salvar" gravaria o slot da área errada.
import 'package:logger/logger.dart';

import '../nucleo/ajustes/ajustes_pedaleira.dart';
import '../nucleo/ajustes/modo_footswitches.dart';
import '../nucleo/modelo/areas_presets.dart';
import '../nucleo/modelo/conferencia_gravacao.dart';
import '../nucleo/modelo/documento_preset.dart';
import '../nucleo/modelo/slot_preset.dart';
import '../nucleo/protocolo/api_anagram.dart';
import '../nucleo/protocolo/api_tone3000.dart';
import '../nucleo/protocolo/cliente_anagram.dart';
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/registro.dart';
import '../nucleo/resultado.dart';
import '../nucleo/tone3000/tons_da_pedaleira.dart';

class RepositorioPedaleira {
  RepositorioPedaleira(this._api);

  final ApiAnagram _api;

  Stream<MedicaoChamada> get medicoes => _api.cliente.medicoes;

  /// [falhaEsperada]: a procura ao abrir o app (DECISOES CA2), em que não
  /// achar a pedaleira é informação no registro, não erro.
  Future<Resultado<String>> firmware({Duration? prazo, bool falhaEsperada = false}) => _proteger(
      'firmware', () => _api.firmware(prazo: prazo), nivelDaFalha: falhaEsperada ? Level.info : Level.error);

  Future<Resultado<AreasDaPedaleira>> lerAreas() => _proteger('ler áreas', _api.lerAreas);

  Future<Resultado<void>> tornarAreaAtiva(String area) =>
      _proteger('tornar $area ativa', () => _api.tornarAreaAtiva(area));

  Future<Resultado<AjustesPedaleira>> lerAjustesGlobais() =>
      _proteger('ler ajustes globais', _api.lerAjustesGlobais);

  /// Mixer, Global EQ e entrada não têm gravação: a pedaleira os aceita, mas
  /// não muda o som (DECISOES AJ1). Do `edit_settings` saem só o modo e a área.
  Future<Resultado<void>> gravarModoFootswitches(ModoFootswitches modo) => _proteger(
      'gravar $chaveModoFootswitches=${modo.valor}',
      () => _api.gravarAjustesGlobais({chaveModoFootswitches: modo.valor}));

  /// [area]: id da área ("user", "user-2"…); nulo = firmware sem áreas.
  Future<Resultado<List<ResumoSlot>>> listarSlots({String? area}) =>
      _proteger('listar', () => _api.listarSlots(area: area));

  Future<Resultado<DocumentoPreset?>> lerPreset(SlotPreset slot, {String? area}) =>
      _proteger('ler ${slot.rotulo}', () => _api.lerPreset(slot, area: area));

  Future<Resultado<void>> tocarAoVivo(DocumentoPreset preset) =>
      _proteger('tocar ao vivo', () => _api.tocarAoVivo(preset));

  Future<Resultado<void>> salvar(SlotPreset slot, DocumentoPreset preset, {String? area}) =>
      _proteger('salvar ${slot.rotulo}', () => _salvarConferindo(slot, preset, area));

  /// A Anagram grava o preset mas pode não confirmar em 30 s (provado em
  /// 2026-11-21 na v1.19.2.24, com 2 a 5 blocos pesados): sem confirmação,
  /// relê o slot e só acusa a falha se o que está lá não for o que se mandou
  /// (nome, cadeia e valores, ver [gravacaoConfere]).
  Future<void> _salvarConferindo(SlotPreset slot, DocumentoPreset preset, String? area) async {
    try {
      await _api.salvar(slot, preset, area: area);
    } on ErroSemResposta {
      final gravado = await _api.lerPreset(slot, area: area);
      if (gravado == null || !gravacaoConfere(gravado, preset)) rethrow;
      registro.w('pedaleira: salvar ${slot.rotulo} sem confirmação; a releitura mostrou o preset gravado');
    }
  }

  /// Apaga o preset do slot (o slot fica vazio na pedaleira).
  Future<Resultado<void>> excluir(SlotPreset slot, {String? area}) =>
      _proteger('limpar ${slot.rotulo}', () => _api.excluir(slot, area: area));

  Future<Resultado<void>> trocarPresets(SlotPreset de, SlotPreset para, {String? area}) =>
      _proteger('trocar ${de.rotulo} e ${para.rotulo}', () => _api.trocarPresets(de, para, area: area));

  Future<Resultado<void>> trocarBancos(int de, int para, {String? area}) =>
      _proteger('trocar os bancos $de e $para', () => _api.trocarBancos(de, para, area: area));

  /// Os tons do TONE3000 que estão na pedaleira (só leitura).
  Future<Resultado<TonsDaPedaleira>> lerTonsDaPedaleira() =>
      _proteger('ler os tons do TONE3000', _api.lerTonsDaPedaleira);

  Future<Resultado<T>> _proteger<T>(String operacao, Future<T> Function() acao,
      {Level nivelDaFalha = Level.error}) async {
    try {
      return Sucesso(await acao());
    } on ErroAnagram catch (erro) {
      registro.log(nivelDaFalha, 'pedaleira: $operacao falhou', error: erro);
      return Falha(erro);
    } on FormatException catch (erro) {
      registro.e('pedaleira: $operacao devolveu preset inválido', error: erro);
      return Falha(ErroRespostaInvalida('Preset inválido: ${erro.message}'));
    } on TypeError catch (erro, pilha) {
      // a resposta é entrada externa: um campo com tipo que o código não
      // previu não pode escapar como exceção e deixar a tela carregando
      registro.e('pedaleira: $operacao devolveu resposta fora do formato', error: erro, stackTrace: pilha);
      return Falha(ErroRespostaInvalida('Resposta fora do formato esperado em "$operacao".'));
    }
  }
}
