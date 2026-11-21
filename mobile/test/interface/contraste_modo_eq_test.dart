// O nome do modo do EQ é texto na cor do modo sobre o painel: precisa de
// 4,5:1 (WCAG AA, texto normal). A cor da pedaleira continua no chip e na curva.
import 'package:anagram_app/apresentacao/componentes/tela_eq.dart';
import 'package:anagram_app/apresentacao/tema/tokens.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/ajustes/mapa_ajustes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Razão de contraste da WCAG 2.x entre duas cores opacas.
double contrasteWcag(Color a, Color b) {
  final (claro, escuro) = (a.computeLuminance(), b.computeLuminance());
  final (maior, menor) = claro > escuro ? (claro, escuro) : (escuro, claro);
  return (maior + 0.05) / (menor + 0.05);
}

Future<Color> _corDoNome(WidgetTester tester, ModoEq modo) async {
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SeletorModoEq(modo: modo, aoEscolher: (_) {})),
  ));
  final l = AppLocalizations.of(tester.element(find.byType(SeletorModoEq)));
  final nome = switch (modo) {
    ModoEq.gain => l.pdEqModoGanho,
    ModoEq.freq => l.pdEqModoFrequencia,
    ModoEq.width => l.pdEqModoLargura,
  };
  return tester.widget<Text>(find.text(nome)).style!.color!;
}

void main() {
  testWidgets('should_reach_4_5_to_1_when_the_eq_mode_name_is_written_on_the_panel', (tester) async {
    for (final modo in ModoEq.values) {
      final cor = await _corDoNome(tester, modo);
      for (final fundo in [Cores.painel, Cores.painelElevado]) {
        expect(contrasteWcag(cor, fundo), greaterThanOrEqualTo(4.5), reason: '${modo.name} sobre $fundo');
      }
    }
  });

  test('should_reach_4_5_to_1_when_the_value_is_written_on_the_mode_chip', () {
    for (final modo in ModoEq.values) {
      expect(contrasteWcag(Cores.textoSobreModoEq, Cores.doModoEq(modo)), greaterThanOrEqualTo(4.5), reason: modo.name);
    }
  });
}
