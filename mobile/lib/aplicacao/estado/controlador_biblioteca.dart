// Lista de presets do aparelho (126 slots), recarregada a cada conexão.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/resultado.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

class EstadoBiblioteca {
  const EstadoBiblioteca({this.ocupados = const {}, this.carregando = false, this.erro});

  final Map<SlotPreset, ResumoSlot> ocupados;
  final bool carregando;
  final String? erro;

  ResumoSlot? resumo(SlotPreset slot) => ocupados[slot];
}

final bibliotecaProvider =
    NotifierProvider<ControladorBiblioteca, EstadoBiblioteca>(ControladorBiblioteca.new);

class ControladorBiblioteca extends Notifier<EstadoBiblioteca> {
  @override
  EstadoBiblioteca build() {
    ref.listen(conexaoProvider, (_, estado) {
      if (estado is Conectada) unawaited(recarregar());
      if (estado is SemConexao) state = const EstadoBiblioteca();
    });
    // a lista pode nascer depois da conexão: aí carrega na primeira leitura
    final conectada = ref.read(conexaoProvider) is Conectada;
    if (conectada) Future.microtask(recarregar);
    return EstadoBiblioteca(carregando: conectada);
  }

  Future<void> recarregar() async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return;
    state = EstadoBiblioteca(ocupados: state.ocupados, carregando: true);
    final resultado = await repositorio.listarSlots();
    state = switch (resultado) {
      Sucesso(:final valor) => EstadoBiblioteca(ocupados: {for (final r in valor) r.slot: r}),
      Falha(:final erro) => EstadoBiblioteca(ocupados: state.ocupados, erro: erro.mensagem),
    };
  }

  /// Atualiza uma linha depois de salvar, sem reler a lista inteira.
  void registrarSalvo(SlotPreset slot, String nome, {String? id}) {
    state = EstadoBiblioteca(ocupados: {...state.ocupados, slot: ResumoSlot(slot: slot, nome: nome, id: id)});
  }
}
