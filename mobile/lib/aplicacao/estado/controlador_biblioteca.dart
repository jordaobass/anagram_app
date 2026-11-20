// Lista de presets do aparelho (126 slots), recarregada a cada conexão.
// Com firmware 1.18+ a pedaleira tem várias áreas de presets: a lista é a da
// área escolhida aqui, que começa sendo a ativa na pedaleira.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/resultado.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

class EstadoBiblioteca {
  const EstadoBiblioteca({
    this.ocupados = const {},
    this.carregando = false,
    this.erro,
    this.areas = const AreasDaPedaleira.unica(),
    this.areaSelecionada,
  });

  final Map<SlotPreset, ResumoSlot> ocupados;
  final bool carregando;
  final String? erro;
  final AreasDaPedaleira areas;

  /// Id da área cuja lista está na tela; nulo = firmware sem áreas.
  final String? areaSelecionada;

  ResumoSlot? resumo(SlotPreset slot) => ocupados[slot];

  /// A lista na tela é de uma área que a pedaleira não está usando: o Program
  /// Change trocaria o slot da OUTRA área, então abrir um preset só o toca.
  bool get areaForaDaPedaleira => areas.temAreas && areaSelecionada != areas.ativa;

  EstadoBiblioteca copiar({
    Map<SlotPreset, ResumoSlot>? ocupados,
    bool? carregando,
    String? erro,
    AreasDaPedaleira? areas,
    String? areaSelecionada,
  }) =>
      EstadoBiblioteca(
        ocupados: ocupados ?? this.ocupados,
        carregando: carregando ?? this.carregando,
        erro: erro,
        areas: areas ?? this.areas,
        areaSelecionada: areaSelecionada ?? this.areaSelecionada,
      );
}

final bibliotecaProvider =
    NotifierProvider<ControladorBiblioteca, EstadoBiblioteca>(ControladorBiblioteca.new);

class ControladorBiblioteca extends Notifier<EstadoBiblioteca> {
  @override
  EstadoBiblioteca build() {
    ref.listen(conexaoProvider, (_, estado) {
      if (estado is Conectada) unawaited(_aoConectar());
      if (estado is SemConexao) state = const EstadoBiblioteca();
    });
    // a lista pode nascer depois da conexão: aí carrega na primeira leitura
    final conectada = ref.read(conexaoProvider) is Conectada;
    if (conectada) Future.microtask(_aoConectar);
    return EstadoBiblioteca(carregando: conectada);
  }

  /// Descobre as áreas (e a ativa) antes da primeira lista. Se os ajustes não
  /// vierem, segue como firmware de área única: a lista ainda carrega.
  Future<void> _aoConectar() async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return;
    state = state.copiar(carregando: true);
    final areas = switch (await repositorio.lerAreas()) {
      Sucesso(:final valor) => valor,
      Falha() => const AreasDaPedaleira.unica(),
    };
    repositorio.areaEmUso = areas.ativa;
    state = EstadoBiblioteca(carregando: true, areas: areas, areaSelecionada: areas.ativa);
    await recarregar();
  }

  Future<void> recarregar() async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return;
    final area = state.areaSelecionada;
    state = state.copiar(carregando: true);
    final resultado = await repositorio.listarSlots();
    // trocou de área enquanto a lista vinha: esta resposta é da área anterior
    if (state.areaSelecionada != area) return;
    state = switch (resultado) {
      Sucesso(:final valor) => state.copiar(ocupados: {for (final r in valor) r.slot: r}, carregando: false),
      Falha(:final erro) => state.copiar(carregando: false, erro: erro.mensagem),
    };
  }

  /// Mostra os presets de outra área. Não muda a área da pedaleira.
  Future<void> selecionarArea(String id) async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null || id == state.areaSelecionada || state.areas.area(id) == null) return;
    repositorio.areaEmUso = id;
    state = EstadoBiblioteca(carregando: true, areas: state.areas, areaSelecionada: id);
    await recarregar();
  }

  /// Passa a pedaleira para a área da tela, para o Program Change valer nela.
  /// Hipótese a conferir na bancada (DECISOES, U11).
  Future<void> tornarSelecionadaAtiva() async {
    final repositorio = ref.read(conexaoProvider.notifier).repositorio;
    final id = state.areaSelecionada;
    if (repositorio == null || id == null) return;
    state = switch (await repositorio.tornarAreaAtiva(id)) {
      Sucesso() => state.copiar(areas: AreasDaPedaleira(state.areas.areas, ativa: id)),
      Falha(:final erro) => state.copiar(erro: 'A pedaleira não trocou de área: ${erro.mensagem}'),
    };
  }

  /// Atualiza uma linha depois de salvar, sem reler a lista inteira.
  void registrarSalvo(SlotPreset slot, String nome, {String? id}) {
    state = state.copiar(ocupados: {...state.ocupados, slot: ResumoSlot(slot: slot, nome: nome, id: id)});
  }
}
