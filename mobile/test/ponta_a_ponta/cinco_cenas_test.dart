// Preset com cinco cenas (firmware 1.16+, issue #39), pela interface e com a
// pedaleira de demonstração: abrir, ir à cena 4 pela fita de cenas, girar um
// knob em "só a cena ativa", trocar para a cena 5 e salvar. O que volta da
// pedaleira tem as cinco cenas, cada uma com o próprio valor.
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_com_mcp.dart' show pedaleiraDe;
import '../apoio/app_de_teste.dart';
import '../apoio/cinco_cenas.dart';
import '../apoio/demonstracao_na_tela.dart';

const _casa = PosicaoBloco(1, 1);
const _slot01C = 3;

Future<void> _tocarCena(WidgetTester tester, int cena) async {
  await voltarAoTopoDoEditor(tester);
  final botao = find.byKey(ValueKey('cena-$cena'));
  await tester.ensureVisible(botao);
  await tester.pumpAndSettle();
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

List<num?> _porCena(BlocoPreset bloco, String simbolo) =>
    [for (var cena = 1; cena <= 5; cena++) bloco.valorNaCena(simbolo, cena)];

void main() {
  testWidgets('should_save_all_five_scenes_with_their_own_values_after_editing_only_scene_4', (tester) async {
    await montarApp(tester, preferenciasCenas: PreferenciasCenasEmMemoria());
    final container = await entrarNaDemonstracao(tester);
    final pedaleira = pedaleiraDe(container)..substituirSlot(_slot01C, presetCincoCenas());
    await tocarNoSlot(tester, '01C');
    for (final nome in ['LIMPO', 'GRAVE', 'SUJO', 'SOLO', 'FINAL']) {
      expect(find.text(nome), findsOneWidget, reason: 'a fita mostra as cinco cenas com o nome do preset');
    }

    await _tocarCena(tester, 4);
    await tester.tap(find.byKey(const ValueKey('casa-1-1')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    final knob = find.byKey(const ValueKey('param-low_level'));
    await tester.ensureVisible(knob);
    await tester.drag(knob, const Offset(0, -60));
    await tester.pumpAndSettle();
    await _tocarCena(tester, 5);
    await voltarAoTopoDoEditor(tester);
    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    final gravado = DocumentoPreset.doJson(pedaleira.conteudoDoSlot(_slot01C)!);
    final bloco = gravado.bloco(_casa)!;
    final novo = bloco.valorNaCena('low_level', 4)!;
    expect(novo, greaterThan(3), reason: 'o arraste mudou o valor da cena 4');
    expect(_porCena(bloco, 'low_level'), [3, 3, 3, novo, 3], reason: 'só a cena 4 mudou, a 5 inclusive');
    expect(_porCena(bloco, 'high_drive'), [5, 5, 8.5, 6, 7]);
    expect(gravado.quantidadeCenas, 5);
    expect([for (final c in gravado.cenas) gravado.nomeDaCena(c)], ['LIMPO', 'GRAVE', 'SUJO', 'SOLO', 'FINAL']);
    expect(gravado.cenaAtiva, 5);
  });
}
