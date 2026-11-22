// Painéis da bateria e do metrônomo na tela, ponta a ponta na demonstração:
// uma fileira de cartões na ordem da tela da Anagram; trocar o estilo e o
// compasso muda o preset e o que a pedaleira toca; o Action é uma chave
// gravada no preset; o BATER grava o BPM só no modo Fixed Tempo; no celular
// os cartões quebram em mais fileiras sem estourar.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/painel_utilitario.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/arranjo_utilitario.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

const _casa = PosicaoBloco(1, 4);
const _bateria = 'https://falktx.com/plugins/auto-drummer';
const _metro = 'https://cognate.audio/plugins/cognate-metro';

/// Relógio do BATER andado à mão pelo teste.
class _Relogio {
  Duration agora = Duration.zero;
}

Future<ProviderContainer> _comBloco(WidgetTester tester, String uri,
    {Size tamanho = const Size(1440, 2000), _Relogio? relogio}) async {
  final container = await abrirDemonstracao(tester,
      tamanho: tamanho, overrides: [if (relogio != null) relogioDoToqueProvider.overrideWithValue(() => relogio.agora)]);
  unawaited(container.read(editorProvider.notifier).abrirSlot(SlotPreset.doRotulo('01A')));
  await tester.pumpAndSettle();
  unawaited(container.read(editorProvider.notifier).adicionarBloco(_casa, lerCatalogo().definicao(uri)));
  await tester.pumpAndSettle();
  return container;
}

num? _valor(ProviderContainer c, String simbolo) => c.read(editorProvider).atual!.bloco(_casa)!.valorBase(simbolo);

TransporteDemonstracao _pedaleira(ProviderContainer c) =>
    c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

/// O valor do parâmetro no bloco [uri] de um preset tocado ao vivo.
num? _noTocado(Map<String, dynamic>? preset, String uri, String simbolo) {
  final blocos = preset!['preset']['chains']['1']['blocks'] as Map;
  final bloco = blocos.values.firstWhere((b) => b['uri'] == uri) as Map;
  final parametros = (bloco['parameters'] as Map).values;
  return parametros.firstWhere((p) => p['symbol'] == simbolo, orElse: () => const {'value': null})['value'] as num?;
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_lay_the_drum_cards_in_one_row_in_the_pedal_order', (tester) async {
    await _comBloco(tester, _bateria);
    final cantos = [
      for (final s in ['style', 'level', 'action', 'status', 'useHostTempo', 'userTempo'])
        tester.getTopLeft(find.byKey(ValueKey('cartao-$s'))),
    ];

    expect(cantos.map((c) => c.dy).toSet(), hasLength(1), reason: 'uma fileira só, como no visor');
    expect([for (var i = 1; i < cantos.length; i++) cantos[i].dx > cantos[i - 1].dx], everyElement(isTrue));
    expect(find.descendant(of: find.byKey(const ValueKey('cartao-status')), matching: find.text('Só no visor da pedaleira')),
        findsOneWidget, reason: 'o estado não chega pelo USB: nada de valor inventado');
    expect(find.byKey(const ValueKey('ut-outros')), findsNothing, reason: 'todo parâmetro tem lugar no painel');
  });

  testWidgets('should_play_a_drum_style_picked_from_the_neighbours_or_the_grouped_list', (tester) async {
    final c = await _comBloco(tester, _bateria);

    await _tocar(tester, find.byKey(const ValueKey('vizinha-style-13')));
    expect(_valor(c, 'style'), 13, reason: 'a vizinha de baixo do Rock vira a marcada');
    expect(find.byKey(const ValueKey('vizinha-style-14')), findsOneWidget, reason: 'e a lista rola uma');

    await _tocar(tester, find.byKey(const ValueKey('abrir-style')));
    expect(find.text('JAZZ'), findsOneWidget, reason: 'os 17 estilos agrupados pela família');
    await _tocar(tester, find.byKey(const ValueKey('opcao-style-4')));

    expect(_valor(c, 'style'), 4);
    expect(_noTocado(_pedaleira(c).presetTocando, _bateria, 'style'), 4, reason: 'a pedaleira toca o Funk');
  });

  testWidgets('should_switch_action_like_the_pedal_screen_and_keep_it_in_the_preset', (tester) async {
    final c = await _comBloco(tester, _bateria);
    final pedaleira = _pedaleira(c);
    final chave = find.byKey(const ValueKey('chave-action'));
    expect(find.descendant(of: find.byKey(const ValueKey('cartao-action')), matching: chave), findsOneWidget);
    expect(find.byKey(const ValueKey('ajuda-action')), findsOneWidget, reason: 'o que o Action faz fica no "?"');
    expect(find.text('DISPARAR'), findsNothing, reason: 'na pedaleira o Action é chave, não botão');

    await _tocar(tester, chave);
    expect(_noTocado(pedaleira.presetTocando, _bateria, 'action'), 1, reason: 'ligar soa na hora');
    expect(_valor(c, 'action'), 1, reason: 'o preset guarda a chave, como a pedaleira');
    expect(c.read(editorProvider).naoSalvo, isTrue);

    await _tocar(tester, chave);
    expect(_noTocado(pedaleira.presetTocando, _bateria, 'action'), 0, reason: 'desligar também');
    expect(_valor(c, 'action'), 0);
  });

  testWidgets('should_dim_the_drum_tempo_while_it_follows_the_global_tempo', (tester) async {
    final c = await _comBloco(tester, _bateria);
    Finder apagado() => find.ancestor(
        of: find.byKey(const ValueKey('param-userTempo')),
        matching: find.byWidgetPredicate((w) => w is Opacity && w.opacity < 1));
    expect(apagado(), findsNothing);

    await _tocar(tester, find.byKey(const ValueKey('chave-useHostTempo')));

    expect(_valor(c, 'useHostTempo'), 1);
    expect(apagado(), findsOneWidget, reason: 'apagado, mas ajustável, como o arpejador desligado');
  });

  testWidgets('should_roll_the_time_signature_and_play_it', (tester) async {
    final c = await _comBloco(tester, _metro);
    final rolo = find.byKey(const ValueKey('cartao-time_signature'));
    expect(find.descendant(of: rolo, matching: find.text('3/4')), findsOneWidget, reason: 'a anterior, apagada');
    expect(find.descendant(of: rolo, matching: find.text('5/4')), findsOneWidget, reason: 'a seguinte, apagada');

    await _tocar(tester, find.byKey(const ValueKey('proxima-time_signature')));
    expect(_valor(c, 'time_signature'), 3, reason: 'de 4/4 para 5/4');

    await _tocar(tester, find.byKey(const ValueKey('abrir-time_signature')));
    await _tocar(tester, find.byKey(const ValueKey('opcao-time_signature-5')));

    expect(_valor(c, 'time_signature'), 5);
    expect(_noTocado(_pedaleira(c).presetTocando, _metro, 'time_signature'), 5, reason: 'a pedaleira toca 6/8');
    expect(find.descendant(of: rolo, matching: find.text('9/8')), findsOneWidget, reason: 'o rolo andou junto');
  });

  testWidgets('should_put_the_metronome_page_two_in_a_practice_row_below', (tester) async {
    await _comBloco(tester, _metro);
    final principal = [for (final s in ['tempo', 'mode', 'time_signature', 'sound', 'level']) tester.getTopLeft(find.byKey(ValueKey('cartao-$s')))];
    final treino = [for (final s in ['gap_mode', 'accuracy']) tester.getTopLeft(find.byKey(ValueKey('cartao-$s')))];

    expect(principal.map((c) => c.dy).toSet(), hasLength(1));
    expect(treino.first.dy, greaterThan(principal.first.dy), reason: 'a página 2 do visor vira a fileira de baixo');
    expect(find.text('TREINO'), findsOneWidget);
  });

  testWidgets('should_write_the_tapped_tempo_only_in_fixed_tempo_mode', (tester) async {
    final relogio = _Relogio();
    final c = await _comBloco(tester, _metro, relogio: relogio);
    final bater = find.byKey(const ValueKey('toque-tempo'));
    Future<void> tocarAos(List<int> instantes) async {
      for (final ms in instantes) {
        relogio.agora = Duration(milliseconds: ms);
        await _tocar(tester, bater);
      }
    }

    await tocarAos([0, 500, 1000, 1500]);
    expect(_valor(c, 'tempo'), 120);
    expect(_noTocado(_pedaleira(c).presetTocando, _metro, 'tempo'), 120);

    c.read(editorProvider.notifier).alterarParametro('mode', 2, arrastando: false, posicao: _casa);
    await tester.pumpAndSettle();
    await tocarAos([10000, 10400, 10800]);
    expect(_valor(c, 'tempo'), 120, reason: 'em Global Tempo o BATER não grava');
    expect(find.byTooltip('Bater o tempo só vale no modo Fixed Tempo.'), findsOneWidget);
  });

  for (final (uri, cartoes) in [(_bateria, ['style', 'userTempo']), (_metro, ['tempo', 'level'])]) {
    testWidgets('should_wrap_the_${cartoes.first}_row_without_overflow_on_a_phone', (tester) async {
      await _comBloco(tester, uri, tamanho: const Size(390, 2600));

      final [primeiro, ultimo] = [for (final s in cartoes) tester.getTopLeft(find.byKey(ValueKey('cartao-$s')))];
      expect(ultimo.dy, greaterThan(primeiro.dy), reason: 'no celular, a fileira quebra');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('should_show_a_parameter_the_arrangement_does_not_know_under_others', (tester) async {
    final catalogo = lerCatalogo().definicao(_metro);
    const novo = DefinicaoParametro(simbolo: 'swing', nome: 'Swing', minimo: 0, maximo: 1, padrao: 0);
    final definicao = DefinicaoBloco(
        uri: _metro, nome: catalogo.nome, abreviacao: '', categoria: '', parametros: [...catalogo.parametros, novo]);
    const bloco = BlocoPreset(_casa, {'uri': _metro});

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PainelUtilitario(
                arranjo: arranjoUtilitario(_metro)!,
                bloco: bloco,
                definicao: definicao,
                cena: 1,
                parametros: [novo],
                tamanhoKnob: 104),
          ),
        ),
      ),
    ));

    expect(find.descendant(of: find.byKey(const ValueKey('ut-outros')), matching: find.byKey(const ValueKey('param-swing'))),
        findsOneWidget);
  });
}
