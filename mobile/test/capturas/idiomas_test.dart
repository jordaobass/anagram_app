// Capturas das telas principais em inglês, espanhol e francês: as frases ficam
// maiores que em português e não podem estourar botão, barra nem lista.
// Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';
import '../apoio/demonstracao_na_tela.dart';

const _idiomas = [IdiomaApp.ingles, IdiomaApp.espanhol, IdiomaApp.frances];
const _desktop = desktopWindows;
const _celular = Tamanho('celular-retrato', 390, 844, 2);

/// A menor janela que o Windows e o macOS deixam abrir (DECISOES K6).
const _janelaMinima = Tamanho('janela-minima', Medidas.larguraMinimaJanela, Medidas.alturaMinimaJanela, 1,
    plataforma: TargetPlatform.windows);

void main() {
  setUpAll(carregarFontes);

  for (final idioma in _idiomas) {
    final prefixo = '$pasta/idiomas/${idioma.codigo}';

    testWidgets('captura ${idioma.codigo}: conectar no celular', (tester) async {
      await preparar(tester, _celular, idioma: idioma);
      await capturar(tester, '$prefixo-celular-1-conectar.png');
    });

    testWidgets('captura ${idioma.codigo}: editor no computador', (tester) async {
      await preparar(tester, _desktop, idioma: idioma);
      await abrirPresetEditado(tester, _desktop);
      await capturar(tester, '$prefixo-desktop-2-editor.png');
    });

    testWidgets('captura ${idioma.codigo}: editor no celular', (tester) async {
      await preparar(tester, _celular, idioma: idioma);
      await abrirPresetEditado(tester, _celular);
      await capturar(tester, '$prefixo-celular-2-editor.png');
    });
  }

  // francês, o mais longo, também no conectar e nas Configurações da menor janela
  testWidgets('captura fr: conectar na janela mínima', (tester) async {
    await preparar(tester, _janelaMinima, idioma: IdiomaApp.frances);
    await capturar(tester, '$pasta/idiomas/fr-janela-minima-1-conectar.png');
  });

  testWidgets('captura fr: configurações na janela mínima', (tester) async {
    await preparar(tester, _janelaMinima, idioma: IdiomaApp.frances);
    await entrarNaDemonstracao(tester);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();
    await capturar(tester, '$pasta/idiomas/fr-janela-minima-configuracoes.png');
  });

  // o topo compacto na menor janela, nos quatro idiomas (DECISOES BC1)
  for (final idioma in IdiomaApp.values) {
    testWidgets('captura ${idioma.codigo}: editor na janela mínima', (tester) async {
      await preparar(tester, _janelaMinima, idioma: idioma);
      await abrirPresetEditado(tester, _janelaMinima);
      await capturar(tester, '$pasta/idiomas/${idioma.codigo}-janela-minima-editor.png');
    });
  }
}
