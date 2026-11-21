// Lista de presets do aparelho (126 slots), recarregada a cada conexão.
// Com firmware 1.18+ a pedaleira tem várias áreas de presets: a lista é a da
// área escolhida aqui, que começa sendo a ativa na pedaleira. A ativa pode
// mudar na própria pedaleira, então é relida antes de cada lista e de cada
// Program Change. Toda resposta que chega depois de uma espera só vale se a
// conexão ainda for a mesma: o cabo pode ter saído no meio.
// A área Fábrica (U18) é do app, não da pedaleira: a lista dela sai do
// arquivo gerado do Suite e nenhum pedido com ela vai pelo USB.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../avisos.dart';
import '../provedores.dart';
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/resultado.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

const Object _manter = Object();

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
  final Aviso? erro;
  final AreasDaPedaleira areas;

  /// Id da área cuja lista está na tela; nulo = firmware sem áreas.
  final String? areaSelecionada;

  ResumoSlot? resumo(SlotPreset slot) => ocupados[slot];

  /// A lista na tela é a da fábrica: só leitura, e o Program Change não vale.
  bool get naFabrica => areaSelecionada == PresetsDeFabrica.idArea;

  /// A lista na tela é de uma área que a pedaleira não está usando (ou não se
  /// sabe qual ela usa): o Program Change trocaria o slot de OUTRA área, então
  /// abrir um preset só o toca.
  bool get areaForaDaPedaleira => areas.temAreas && (areas.ativa == null || areaSelecionada != areas.ativa);

  /// [erro] fica como está se não for passado; `erro: null` o apaga.
  EstadoBiblioteca copiar({
    Map<SlotPreset, ResumoSlot>? ocupados,
    bool? carregando,
    Object? erro = _manter,
    AreasDaPedaleira? areas,
    String? areaSelecionada,
  }) =>
      EstadoBiblioteca(
        ocupados: ocupados ?? this.ocupados,
        carregando: carregando ?? this.carregando,
        erro: identical(erro, _manter) ? this.erro : erro as Aviso?,
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

  RepositorioPedaleira? get _repositorio => ref.read(conexaoProvider.notifier).repositorio;

  /// A conexão de [repositorio] ainda é a de agora (o cabo não saiu nem
  /// reconectou durante a espera).
  bool _mesmaConexao(RepositorioPedaleira repositorio) => identical(_repositorio, repositorio);

  /// Descobre as áreas (e a ativa) antes da primeira lista. Se os ajustes não
  /// vierem, segue como firmware de área única: a lista ainda carrega.
  Future<void> _aoConectar() async {
    final repositorio = _repositorio;
    if (repositorio == null) return;
    state = state.copiar(carregando: true);
    final areas = await _lerAreas(repositorio, padrao: const AreasDaPedaleira.unica());
    if (!_mesmaConexao(repositorio)) return;
    // ativa desconhecida: a lista começa pela primeira área, sem Program Change
    final inicial = areas.ativa ?? areas.areas.firstOrNull?.id;
    state = EstadoBiblioteca(carregando: true, areas: areas, areaSelecionada: inicial);
    await recarregar(relerAreas: false);
  }

  Future<AreasDaPedaleira> _lerAreas(RepositorioPedaleira repositorio, {required AreasDaPedaleira padrao}) async =>
      switch (await repositorio.lerAreas()) {
        Sucesso(:final valor) => valor,
        Falha() => padrao,
      };

  /// Relê os ajustes para saber a área ativa de agora. Sem áreas (firmware
  /// antigo) não pergunta: o pedido levaria o prazo inteiro sem resposta.
  Future<void> _atualizarAtiva(RepositorioPedaleira repositorio) async {
    if (!state.areas.temAreas) return;
    final relidas = await _lerAreas(repositorio, padrao: state.areas);
    if (_mesmaConexao(repositorio) && relidas.temAreas) state = state.copiar(areas: relidas);
  }

  Future<void> recarregar({bool relerAreas = true}) async {
    final repositorio = _repositorio;
    if (repositorio == null) return;
    // a fábrica não muda; só a área ativa da pedaleira pode ter mudado
    if (state.naFabrica) {
      if (relerAreas) await _atualizarAtiva(repositorio);
      return;
    }
    final area = state.areaSelecionada;
    // nova tentativa: o erro da anterior sai da tela
    state = state.copiar(carregando: true, erro: null);
    if (relerAreas) await _atualizarAtiva(repositorio);
    final resultado = await repositorio.listarSlots(area: area);
    // o cabo saiu, ou trocou de área enquanto a lista vinha: a resposta não vale
    if (!_mesmaConexao(repositorio) || state.areaSelecionada != area) return;
    state = switch (resultado) {
      Sucesso(:final valor) => state.copiar(ocupados: {for (final r in valor) r.slot: r}, carregando: false),
      Falha(:final erro) => state.copiar(carregando: false, erro: AvisoErro(erro)),
    };
  }

  /// Mostra os presets de outra área. Não muda a área da pedaleira.
  Future<void> selecionarArea(String id) async {
    if (_repositorio == null || id == state.areaSelecionada) return;
    if (id == PresetsDeFabrica.idArea) return _mostrarFabrica();
    if (state.areas.area(id) == null) return;
    state = EstadoBiblioteca(carregando: true, areas: state.areas, areaSelecionada: id);
    await recarregar();
  }

  /// Só com áreas (o seletor só existe com elas) e com o arquivo no build.
  Future<void> _mostrarFabrica() async {
    final fabrica = await ref.read(presetsFabricaProvider.future);
    if (fabrica.vazio || !state.areas.temAreas || _repositorio == null) return;
    state = EstadoBiblioteca(
      areas: state.areas,
      areaSelecionada: PresetsDeFabrica.idArea,
      ocupados: {for (final resumo in fabrica.resumos) resumo.slot: resumo},
    );
  }

  /// A área na tela é a que a pedaleira está usando agora, relida da própria
  /// pedaleira: só então um Program Change cai no slot que a pessoa vê.
  Future<bool> areaDaTelaEstaAtiva() async {
    final repositorio = _repositorio;
    if (repositorio == null) return false;
    await _atualizarAtiva(repositorio);
    return _mesmaConexao(repositorio) && !state.areaForaDaPedaleira;
  }

  /// Passa a pedaleira para a área da tela, para o Program Change valer nela.
  /// O "ok" do `edit_settings` não basta (DECISOES, U11): só conta como ativa
  /// se os ajustes relidos disserem que a pedaleira de fato trocou.
  Future<void> tornarSelecionadaAtiva() async {
    final repositorio = _repositorio;
    final id = state.areaSelecionada;
    if (repositorio == null || id == null) return;
    final pedido = await repositorio.tornarAreaAtiva(id);
    if (!_mesmaConexao(repositorio)) return;
    if (pedido case Falha(:final erro)) {
      state = state.copiar(erro: AvisoAreaNaoTrocou(erro));
      return;
    }
    await _atualizarAtiva(repositorio);
    if (!_mesmaConexao(repositorio)) return;
    if (state.areas.ativa == id) {
      state = state.copiar(erro: null);
      return;
    }
    final continuou = state.areas.ativa ?? '?';
    state = state.copiar(erro: AvisoAreaNaoTrocou(ErroRespostaInvalida('A pedaleira continuou na área $continuou.')));
  }

  /// Atualiza uma linha depois de salvar, sem reler a lista inteira.
  void registrarSalvo(SlotPreset slot, String nome, {String? id}) {
    state = state.copiar(ocupados: {...state.ocupados, slot: ResumoSlot(slot: slot, nome: nome, id: id)});
  }

  /// O slot foi limpo na pedaleira: a linha passa a "vazio" sem reler a lista.
  void registrarVazio(SlotPreset slot) {
    state = state.copiar(ocupados: {...state.ocupados}..remove(slot));
  }
}
