// Capturas das telas principais em inglês e espanhol: as frases ficam maiores
// que em português e não podem estourar botão, barra nem lista.
// Gerar/atualizar: flutter test test/capturas --update-goldens
import 'package:anagram_app/aplicacao/idioma.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

const _idiomas = [IdiomaApp.ingles, IdiomaApp.espanhol];
const _desktop = desktopWindows;
const _celular = Tamanho('celular-retrato', 390, 844, 2);

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
}
