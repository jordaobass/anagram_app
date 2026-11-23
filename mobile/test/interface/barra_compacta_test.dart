// A parte de cima do editor (barra de conexão, fita do preset, Salvar/
// Descartar, cenas e modo) era alta demais no computador (relato no Reddit).
// Com mouse ela fica compacta, com alvos de 32 a 40 px; no toque continua no
// mínimo de 48 dp. Na janela mínima, nos três idiomas, nada pode estourar.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/apresentacao/componentes/barra_conexao.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart' show carregarFontes;
import '../apoio/demonstracao_na_tela.dart';

const _alvoMinimoComMouse = 32.0;

Future<void> _naPlataforma(TargetPlatform plataforma, Future<void> Function() corpo) async {
  debugDefaultTargetPlatformOverride = plataforma;
  try {
    await corpo();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

/// 02A aberto e editado: SALVAR preenchido, DESCARTAR habilitado, selo NÃO SALVO.
Future<void> _presetEditado(WidgetTester tester, Size tamanho, IdiomaApp idioma) async {
  await montarApp(tester, tamanho: tamanho, idioma: idioma);
  final c = await entrarNaDemonstracao(tester);
  unawaited(c.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('02A')));
  await tester.pumpAndSettle();
  c.read(editorProvider.notifier).alterarParametro('Threshold', -52, arrastando: false);
  await tester.pumpAndSettle();
}

/// As duas opções da chave "Controlar" sob as cenas (DECISOES CE1).
const _chaveControlar = ['controlar-todasAsCenas', 'controlar-soNaCena'];

/// Onde começa a cadeia de blocos (a primeira casa) num editor de [tamanho].
Future<double> _topoDaCadeia(WidgetTester tester, TargetPlatform plataforma, Size tamanho) async {
  var topo = 0.0;
  await _naPlataforma(plataforma, () async {
    await _presetEditado(tester, tamanho, IdiomaApp.portugues);
    topo = tester.getTopLeft(find.byKey(const ValueKey('casa-1-1'))).dy;
    // desmonta o app para a próxima medida nascer do zero
    await tester.pumpWidget(const SizedBox.shrink());
  });
  return topo;
}

double _altura(WidgetTester tester, String chave) => tester.getSize(find.byKey(ValueKey(chave))).height;

void main() {
  // com as fontes reais: a fonte de teste (Ahem) desenha toda letra como um
  // quadrado e mede palavras bem mais largas que as de verdade
  setUpAll(carregarFontes);

  for (final idioma in IdiomaApp.values) {
    testWidgets('should_keep_the_top_bar_compact_and_inside_the_minimum_window_with_the_mouse_${idioma.name}',
        (tester) => _naPlataforma(TargetPlatform.windows, () async {
              await _presetEditado(tester, const Size(Medidas.larguraMinimaJanela, Medidas.alturaMinimaJanela), idioma);

              expect(tester.getSize(find.byType(BarraConexao)).height, lessThanOrEqualTo(48));
              for (final chave in ['botao-salvar', 'botao-salvar-como', 'cena-1', 'cena-2', 'cena-3', ..._chaveControlar]) {
                expect(_altura(tester, chave), inInclusiveRange(_alvoMinimoComMouse, 40), reason: chave);
              }
              expect(_altura(tester, 'fita-nome'), lessThanOrEqualTo(44));
            }));
  }

  testWidgets('should_bring_the_block_chain_up_on_a_desktop_window', (tester) async {
    const janela = Size(1440, 900);
    final noToque = await _topoDaCadeia(tester, TargetPlatform.android, janela);
    final comMouse = await _topoDaCadeia(tester, TargetPlatform.windows, janela);

    // o mesmo topo (barra, fita, cenas e a chave Controlar) com alvos de toque
    // e com mouse: a versão compacta sobe a cadeia pelo menos 50 px
    expect(comMouse, lessThanOrEqualTo(noToque - 50), reason: 'toque $noToque, mouse $comMouse');
  });

  testWidgets('should_keep_touch_targets_of_48_dp_on_a_tablet',
      (tester) => _naPlataforma(TargetPlatform.android, () async {
            await _presetEditado(tester, const Size(1366, 1024), IdiomaApp.portugues);

            for (final chave in ['botao-salvar', 'botao-salvar-como', 'cena-1', ..._chaveControlar]) {
              expect(_altura(tester, chave), greaterThanOrEqualTo(Medidas.alvoMinimo), reason: chave);
            }
          }));
}
