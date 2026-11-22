// Os blocos que carregam arquivo (TONE3000, neural, IR do usuário) mostram
// QUAL arquivo carregam: o título do tom de fábrica ou o nome do arquivo, na
// casa da grade e no cabeçalho do painel. Antes, todos diziam só
// "TONE3000 NAM Loader".
import 'package:anagram_app/aplicacao/arte/indice_miniaturas.dart';
import 'package:anagram_app/aplicacao/arte/tons_tone3000.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/cabecalho_bloco.dart';
import 'package:anagram_app/apresentacao/componentes/casa_bloco.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

const _tone3000 = 'urn:darkglass:neural:tone3000';
const _tomDeFabrica = '/factory-data/neural-models-t3k/1612/1612-Mesa_OS_4x12_57_m160.nam';

final _indice = IndiceMiniaturas(const {}, const {}, '',
    tons: TonsTone3000.doJson({
      'tons': {
        '1612': {'titulo': 'Mesa OS 4x12 IR', 'gear': 'cab'}
      }
    }));

BlocoPreset _bloco(String uri, String valor) => BlocoPreset(const PosicaoBloco(1, 1), {
      'uri': uri,
      'enabled': true,
      'properties': {
        '1': {'name': 'Neural Model', 'uri': '$uri#model', 'value': valor}
      },
    });

Future<void> _montar(WidgetTester tester, Widget filho) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      indiceMiniaturasProvider.overrideWith((ref) async => _indice),
      catalogoProvider.overrideWith((ref) async => lerCatalogo()),
    ],
    child: MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: filho),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  String? nome(String uri, String valor) => nomeDoModeloCarregado(uri, valor, _indice.tons);

  test('should_name_the_tone_by_the_factory_title_or_the_file_name_without_path_and_extension', () {
    expect(nome(_tone3000, _tomDeFabrica), 'Mesa OS 4x12 IR');
    expect(nome(_tone3000, '/data/user-files/neural-models-t3k/99999/Meu Ampeg SVT.nam'), 'Meu Ampeg SVT');
    expect(nome('urn:darkglass-anagram:cabinet-tone3000#stereo', 'Tone 4242 - IR Cab do Ensaio'), 'Cab do Ensaio');
    expect(nome('urn:darkglass:neural:amp', '/factory-data/neural-models/AX Komrade 1.dat'), 'AX Komrade 1');
    expect(nome('urn:darkglass-anagram:cabinet-user', '/data/user-files/cabinets/Meu 4x10.wav'), 'Meu 4x10');
  });

  test('should_not_name_a_model_when_the_block_does_not_load_a_file', () {
    expect(nome('urn:darkglass:Chorus', '/factory-data/qualquer.dat'), isNull);
    expect(nome(_tone3000, '  '), isNull);
  });

  testWidgets('should_show_the_tone_title_in_the_grid_slot_and_in_the_panel_header', (tester) async {
    final bloco = _bloco(_tone3000, _tomDeFabrica);
    await _montar(
        tester,
        Column(children: [
          CasaBloco(
              posicao: bloco.posicao,
              bloco: bloco,
              ligado: true,
              selecionado: false,
              largura: 120,
              aoTocar: () {},
              aoTocarDuas: () {},
              aoPedirMenu: (_) {}),
          CabecalhoBloco(bloco: bloco, definicao: lerCatalogo().definicao(_tone3000), cena: 1),
        ]));

    expect(find.text('Mesa OS 4x12 IR'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('nome-do-modelo')), findsOneWidget);
  });
}
