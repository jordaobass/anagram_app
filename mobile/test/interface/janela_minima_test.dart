// Janela do computador: o Windows e o macOS não deixam a janela ficar menor
// que Medidas.larguraMinimaJanela × alturaMinimaJanela (runner nativo). Nesse
// tamanho, e logo acima da quebra da barra larga, nada pode estourar a linha —
// barra de conexão, seletor de modo e bandas do EQ — em nenhum dos idiomas.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';
import '../apoio/versao_falsa.dart';

const _casa = PosicaoBloco(1, 4);

/// Roda [corpo] como o app no Windows; a plataforma volta antes do fim do teste.
Future<void> _noWindows(Future<void> Function() corpo) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  try {
    await corpo();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// O app conectado à demonstração, com o Parametric EQ aberto.
Future<void> _editorComEq(WidgetTester tester, Size tamanho, IdiomaApp idioma) async {
  await montarApp(tester, tamanho: tamanho, idioma: idioma);
  final c = await entrarNaDemonstracao(tester);
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(c.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao('urn:darkglass:fil4#mono')));
  await tester.pumpAndSettle();
}

void main() {
  for (final idioma in IdiomaApp.values) {
    testWidgets('should_fit_the_eq_bands_and_the_mode_selector_when_the_window_is_at_its_minimum_width_${idioma.name}',
        (tester) => _noWindows(() async {
              // alta o bastante para o painel inteiro ser montado de uma vez
              await _editorComEq(tester, const Size(Medidas.larguraMinimaJanela, 2400), idioma);
              await tester.ensureVisible(find.byKey(const ValueKey('banda-eq-bloco-shelfAgudos')));
              await tester.pumpAndSettle();

              await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
              await tester.pumpAndSettle();
              await tester.ensureVisible(find.byKey(const ValueKey('cartao-global-eq')));
              await tester.pumpAndSettle();
            }));
  }

  // espanhol e francês têm as frases mais longas
  for (final idioma in [IdiomaApp.espanhol, IdiomaApp.frances]) {
    testWidgets('should_fit_the_editor_when_the_window_is_at_its_minimum_size_${idioma.name}',
        (tester) => _noWindows(() async {
              await _editorComEq(tester, const Size(Medidas.larguraMinimaJanela, Medidas.alturaMinimaJanela), idioma);

              expect(find.byKey(const ValueKey('casa-1-4')), findsOneWidget);
            }));

    for (final largura in [Quebras.amplo, Quebras.amplo + 40]) {
      testWidgets(
          'should_fit_the_connection_bar_when_the_wide_window_is_just_above_the_breakpoint_${largura}_${idioma.name}',
          (tester) => _noWindows(() => _editorComEq(tester, Size(largura, 900), idioma)));
    }

    // com versão nova, a barra só marca a engrenagem com um ponto (DECISOES
    // BS1): nada de texto que estoure, da janela mínima à barra larga
    for (final largura in [Medidas.larguraMinimaJanela, Quebras.amplo]) {
      testWidgets('should_fit_the_connection_bar_with_the_new_version_dot_at_${largura}_${idioma.name}',
          (tester) => _noWindows(() async {
                await montarApp(tester,
                    tamanho: Size(largura, 900), idioma: idioma, github: GithubFalso(tag: 'v10.10.10'));
                await entrarNaDemonstracao(tester);

                expect(tester.widget<Badge>(find.byKey(const ValueKey('selo-versao-nova'))).isLabelVisible, isTrue);
              }));
    }
  }
}
