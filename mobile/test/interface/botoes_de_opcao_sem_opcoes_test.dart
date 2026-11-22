// Parâmetro de botões que chegou sem opções (catálogo de firmware novo,
// arquivo mexido): o painel mostra o rótulo e nenhum botão, sem quebrar.
import 'package:anagram_app/apresentacao/componentes/controles_utilitario.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _semOpcoes = DefinicaoParametro(simbolo: 'signature', nome: 'Time Signature', minimo: 0, maximo: 0, padrao: 0);

void main() {
  testWidgets('should_show_the_label_without_buttons_when_the_parameter_has_no_options', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BotoesDeOpcao(
            parametro: _semOpcoes,
            bloco: BlocoPreset(const PosicaoBloco(1, 1), {'uri': 'urn:teste:metro'}),
            valor: 0,
            cor: Colors.blue,
          ),
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('TIME SIGNATURE'), findsOneWidget);
  });
}
