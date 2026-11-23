// Chave "Controlar: todas as cenas / só a cena ativa" (DECISOES CE1), pela
// interface e com a pedaleira de demonstração: girar o knob e ligar/desligar
// o bloco na cena 2 do 02A, e conferir o que cada cena toca na pedaleira.
// No 02A o Microtubes tem high_drive 5 no bloco e 8.5 só na cena 3.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/cenas_do_bloco.dart';
import 'package:anagram_app/nucleo/modelo/json_util.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart' show pedaleiraDe;
import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';

const _microtubes = PosicaoBloco(1, 3);
const _compressor = PosicaoBloco(1, 2);
const _cenas = [1, 2, 3];

/// O bloco que a pedaleira de demonstração está tocando agora.
BlocoPreset _tocando(ProviderContainer container, PosicaoBloco posicao) {
  final preset = pedaleiraDe(container).presetTocando!['preset'] as Map<String, dynamic>;
  final linha = mapaOuVazio(mapaOuVazio(preset['chains'])['${posicao.linha}']);
  return BlocoPreset(posicao, mapaOuVazio(linha['blocks'])['${posicao.casa}'] as Map<String, dynamic>);
}

/// Troca de cena pela tela e devolve o que a pedaleira toca em cada uma.
Future<List<T>> _naPedaleiraPorCena<T>(WidgetTester tester, ProviderContainer container, PosicaoBloco posicao,
    T Function(BlocoPreset tocando) ler) async {
  final lidos = <T>[];
  for (final cena in _cenas) {
    await _tocarCena(tester, cena);
    lidos.add(ler(_tocando(container, posicao)));
  }
  return lidos;
}

num? _highDrive(BlocoPreset bloco) => bloco.valorBase('high_drive');

bool _ligado(BlocoPreset bloco) => bloco.habilitado;

Future<void> _tocarCena(WidgetTester tester, int cena) async {
  await voltarAoTopoDoEditor(tester);
  await tester.tap(find.byKey(ValueKey('cena-$cena')));
  await tester.pumpAndSettle();
}

/// App novo (com as [preferencias] dadas), demonstração, 02A aberto, cena 2.
Future<ProviderContainer> _abrir02ANaCena2(WidgetTester tester, PreferenciasCenasEmMemoria preferencias,
    {EscopoCenas? escolher}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await montarApp(tester, preferenciasCenas: preferencias);
  final container = await entrarNaDemonstracao(tester);
  await tocarNoSlot(tester, '02A');
  if (escolher != null) {
    await tester.tap(find.byKey(ValueKey('controlar-${escolher.name}')));
    await tester.pumpAndSettle();
  }
  await _tocarCena(tester, 2);
  return container;
}

Future<void> _selecionar(WidgetTester tester, PosicaoBloco posicao) async {
  await tester.tap(find.byKey(ValueKey('casa-${posicao.linha}-${posicao.casa}')));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<num> _girarHighDrive(WidgetTester tester, ProviderContainer container) async {
  await _selecionar(tester, _microtubes);
  final knob = find.byKey(const ValueKey('param-high_drive'));
  await tester.ensureVisible(knob);
  await tester.drag(knob, const Offset(0, -60));
  await tester.pumpAndSettle();
  return container.read(editorProvider).atual!.bloco(_microtubes)!.valorNaCena('high_drive', 2)!;
}

Future<void> _desligarCompressor(WidgetTester tester) async {
  await _selecionar(tester, _compressor);
  await tester.tap(find.byKey(const ValueKey('bypass')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_change_only_scene_2_when_turning_the_knob_with_only_the_active_scene', (tester) async {
    final container = await _abrir02ANaCena2(tester, PreferenciasCenasEmMemoria());

    final novo = await _girarHighDrive(tester, container);

    expect(novo, isNot(anyOf(5, 8.5)), reason: 'o arraste mudou o valor');
    expect(await _naPedaleiraPorCena(tester, container, _microtubes, _highDrive), [5, novo, 8.5],
        reason: 'padrão = só a cena ativa: as cenas 1 e 3 tocam o que tocavam');
  });

  testWidgets('should_change_all_three_scenes_when_turning_the_knob_with_all_scenes', (tester) async {
    final container =
        await _abrir02ANaCena2(tester, PreferenciasCenasEmMemoria(), escolher: EscopoCenas.todasAsCenas);

    final novo = await _girarHighDrive(tester, container);

    expect(await _naPedaleiraPorCena(tester, container, _microtubes, _highDrive), [novo, novo, novo],
        reason: 'o 8.5 próprio da cena 3 sai: o valor deixa de variar entre as cenas');
  });

  testWidgets('should_switch_the_block_off_only_in_scene_2_with_only_the_active_scene', (tester) async {
    final container = await _abrir02ANaCena2(tester, PreferenciasCenasEmMemoria());

    await _desligarCompressor(tester);

    expect(await _naPedaleiraPorCena(tester, container, _compressor, _ligado), [true, false, true]);
  });

  testWidgets('should_switch_the_block_off_in_every_scene_with_all_scenes', (tester) async {
    final container =
        await _abrir02ANaCena2(tester, PreferenciasCenasEmMemoria(), escolher: EscopoCenas.todasAsCenas);

    await _desligarCompressor(tester);

    expect(await _naPedaleiraPorCena(tester, container, _compressor, _ligado), [false, false, false]);
  });

  testWidgets('should_keep_all_scenes_after_reopening_the_app_when_it_was_chosen', (tester) async {
    final preferencias = PreferenciasCenasEmMemoria();
    await _abrir02ANaCena2(tester, preferencias, escolher: EscopoCenas.todasAsCenas);

    // o app fecha e abre de novo com o mesmo armazenamento, sem tocar na chave
    final container = await _abrir02ANaCena2(tester, preferencias);
    final novo = await _girarHighDrive(tester, container);

    expect(await _naPedaleiraPorCena(tester, container, _microtubes, _highDrive), [novo, novo, novo]);
  });
}
