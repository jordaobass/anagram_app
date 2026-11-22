// Provedores de infraestrutura: catálogo, presets de demonstração e
// fábrica de transporte. Os testes sobrepõem estes.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dados/arquivos_preset.dart';
import '../dados/preferencias_pausa.dart';
import '../nucleo/catalogo/catalogo_blocos.dart';
import '../nucleo/catalogo/definicao_bloco.dart';
import '../nucleo/catalogo/explicacoes_parametros.dart';
import '../nucleo/catalogo/templates_bloco.dart';
import '../nucleo/conhecimento/base_conhecimento.dart';
import '../nucleo/demonstracao/transporte_demonstracao.dart';
import '../nucleo/midi/saida_midi.dart';
import '../nucleo/modelo/presets_fabrica.dart';
import '../nucleo/registro.dart';
import '../plataforma/fabrica_transporte.dart';
import '../plataforma/fotos_suite.dart';
import 'arte/indice_miniaturas.dart';

abstract final class CaminhosAssets {
  static const catalogo = 'assets/referencia/blocks-factory.json';
  /// Opcional: fica fora do git até haver autorização (ver DECISOES A2).
  static const miniaturas = 'assets/blocos_terceiros/indice.json';
  /// Opcional, gerado do Darkglass Suite junto com a arte (DECISOES U18).
  static const fabrica = 'assets/blocos_terceiros/fabrica.json';
  static const demonstracao = 'assets/demonstracao/presets.json';
  static const explicacoes = 'assets/explicacoes/parametros.json';
  static const templates = 'assets/templates/blocos.json';
  /// Conhecimento de timbre que o MCP entrega à IA (DECISOES IC1).
  static const conhecimentoBlocos = 'assets/conhecimento/blocos.json';
  static const conhecimentoTimbre = 'assets/conhecimento/guia_timbre.json';
  static const conhecimentoReceitas = 'assets/conhecimento/receitas.json';
  static const exemplos = [1, 2, 13, 41];
  static String exemplo(int n) => 'assets/referencia/exemplos/$n.json';
}

final pacoteAssetsProvider = Provider<AssetBundle>((ref) => rootBundle);

final catalogoProvider = FutureProvider<CatalogoBlocos>((ref) async {
  final texto = await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.catalogo);
  return CatalogoBlocos.doTexto(texto);
});

/// Sem a pasta de miniaturas, índice vazio: todo bloco usa a arte própria.
/// Índice malformado também: vale a arte própria, e o log diz a causa.
final indiceMiniaturasProvider = FutureProvider<IndiceMiniaturas>((ref) async {
  final String texto;
  try {
    texto = await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.miniaturas);
  } on FlutterError catch (erro) {
    registro.i('miniaturas de terceiros ausentes; usando arte própria (${erro.message})');
    return IndiceMiniaturas.vazio();
  }
  try {
    return IndiceMiniaturas.doTexto(texto);
  } on Object catch (erro, pilha) {
    registro.w('índice de miniaturas malformado; usando arte própria', error: erro, stackTrace: pilha);
    return IndiceMiniaturas.vazio();
  }
});

/// A pasta do Darkglass Suite instalado (fotos dos tons TONE3000 da pessoa);
/// null no celular, no navegador e sem o Suite.
final fotosDoSuiteProvider = Provider<FotosDoSuite?>((ref) => fotosDoSuiteInstalado());

/// Sem o arquivo da fábrica (build sem a arte do Suite), não há área Fábrica.
final presetsFabricaProvider = FutureProvider<PresetsDeFabrica>((ref) async {
  try {
    return PresetsDeFabrica.doTexto(await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.fabrica));
  } on FlutterError catch (erro) {
    registro.i('presets de fábrica ausentes; sem área Fábrica (${erro.message})');
    return const PresetsDeFabrica.vazio();
  }
});

/// O que cada parâmetro faz com o som (DECISOES TT1). Sem o arquivo, os
/// controles só ficam sem a explicação — nada deixa de funcionar.
final explicacoesProvider = FutureProvider<ExplicacoesParametros>((ref) async {
  try {
    return ExplicacoesParametros.doTexto(await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.explicacoes));
  } on FlutterError catch (erro) {
    registro.w('explicações dos parâmetros ausentes (${erro.message})');
    return ExplicacoesParametros.vazio;
  }
});

/// Templates de bloco (DECISOES PP). Sem o arquivo, o seletor só não aparece.
final templatesProvider = FutureProvider<TemplatesBlocos>((ref) async {
  try {
    return TemplatesBlocos.doTexto(await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.templates));
  } on FlutterError catch (erro) {
    registro.w('templates de bloco ausentes (${erro.message})');
    return TemplatesBlocos.vazio;
  }
});

/// O conhecimento de timbre lido pela IA (DECISOES IC1). Cada arquivo que
/// faltar deixa só a sua parte vazia: as ferramentas de ajuste não dependem dele.
final conhecimentoProvider = FutureProvider<BaseConhecimento>((ref) async {
  final pacote = ref.watch(pacoteAssetsProvider);
  Future<String?> ler(String caminho) async {
    try {
      return await pacote.loadString(caminho);
    } on FlutterError catch (erro) {
      registro.w('conhecimento de timbre ausente: $caminho (${erro.message})');
      return null;
    }
  }

  final (blocos, timbre, receitas) = await (
    ler(CaminhosAssets.conhecimentoBlocos),
    ler(CaminhosAssets.conhecimentoTimbre),
    ler(CaminhosAssets.conhecimentoReceitas),
  ).wait;
  return BaseConhecimento(
    guiaBlocos: blocos == null ? GuiaBlocos.vazio : GuiaBlocos.doTexto(blocos),
    guiaTimbre: timbre == null ? GuiaTimbre.vazio : GuiaTimbre.doTexto(timbre),
    receitas: receitas == null ? ReceitasTimbre.vazio : ReceitasTimbre.doTexto(receitas),
  );
});

/// Presets da pedaleira simulada: os autorais + os exemplos reais.
final presetsDemonstracaoProvider = FutureProvider<Map<int, Map<String, dynamic>>>((ref) async {
  final pacote = ref.watch(pacoteAssetsProvider);
  final autorais = jsonDecode(await pacote.loadString(CaminhosAssets.demonstracao)) as Map<String, dynamic>;
  return {
    for (final e in autorais.entries) int.parse(e.key): e.value as Map<String, dynamic>,
    for (final n in CaminhosAssets.exemplos)
      n: jsonDecode(await pacote.loadString(CaminhosAssets.exemplo(n))) as Map<String, dynamic>,
  };
});

/// Cronômetro da latência ida e volta (os testes fixam o valor).
final cronometroProvider = Provider<Stopwatch Function()>((ref) => Stopwatch.new);

/// Relógio do "Bater" (tap tempo): o instante de cada toque, desde um
/// início qualquer; os testes andam com ele à mão.
final relogioDoToqueProvider = Provider<Duration Function()>((ref) {
  final cronometro = Stopwatch()..start();
  return () => cronometro.elapsed;
});

final preferenciasPausaProvider = Provider<PreferenciasPausa>((ref) => PreferenciasPausaLocais());

/// A pausa guardada ao abrir o app; o main lê antes da primeira tela.
final pausaSalvaProvider = Provider<Duration?>((ref) => null);

/// Pausa entre relatórios escolhida pela pessoa (null = a sugerida pelo transporte).
final pausaRelatoriosProvider = NotifierProvider<PausaRelatorios, Duration?>(PausaRelatorios.new);

class PausaRelatorios extends Notifier<Duration?> {
  @override
  Duration? build() => ref.read(pausaSalvaProvider);

  /// Vale na próxima mensagem e fica guardada para a próxima abertura.
  void definir(Duration? pausa) {
    state = pausa;
    unawaited(ref.read(preferenciasPausaProvider).gravar(pausa?.inMilliseconds));
  }
}

/// A demonstração simula também o USB MIDI (os testes trocam: sem MIDI, MIDI lento).
final midiDemonstracaoProvider = Provider<SaidaMidiAnagram? Function()>((ref) => SaidaMidiDemonstracao.new);

/// Gancho de teste: ajusta a pedaleira simulada logo depois de criada.
final ajusteDemonstracaoProvider = Provider<void Function(TransporteDemonstracao)>((ref) => (_) {});

/// Arquivos do sistema (os testes trocam por um falso que não abre diálogo).
final arquivosPresetProvider = Provider<ArquivosPreset>((ref) => const ArquivosPreset());

final fabricaTransporteProvider = Provider<FabricaTransporte>((ref) => criarFabricaDaPlataforma());

/// Definição de um bloco pela uri; fora do catálogo vira "desconhecido".
final definicaoBlocoProvider = Provider.family<DefinicaoBloco, String>(
  (ref, uri) => ref.watch(catalogoProvider).value?.definicao(uri) ?? DefinicaoBloco.desconhecido(uri),
);
