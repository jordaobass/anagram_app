// O modo dos footswitches (PRESET / STOMP / SCENE): um ajuste global de texto,
// por isso fora do [ControladorAjustes], que cuida dos números com pausa de
// arraste. A leitura é a mesma (`export_settings`, guardada lá); a troca sai na
// hora, num `edit_settings` só, e vale o que a releitura mostrar — se a
// pedaleira recusar ou não mudar, o seletor volta ao valor real e avisa
// (DECISOES FM2).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/ajustes/modo_footswitches.dart';
import '../../nucleo/resultado.dart';
import 'controlador_ajustes.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

final controladorModoProvider =
    NotifierProvider<ControladorModoFootswitches, EstadoModoFootswitches>(ControladorModoFootswitches.new);

/// O que a tela mostra: o pedido em andamento ou o lido da pedaleira.
final modoExibidoProvider = Provider<ModoFootswitches?>(
    (ref) => ref.watch(controladorModoProvider).pedido ?? ref.watch(controladorAjustesProvider).lidos?.modo);

/// Os ajustes já foram lidos (com ou sem `mode`).
final modoLidoProvider = Provider<bool>((ref) => ref.watch(controladorAjustesProvider.select((e) => e.lidos != null)));

/// O firmware exporta `mode`: sem isso o seletor fica desabilitado.
final modoDisponivelProvider =
    Provider<bool>((ref) => ref.watch(controladorAjustesProvider.select((e) => e.lidos?.temModo ?? false)));

class EstadoModoFootswitches {
  const EstadoModoFootswitches({this.pedido, this.recusado = false});

  /// Escolhido e ainda não confirmado pela releitura.
  final ModoFootswitches? pedido;

  /// A última troca não se confirmou.
  final bool recusado;
}

class ControladorModoFootswitches extends Notifier<EstadoModoFootswitches> {
  /// Cresce a cada troca de conexão: resposta de antes dela é descartada.
  int _geracao = 0;

  @override
  EstadoModoFootswitches build() {
    ref.listen(conexaoProvider, (_, _) {
      _geracao++;
      state = const EstadoModoFootswitches();
    });
    return const EstadoModoFootswitches();
  }

  RepositorioPedaleira? get _repositorio =>
      ref.read(conexaoProvider) is Conectada ? ref.read(conexaoProvider.notifier).repositorio : null;

  /// Lê os ajustes se ninguém leu ainda: o editor mostra o modo sem passar
  /// pelas Configurações.
  Future<void> garantirLeitura() async {
    final ajustes = ref.read(controladorAjustesProvider);
    if (ajustes.lidos == null && !ajustes.carregando) await ref.read(controladorAjustesProvider.notifier).carregar();
  }

  /// Grava [modo] e relê; devolve se a releitura mostrou [modo].
  Future<bool> escolher(ModoFootswitches modo) async {
    final repositorio = _repositorio;
    if (repositorio == null || state.pedido != null || !ref.read(modoDisponivelProvider)) return false;
    final geracao = _geracao;
    state = EstadoModoFootswitches(pedido: modo);
    final gravado = await repositorio.gravarModoFootswitches(modo);
    if (geracao != _geracao) return false;
    await ref.read(controladorAjustesProvider.notifier).carregar();
    if (geracao != _geracao) return false;
    final confirmado = gravado is Sucesso && ref.read(controladorAjustesProvider).lidos?.modo == modo;
    state = EstadoModoFootswitches(recusado: !confirmado);
    return confirmado;
  }
}
