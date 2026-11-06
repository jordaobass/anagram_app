// Provedores de infraestrutura: catálogo, presets de demonstração e
// fábrica de transporte. Os testes sobrepõem estes.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nucleo/catalogo/catalogo_blocos.dart';
import '../nucleo/catalogo/definicao_bloco.dart';
import '../nucleo/demonstracao/transporte_demonstracao.dart';
import '../nucleo/midi/saida_midi.dart';
import '../nucleo/registro.dart';
import '../plataforma/fabrica_transporte.dart';
import 'arte/indice_miniaturas.dart';

abstract final class CaminhosAssets {
  static const catalogo = 'assets/referencia/blocks-factory.json';
  /// Opcional: fica fora do git até haver autorização (ver DECISOES A2).
  static const miniaturas = 'assets/blocos_terceiros/indice.json';
  static const demonstracao = 'assets/demonstracao/presets.json';
  static const exemplos = [1, 2, 13, 41];
  static String exemplo(int n) => 'assets/referencia/exemplos/$n.json';
}

final pacoteAssetsProvider = Provider<AssetBundle>((ref) => rootBundle);

final catalogoProvider = FutureProvider<CatalogoBlocos>((ref) async {
  final texto = await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.catalogo);
  return CatalogoBlocos.doTexto(texto);
});

/// Sem a pasta de miniaturas, índice vazio: todo bloco usa a arte própria.
final indiceMiniaturasProvider = FutureProvider<IndiceMiniaturas>((ref) async {
  try {
    final texto = await ref.watch(pacoteAssetsProvider).loadString(CaminhosAssets.miniaturas);
    return IndiceMiniaturas.doTexto(texto);
  } on FlutterError catch (erro) {
    registro.i('miniaturas de terceiros ausentes; usando arte própria (${erro.message})');
    return IndiceMiniaturas.vazio();
  }
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

/// Pausa entre relatórios escolhida pela pessoa (null = a sugerida pelo transporte).
final pausaRelatoriosProvider = NotifierProvider<PausaRelatorios, Duration?>(PausaRelatorios.new);

class PausaRelatorios extends Notifier<Duration?> {
  @override
  Duration? build() => null;

  void definir(Duration? pausa) => state = pausa;
}

/// A demonstração simula também o USB MIDI (os testes trocam: sem MIDI, MIDI lento).
final midiDemonstracaoProvider = Provider<SaidaMidiAnagram? Function()>((ref) => SaidaMidiDemonstracao.new);

/// Gancho de teste: ajusta a pedaleira simulada logo depois de criada.
final ajusteDemonstracaoProvider = Provider<void Function(TransporteDemonstracao)>((ref) => (_) {});

final fabricaTransporteProvider = Provider<FabricaTransporte>((ref) => criarFabricaDaPlataforma());

/// Definição de um bloco pela uri; fora do catálogo vira "desconhecido".
final definicaoBlocoProvider = Provider.family<DefinicaoBloco, String>(
  (ref, uri) => ref.watch(catalogoProvider).value?.definicao(uri) ?? DefinicaoBloco.desconhecido(uri),
);
