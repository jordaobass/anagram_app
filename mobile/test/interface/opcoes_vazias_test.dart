// Parâmetro de opções que chegou sem opções (catálogo de firmware novo,
// arquivo mexido): a lista rolante e o rolo mostram o rótulo, sem quebrar.
import 'package:anagram_app/apresentacao/componentes/controles_utilitario.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _semOpcoes = DefinicaoParametro(simbolo: 'signature', nome: 'Time Signature', minimo: 0, maximo: 0, padrao: 0);

Future<void> _mostrar(WidgetTester tester, Widget controle) => tester.pumpWidget(MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(width: 168, child: controle)),
    ));

void _semMudar(num valor, {required bool arrastando}) {}

void main() {
  for (final (nome, controle) in [
    ('rolling_list', const ListaRolante(parametro: _semOpcoes, valor: 0, cor: Colors.blue, aoMudar: _semMudar)),
    ('roll', const RoloOpcoes(parametro: _semOpcoes, valor: 0, cor: Colors.blue, aoMudar: _semMudar)),
  ]) {
    testWidgets('should_show_the_label_of_the_${nome}_when_the_parameter_has_no_options', (tester) async {
      await _mostrar(tester, controle);

      expect(tester.takeException(), isNull);
      expect(find.text('TIME SIGNATURE'), findsOneWidget);
    });
  }
}
