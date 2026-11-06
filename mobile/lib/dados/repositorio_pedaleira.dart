// Porta única do app para a pedaleira. Converte exceções do protocolo em
// [Resultado] e registra a causa real no log.
import '../nucleo/modelo/documento_preset.dart';
import '../nucleo/modelo/slot_preset.dart';
import '../nucleo/protocolo/api_anagram.dart';
import '../nucleo/protocolo/cliente_anagram.dart';
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/registro.dart';
import '../nucleo/resultado.dart';

class RepositorioPedaleira {
  RepositorioPedaleira(this._api);

  final ApiAnagram _api;

  Stream<MedicaoChamada> get medicoes => _api.cliente.medicoes;

  Future<Resultado<String>> firmware({Duration? prazo}) =>
      _proteger('firmware', () => _api.firmware(prazo: prazo));

  Future<Resultado<List<ResumoSlot>>> listarSlots() => _proteger('listar', _api.listarSlots);

  Future<Resultado<DocumentoPreset?>> lerPreset(SlotPreset slot) =>
      _proteger('ler ${slot.rotulo}', () => _api.lerPreset(slot));

  Future<Resultado<void>> tocarAoVivo(DocumentoPreset preset) =>
      _proteger('tocar ao vivo', () => _api.tocarAoVivo(preset));

  Future<Resultado<void>> salvar(SlotPreset slot, DocumentoPreset preset) =>
      _proteger('salvar ${slot.rotulo}', () => _api.salvar(slot, preset));

  Future<Resultado<T>> _proteger<T>(String operacao, Future<T> Function() acao) async {
    try {
      return Sucesso(await acao());
    } on ErroAnagram catch (erro) {
      registro.e('pedaleira: $operacao falhou', error: erro);
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
