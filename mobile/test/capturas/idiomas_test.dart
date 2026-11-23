// Capturas das telas principais em inglês e espanhol: as frases ficam maiores
// que em português e não podem estourar botão, barra nem lista.
// Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

const _idiomas = [IdiomaApp.ingles, IdiomaApp.espanhol];
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

  // o topo compacto na menor janela, nos três idiomas (DECISOES BC1)
  for (final idioma in IdiomaApp.values) {
    testWidgets('captura ${idioma.codigo}: editor na janela mínima', (tester) async {
      await preparar(tester, _janelaMinima, idioma: idioma);
      await abrirPresetEditado(tester, _janelaMinima);
      await capturar(tester, '$pasta/idiomas/${idioma.codigo}-janela-minima-editor.png');
    });
  }
}
