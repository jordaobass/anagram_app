// O gráfico do compressor da banda é lido pelo leitor de tela no idioma do
// app, com o Ratio como ele é (2,5:1), não arredondado.
import 'package:anagram_app/apresentacao/componentes/grafico_banda.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _montar(WidgetTester tester, Locale idioma) => tester.pumpWidget(MaterialApp(
      locale: idioma,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: GraficoCompressor(limiarDb: -30, razao: 2.5, ligado: true, cor: Colors.blue),
      ),
    ));

void main() {
  testWidgets('should_read_the_ratio_with_its_decimal_in_the_app_language_when_the_compressor_graph_is_announced',
      (tester) async {
    final semantica = tester.ensureSemantics();
    await _montar(tester, const Locale('pt'));
    expect(find.bySemanticsLabel('Curva do compressor: Threshold -30 dB, Ratio 2,5:1'), findsOneWidget);

    await _montar(tester, const Locale('en'));
    expect(find.bySemanticsLabel('Compressor curve: Threshold -30 dB, Ratio 2.5:1'), findsOneWidget);
    semantica.dispose();
  });
}
