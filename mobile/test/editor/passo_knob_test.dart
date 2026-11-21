// Seta, rodinha e leitor de tela no knob: um passo sempre muda o valor,
// também nos parâmetros inteiros e de opções (DECISOES EQ4/K1).
import 'package:anagram_app/apresentacao/componentes/botao_giratorio.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _semitom = DefinicaoParametro(
    simbolo: 'Semitone', nome: 'Semitone', minimo: -12, maximo: 12, padrao: 0, inteiro: true);
const _subdivisao = DefinicaoParametro(
    simbolo: 'Subdivision', nome: 'Subdivision', minimo: 0, maximo: 3, padrao: 0, opcoes: ['1/4', '1/8', '1/8.', '1/16']);
const _ganho = DefinicaoParametro(simbolo: 'Gain', nome: 'Gain', minimo: -12, maximo: 12, padrao: 0, unidade: 'dB');

/// Monta o knob com o valor guardado fora dele, como o editor faz.
Future<List<num>> _montar(WidgetTester tester, DefinicaoParametro parametro, num inicial) async {
  final enviados = <num>[];
  var valor = inicial;
  await tester.pumpWidget(MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: StatefulBuilder(
          builder: (context, setState) => BotaoGiratorio(
            parametro: parametro,
            valor: valor,
            cor: Colors.blue,
            tamanho: 84,
            aoMudar: (novo, {required arrastando}) => setState(() {
              valor = novo;
              enviados.add(novo);
            }),
          ),
        ),
      ),
    ),
  ));
  return enviados;
}

Future<void> _focar(WidgetTester tester) async {
  await tester.tap(find.byType(BotaoGiratorio));
  await tester.pump();
}

Future<void> _tecla(WidgetTester tester, LogicalKeyboardKey tecla) async {
  await tester.sendKeyEvent(tecla);
  await tester.pump();
}

Future<void> _rolar(WidgetTester tester, double dy) async {
  final ponteiro = TestPointer(1, PointerDeviceKind.mouse)..hover(tester.getCenter(find.byType(BotaoGiratorio)));
  await tester.sendEventToBinding(ponteiro.scroll(Offset(0, dy)));
  await tester.pump();
}

void main() {
  testWidgets('should_move_one_semitone_when_the_arrow_is_pressed_on_an_integer_parameter', (tester) async {
    final enviados = await _montar(tester, _semitom, 0);
    await _focar(tester);

    await _tecla(tester, LogicalKeyboardKey.arrowUp);
    await _tecla(tester, LogicalKeyboardKey.arrowUp);
    await _tecla(tester, LogicalKeyboardKey.arrowLeft);

    expect(enviados, [1, 2, 1]);
  });

  testWidgets('should_take_a_coarse_step_of_whole_positions_when_shift_is_held', (tester) async {
    final enviados = await _montar(tester, _semitom, 0);
    await _focar(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await _tecla(tester, LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(enviados, [2], reason: '10% de 24 semitons, arredondado a posições inteiras');
  });

  testWidgets('should_move_to_the_next_option_when_the_wheel_turns_on_an_option_parameter', (tester) async {
    final enviados = await _montar(tester, _subdivisao, 1);

    await _rolar(tester, -20);
    await _rolar(tester, 20);
    await _rolar(tester, 20);

    expect(enviados, [2, 1, 0]);
  });

  testWidgets('should_announce_the_next_option_and_change_it_when_the_screen_reader_increases', (tester) async {
    final semantica = tester.ensureSemantics();
    final enviados = await _montar(tester, _subdivisao, 0);
    final no = tester.getSemantics(find.byType(BotaoGiratorio));

    expect(no.getSemanticsData().increasedValue, '1/8');
    tester.binding.pipelineOwner.semanticsOwner!.performAction(no.id, SemanticsAction.increase);
    await tester.pump();

    expect(enviados, [1]);
    semantica.dispose();
  });

  testWidgets('should_keep_the_fine_step_of_one_percent_on_a_continuous_parameter', (tester) async {
    final enviados = await _montar(tester, _ganho, 0);
    await _focar(tester);

    await _tecla(tester, LogicalKeyboardKey.arrowUp);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await _tecla(tester, LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

    expect(enviados[0], closeTo(0.24, 1e-9));
    expect(enviados[1], closeTo(2.64, 1e-9));
  });
}
