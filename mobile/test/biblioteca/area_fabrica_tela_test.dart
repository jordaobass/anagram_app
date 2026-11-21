// A área Fábrica na tela: aparece só quando o build traz os presets de
// fábrica, marcada como só leitura; o botão de gravar vira "Copiar para a
// minha área…", que pergunta a área e depois o slot; o menu do preset só
// oferece a cópia.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

Future<void> _abrirSeletor(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('seletor-area')));
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _naFabrica(WidgetTester tester) async {
  final container = await abrirDemonstracao(tester, fabrica: PresetsDeFabrica.doTexto(textoFabricaDeTeste()));
  await _abrirSeletor(tester);
  await tester.tap(find.byKey(const ValueKey('area-${PresetsDeFabrica.idArea}')).last);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('should_offer_the_factory_area_only_when_the_build_carries_the_factory_presets', (tester) async {
    await abrirDemonstracao(tester);
    await _abrirSeletor(tester);
    expect(find.byKey(const ValueKey('area-${PresetsDeFabrica.idArea}')), findsNothing);
  });

  testWidgets('should_mark_the_factory_area_read_only_and_not_offer_to_make_it_active', (tester) async {
    await _naFabrica(tester);

    expect(find.text('Harmonic Booster'), findsOneWidget);
    expect(find.byKey(const ValueKey('selo-so-leitura')), findsWidgets);
    expect(find.byKey(const ValueKey('tornar-area-ativa')), findsNothing, reason: 'a fábrica não vai para a pedaleira');
  });

  testWidgets('should_copy_a_factory_preset_to_the_chosen_area_when_copy_to_my_area_is_used', (tester) async {
    final container = await _naFabrica(tester);
    await tocarNoSlot(tester, '01B');
    expect(find.byKey(const ValueKey('aviso-preset-fabrica')), findsOneWidget);
    expect(find.byKey(const ValueKey('botao-salvar-como')), findsNothing, reason: 'na fábrica só há a cópia');

    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('copiar-para-user-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('faixa-escolher-destino')), findsOneWidget);
    await tocarNoSlot(tester, '02B');

    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    expect(pedaleira.conteudoDoSlot(5, area: 'user-2')!['preset']['name'], 'Vintage Microtubes');
    expect(container.read(bibliotecaProvider).areaSelecionada, 'user-2', reason: 'a lista mostra onde a cópia ficou');
  });

  testWidgets('should_offer_only_the_copy_in_the_preset_menu_when_on_the_factory_area', (tester) async {
    await _naFabrica(tester);

    await tester.tap(find.byKey(const ValueKey('menu-preset-01A')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('op-copiar')), findsOneWidget);
    expect(find.byKey(const ValueKey('op-mover')), findsNothing);
    expect(find.byKey(const ValueKey('op-clonar')), findsNothing);
    expect(find.byKey(const ValueKey('op-banco')), findsNothing);
  });
}
