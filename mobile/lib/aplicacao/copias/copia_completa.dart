// Backup completo, pedido nas Configurações (DECISOES BK4): lê todas as áreas
// e todos os slots ocupados, um pedido por vez (a pedaleira atende uma
// conversa por vez), e grava cada preset numa pasta datada. Dá para cancelar
// entre um preset e outro; o que já foi gravado fica.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/copia_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/registro.dart';
import '../../nucleo/resultado.dart';
import '../../plataforma/copias_de_seguranca.dart';
import '../casos_de_uso/transferir_preset.dart';
import '../estado/controlador_conexao.dart';
import 'copia_automatica.dart';

/// Quantos presets já foram guardados de quantos ocupados; `total` nulo =
/// ainda listando as áreas.
class ProgressoCopiaCompleta {
  const ProgressoCopiaCompleta({this.feitos = 0, this.total});

  final int feitos;
  final int? total;
}

sealed class ResultadoCopiaCompleta {
  const ResultadoCopiaCompleta(this.pasta, this.feitos);

  /// A pasta do lote (vazia se nem chegou a ser criada).
  final String pasta;
  final int feitos;
}

final class CopiaCompletaConcluida extends ResultadoCopiaCompleta {
  const CopiaCompletaConcluida(super.pasta, super.feitos);
}

final class CopiaCompletaCancelada extends ResultadoCopiaCompleta {
  const CopiaCompletaCancelada(super.pasta, super.feitos, this.total);

  final int total;
}

final class CopiaCompletaFalhou extends ResultadoCopiaCompleta {
  const CopiaCompletaFalhou(super.pasta, super.feitos, this.erro);

  final ErroAnagram erro;
}

/// Nulo = parado; com valor = em curso.
final copiaCompletaProvider =
    NotifierProvider<ControladorCopiaCompleta, ProgressoCopiaCompleta?>(ControladorCopiaCompleta.new);

class ControladorCopiaCompleta extends Notifier<ProgressoCopiaCompleta?> {
  bool _cancelado = false;

  @override
  ProgressoCopiaCompleta? build() => null;

  /// Vale entre um preset e outro: o pedido em curso termina antes.
  void cancelar() => _cancelado = true;

  Future<ResultadoCopiaCompleta> executar() async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    final pasta = ref.read(pastaDeCopiasProvider);
    if (state != null) return const CopiaCompletaFalhou('', 0, ErroOperacaoEmCurso('O backup completo já está em curso.'));
    if (repositorio == null || pasta == null) {
      return const CopiaCompletaFalhou('', 0, ErroDesconectado('Conecte a pedaleira para fazer o backup.'));
    }
    _cancelado = false;
    state = const ProgressoCopiaCompleta();
    try {
      return await _executar(repositorio, pasta);
    } finally {
      if (ref.mounted) state = null;
    }
  }

  Future<ResultadoCopiaCompleta> _executar(RepositorioPedaleira repositorio, PastaDeCopias pasta) async {
    final List<(String?, SlotPreset)> lista;
    switch (await _ocupados(repositorio)) {
      case Falha(:final erro):
        return CopiaCompletaFalhou('', 0, erro);
      case Sucesso(:final valor):
        lista = valor;
    }
    final LoteDeCopias lote;
    try {
      lote = await pasta.novoLote();
    } on Object catch (erro) {
      registro.e('backup completo: a pasta não foi criada em ${pasta.caminho}', error: erro);
      return CopiaCompletaFalhou('', 0, ErroCopiaDeSeguranca('$erro', pasta: pasta.caminho));
    }
    registro.i('backup completo: ${lista.length} preset(s) para ${lote.caminho}');
    return _guardarTodos(repositorio, lote, lista);
  }

  Future<ResultadoCopiaCompleta> _guardarTodos(
      RepositorioPedaleira repositorio, LoteDeCopias lote, List<(String?, SlotPreset)> lista) async {
    var feitos = 0;
    for (final (area, slot) in lista) {
      if (_cancelado || !ref.mounted) {
        registro.i('backup completo: cancelado com $feitos de ${lista.length} em ${lote.caminho}');
        return CopiaCompletaCancelada(lote.caminho, feitos, lista.length);
      }
      if (await _guardarUm(repositorio, lote, area, slot) case final erro?) {
        return CopiaCompletaFalhou(lote.caminho, feitos, erro);
      }
      state = ProgressoCopiaCompleta(feitos: ++feitos, total: lista.length);
    }
    registro.i('backup completo: $feitos preset(s) em ${lote.caminho}');
    return CopiaCompletaConcluida(lote.caminho, feitos);
  }

  Future<ErroAnagram?> _guardarUm(RepositorioPedaleira repositorio, LoteDeCopias lote, String? area, SlotPreset slot) async {
    final DocumentoPreset documento;
    switch (await repositorio.lerPreset(slot, area: area)) {
      case Falha(:final erro):
        return erro;
      case Sucesso(valor: final DocumentoPreset lido):
        documento = lido;
      case Sucesso():
        // a lista disse ocupado, mas o slot veio vazio: alguém limpou no meio
        return null;
    }
    try {
      await lote.guardar(OrigemDaCopia(slot: slot, area: area, nome: documento.nome), TransferirPreset.textoDoPreset(documento));
      return null;
    } on Object catch (erro) {
      registro.e('backup completo: ${slot.rotulo} não foi gravado em ${lote.caminho}', error: erro);
      return ErroCopiaDeSeguranca('$erro', pasta: lote.caminho);
    }
  }

  /// Todos os (área, slot) ocupados, área por área; firmware sem áreas = uma só.
  Future<Resultado<List<(String?, SlotPreset)>>> _ocupados(RepositorioPedaleira repositorio) async {
    final AreasDaPedaleira daPedaleira;
    switch (await repositorio.lerAreas()) {
      case Falha(:final erro):
        return Falha(erro);
      case Sucesso(:final valor):
        daPedaleira = valor;
    }
    final ids = daPedaleira.temAreas ? [for (final a in daPedaleira.areas) a.id] : <String?>[null];
    final ocupados = <(String?, SlotPreset)>[];
    for (final id in ids) {
      if (_cancelado) break;
      switch (await repositorio.listarSlots(area: id)) {
        case Falha(:final erro):
          return Falha(erro);
        case Sucesso(:final valor):
          ocupados.addAll([for (final resumo in valor) (id, resumo.slot)]);
      }
    }
    return Sucesso(ocupados);
  }
}
