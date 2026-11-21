// Capturas da linha paralela com o Split e a linha 2 em colunas diferentes:
// a derivação tem de sair do Split, ir ao PRIMEIRO bloco da linha 2 e voltar
// do ÚLTIMO para o Merge (como a pedaleira faz), qualquer que seja a coluna.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

/// O 03A ("Paralelo Grave") com o Split, o Merge e a linha 2 rearrumados.
Future<void> _abrirRearrumado(WidgetTester tester, Tamanho t, DocumentoPreset Function(DocumentoPreset) rearrumar) async {
  await preparar(tester, t);
  final container = await abrirSlot(tester, '03A');
  final editor = container.read(editorProvider.notifier);
  unawaited(editor.carregarDocumento(rearrumar(container.read(editorProvider).atual!)));
  await tester.pumpAndSettle();
}

DocumentoPreset _moverTudo(DocumentoPreset d, List<(PosicaoBloco, PosicaoBloco)> movimentos) {
  var resultado = d;
  for (final (de, para) in movimentos) {
    resultado = resultado.comBlocoMovido(de, para);
  }
  return resultado;
}

void main() {
  setUpAll(carregarFontes);
  const desktop = desktopWindows;

  testWidgets('captura desktop: split na casa 3 e linha 2 começando na casa 1', (tester) async {
    // 03A: Split em 1·2, Merge em 1·5, linha 2 em 2·3 e 2·4
    await _abrirRearrumado(tester, desktop, (d) => _moverTudo(d, const [
          (PosicaoBloco(1, 2), PosicaoBloco(1, 3)),
          (PosicaoBloco(2, 3), PosicaoBloco(2, 1)),
          (PosicaoBloco(2, 4), PosicaoBloco(2, 2)),
        ]));
    await capturar(tester, '$pasta/desktop-8-derivacao-linha2-antes-do-split.png');
  });

  testWidgets('captura desktop: linha 2 depois do merge', (tester) async {
    await _abrirRearrumado(tester, desktop, (d) => _moverTudo(d, const [
          (PosicaoBloco(2, 3), PosicaoBloco(2, 7)),
          (PosicaoBloco(2, 4), PosicaoBloco(2, 8)),
        ]));
    await capturar(tester, '$pasta/desktop-9-derivacao-linha2-depois-do-merge.png');
  });

  testWidgets('captura celular: cadeia com linha paralela', (tester) async {
    await preparar(tester, const Tamanho('celular-retrato', 390, 844, 2));
    await abrirSlot(tester, '03A');
    await capturar(tester, '$pasta/celular-retrato-5-linha-paralela.png');
  });
}
