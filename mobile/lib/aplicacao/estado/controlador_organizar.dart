// Organizar os presets na pedaleira a partir da lista: mover um preset para
// outro slot, clonar ou trocar bancos inteiros. A pessoa escolhe a operação no
// menu do preset e depois toca no slot de destino na própria lista (como no
// "Salvar como"). Tudo vale para a área que está na tela.
//
// Mover e trocar usam o `swap_anagram_presets` da pedaleira (o mesmo do
// Darkglass Suite): com o destino vazio é mover; ocupado, os dois trocam de
// lugar, só depois de a pessoa confirmar. Clonar lê a origem e grava uma
// cópia com uuid novo pelo mesmo caminho do "Salvar como".
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/resultado.dart';
import '../casos_de_uso/salvar_no_slot.dart';
import 'controlador_biblioteca.dart';
import 'controlador_conexao.dart';
import 'controlador_editor.dart';

enum OperacaoPreset { mover, clonar, trocarBanco }

/// A operação escolhida no menu, esperando o slot de destino.
class OperacaoPendente {
  const OperacaoPendente(this.operacao, this.origem);

  final OperacaoPreset operacao;
  final SlotPreset origem;
}

sealed class ResultadoOrganizar {
  const ResultadoOrganizar();
}

final class Organizado extends ResultadoOrganizar {
  const Organizado(this.operacao, this.origem, this.destino);

  final OperacaoPreset operacao;
  final SlotPreset origem;
  final SlotPreset destino;
}

/// O destino tem preset (ou, ao trocar bancos, é sempre uma troca): a
/// operação só segue com `confirmado`.
final class DestinoOcupado extends ResultadoOrganizar {
  const DestinoOcupado(this.destino, this.nomeAtual);

  final SlotPreset destino;
  final String nomeAtual;
}

final class FalhaAoOrganizar extends ResultadoOrganizar {
  const FalhaAoOrganizar(this.erro);

  final ErroAnagram erro;
}

final organizarProvider = NotifierProvider<ControladorOrganizar, OperacaoPendente?>(ControladorOrganizar.new);

class ControladorOrganizar extends Notifier<OperacaoPendente?> {
  @override
  OperacaoPendente? build() => null;

  void iniciar(OperacaoPreset operacao, SlotPreset origem) => state = OperacaoPendente(operacao, origem);

  void cancelar() => state = null;

  /// Faz a operação pendente com [destino]. Destino ocupado volta
  /// [DestinoOcupado] e não manda nada até vir `confirmado`.
  Future<ResultadoOrganizar> concluir(SlotPreset destino, {bool confirmado = false}) async {
    final pendente = state;
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (pendente == null || repositorio == null) {
      return const FalhaAoOrganizar(ErroDesconectado('Conecte a pedaleira para organizar os presets.'));
    }
    final area = ref.read(bibliotecaProvider).areaSelecionada;
    // o próprio lugar (ou o próprio banco): não há o que trocar
    if (_mesmoLugar(pendente, destino)) {
      state = null;
      return Organizado(pendente.operacao, pendente.origem, destino);
    }
    if (!confirmado) {
      final pergunta = await _precisaConfirmar(repositorio, pendente, destino, area);
      if (pergunta != null) return pergunta;
    }
    final resultado = await _executar(repositorio, pendente, destino, area);
    if (resultado is Organizado) await _depoisDe(pendente, destino, area);
    if (resultado is! DestinoOcupado) state = null;
    return resultado;
  }

  /// A pergunta a fazer antes de seguir, ou nulo. O destino é conferido na
  /// própria pedaleira, não na lista da tela, que pode estar desatualizada.
  /// Clonar confere sozinho (SalvarNoSlot); trocar bancos sempre pergunta.
  Future<ResultadoOrganizar?> _precisaConfirmar(
      RepositorioPedaleira repositorio, OperacaoPendente pendente, SlotPreset destino, String? area) async {
    if (pendente.operacao == OperacaoPreset.clonar) return null;
    if (pendente.operacao == OperacaoPreset.trocarBanco) return DestinoOcupado(destino, '');
    return switch (await repositorio.lerPreset(destino, area: area)) {
      Sucesso(valor: final DocumentoPreset ocupante) => DestinoOcupado(destino, ocupante.nome),
      Sucesso() => null,
      Falha(:final erro) => FalhaAoOrganizar(erro),
    };
  }

  static bool _mesmoLugar(OperacaoPendente pendente, SlotPreset destino) => switch (pendente.operacao) {
        OperacaoPreset.trocarBanco => destino.banco == pendente.origem.banco,
        _ => destino == pendente.origem,
      };

  Future<ResultadoOrganizar> _executar(
      RepositorioPedaleira repositorio, OperacaoPendente pendente, SlotPreset destino, String? area) async {
    final origem = pendente.origem;
    if (pendente.operacao == OperacaoPreset.clonar) return _clonar(repositorio, origem, destino, area);
    final feito = pendente.operacao == OperacaoPreset.mover
        ? await repositorio.trocarPresets(origem, destino, area: area)
        : await repositorio.trocarBancos(origem.banco, destino.banco, area: area);
    return switch (feito) {
      Sucesso() => Organizado(pendente.operacao, origem, destino),
      Falha(:final erro) => FalhaAoOrganizar(erro),
    };
  }

  Future<ResultadoOrganizar> _clonar(
      RepositorioPedaleira repositorio, SlotPreset origem, SlotPreset destino, String? area) async {
    final leitura = await repositorio.lerPreset(origem, area: area);
    final DocumentoPreset original;
    switch (leitura) {
      case Sucesso(valor: final DocumentoPreset lido):
        original = lido;
      case Sucesso():
        return FalhaAoOrganizar(ErroRespostaInvalida('${origem.rotulo} está vazio.'));
      case Falha(:final erro):
        return FalhaAoOrganizar(erro);
    }
    // dois presets com o mesmo uuid confundiriam a pedaleira e a lista
    final copia = original.comUuid(novoUuidPreset());
    final gravacao = await SalvarNoSlot(repositorio).executar(destino, copia, area: area);
    return switch (gravacao) {
      PresetSalvo() => Organizado(OperacaoPreset.clonar, origem, destino),
      SlotOcupado(:final nomeAtual) => DestinoOcupado(destino, nomeAtual),
      FalhaAoSalvar(:final erro) => FalhaAoOrganizar(erro),
    };
  }

  /// A lista é relida da pedaleira, e o preset aberto acompanha a troca.
  Future<void> _depoisDe(OperacaoPendente pendente, SlotPreset destino, String? area) async {
    final novoLugar = switch (pendente.operacao) {
      OperacaoPreset.mover => {pendente.origem: destino, destino: pendente.origem},
      OperacaoPreset.trocarBanco => _bancosTrocados(pendente.origem.banco, destino.banco),
      OperacaoPreset.clonar => const <SlotPreset, SlotPreset>{},
    };
    ref.read(editorProvider.notifier).acompanharTroca(novoLugar, area: area);
    await ref.read(bibliotecaProvider.notifier).recarregar();
  }

  static Map<SlotPreset, SlotPreset> _bancosTrocados(int a, int b) {
    final mapa = <SlotPreset, SlotPreset>{};
    for (var letra = 1; letra <= SlotPreset.porBanco; letra++) {
      final slotA = SlotPreset((a - 1) * SlotPreset.porBanco + letra);
      final slotB = SlotPreset((b - 1) * SlotPreset.porBanco + letra);
      mapa[slotA] = slotB;
      mapa[slotB] = slotA;
    }
    return mapa;
  }
}
