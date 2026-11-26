// Modo Biblioteca na tela (DECISOES BB1): o interruptor ao lado do "Ao vivo"
// troca a lista da pedaleira pelos presets prontos por banda; tocar só abre
// (sem slot); aplicar escolhe o slot na lista da pedaleira e grava, com
// confirmação quando o slot está ocupado.
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/modo_biblioteca.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/estado/biblioteca_presets.dart';
import 'package:anagram_app/dados/arquivos_biblioteca.dart';
import 'package:anagram_app/dados/arquivos_preset.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

class _ArquivoEscolhido implements ArquivosBiblioteca {
  const _ArquivoEscolhido(this.texto);

  final String texto;

  @override
  Future<ArquivoEscolhido?> lerEscolhido() async => ArquivoEscolhido('meus presets', texto);

  @override
  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) async => DestinoExportacao.arquivo;
}

const _export =
    '{"exported": "2026-12-01", "presets": [{"slot": "20A", "name": "MEU LIMPO", "blocks": ['
    '{"row": 1, "col": 1, "type": "urn:darkglass:FETComp", "enabled": true, "params": {"Input": 6}}]}]}';

Future<ProviderContainer> _naBiblioteca(WidgetTester tester) async {
  final container = await abrirDemonstracao(
    tester,
    overrides: [
      arquivosBibliotecaProvider.overrideWithValue(const _ArquivoEscolhido(_export)),
      // lido do disco: o rootBundle não anda no relógio falso
      textoBibliotecaBandasProvider.overrideWith(
        (ref) async => File(CaminhosAssets.bibliotecaBandas).readAsStringSync(),
      ),
    ],
  );
  await tester.tap(find.byKey(const ValueKey('interruptor-biblioteca')));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('should_show_the_ready_presets_by_band_when_the_library_switch_is_turned_on', (tester) async {
    await _naBiblioteca(tester);

    expect(find.byKey(const ValueKey('lista-biblioteca')), findsOneWidget);
    expect(find.byKey(const ValueKey('lista-presets')), findsNothing);
    expect(find.byKey(const ValueKey('banda-$nomeColecaoEmbutida-Muse')), findsOneWidget);
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-MUSE FUZZ')), findsOneWidget);
  });

  testWidgets('should_open_the_preset_without_a_slot_when_a_library_preset_is_tapped', (tester) async {
    final container = await _naBiblioteca(tester);

    await tester.tap(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-QOTSA FUZZ')));
    await tester.pumpAndSettle();

    final editor = container.read(editorProvider);
    expect(editor.atual?.nome, 'QOTSA FUZZ');
    expect(editor.slot, isNull, reason: 'só toca: nenhum slot da pedaleira muda');
    expect(container.read(modoBibliotecaProvider), isTrue);
  });

  testWidgets('should_save_the_library_preset_over_the_chosen_slot_after_confirming_when_apply_is_used', (
    tester,
  ) async {
    final container = await _naBiblioteca(tester);

    await tester.tap(find.byKey(const ValueKey('aplicar-$nomeColecaoEmbutida-MUSE FUZZ')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsOneWidget);
    expect(container.read(modoBibliotecaProvider), isFalse, reason: 'o destino é escolhido na lista da pedaleira');

    await tocarNoSlot(tester, '01A');
    await tester.tap(find.byKey(const ValueKey('confirmar-substituicao')));
    await tester.pumpAndSettle();

    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    expect(pedaleira.conteudoDoSlot(1)!['preset']['name'], 'MUSE FUZZ');
    expect(container.read(editorProvider).slot?.rotulo, '01A');
  });

  testWidgets('should_add_the_imported_file_as_a_new_collection_when_imported_from_the_library_menu', (tester) async {
    await _naBiblioteca(tester);

    await tester.tap(find.byKey(const ValueKey('menu-biblioteca')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('biblioteca-importar')));
    await tester.pumpAndSettle();

    expect(find.text('Coleção “meus presets” adicionada com 1 presets.'), findsOneWidget);
    await _rolarAte(tester, find.byKey(const ValueKey('biblioteca-meus presets-MEU LIMPO')));
    expect(find.byKey(const ValueKey('colecao-meus presets')), findsOneWidget);
  });

  testWidgets('should_filter_the_list_as_the_search_is_typed_and_say_when_nothing_matches', (tester) async {
    await _naBiblioteca(tester);

    await tester.enterText(find.byKey(const ValueKey('busca-biblioteca')), 'soad');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-SOAD CLEAN')), findsOneWidget);
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-MUSE FUZZ')), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('busca-biblioteca')), 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('Nada encontrado para “xyz”.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('limpar-busca-biblioteca')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-MUSE FUZZ')), findsOneWidget);
  });

  testWidgets('should_put_the_bands_in_name_order_when_sorting_a_to_z', (tester) async {
    await _naBiblioteca(tester);

    await tester.tap(find.byKey(const ValueKey('ordem-biblioteca')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ordem-nomeAZ')));
    await tester.pumpAndSettle();

    final limp = tester.getTopLeft(find.byKey(const ValueKey('banda-$nomeColecaoEmbutida-Limp Bizkit'))).dy;
    final muse = tester.getTopLeft(find.byKey(const ValueKey('banda-$nomeColecaoEmbutida-Muse'))).dy;
    expect(limp, lessThan(muse));
  });

  testWidgets('should_hide_and_show_a_collection_when_its_title_is_tapped', (tester) async {
    await _naBiblioteca(tester);

    await tester.tap(find.byKey(const ValueKey('colecao-$nomeColecaoEmbutida')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-MUSE FUZZ')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('colecao-$nomeColecaoEmbutida')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('biblioteca-$nomeColecaoEmbutida-MUSE FUZZ')), findsOneWidget);
  });

  testWidgets('should_delete_an_imported_collection_after_confirming_and_never_offer_it_for_the_built_in_one', (
    tester,
  ) async {
    final container = await _naBiblioteca(tester);
    await container.read(fonteBibliotecaProvider.notifier).importarTexto(_export, nomeDoArquivo: 'X');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('menu-colecao-$nomeColecaoEmbutida')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('colecao-apagar')), findsNothing, reason: 'a do build não se apaga');
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('colecao-$nomeColecaoEmbutida')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-colecao-X')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('colecao-apagar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirmar-apagar-colecao')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('colecao-X')), findsNothing);
    expect(find.text('Coleção “X” apagada.'), findsOneWidget);
  });
}

Future<void> _rolarAte(WidgetTester tester, Finder alvo) => tester.scrollUntilVisible(
  alvo,
  200,
  scrollable: find.descendant(of: find.byKey(const ValueKey('lista-biblioteca')), matching: find.byType(Scrollable)),
);
