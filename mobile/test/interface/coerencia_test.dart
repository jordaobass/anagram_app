// Coerência da interface: o que a pessoa vê tem de ser o mesmo em qualquer
// tela e idioma — erro perto da ação, sem nome de biblioteca USB, idioma ao
// alcance antes de conectar, área ativa sem frase cortada, versão só no Sobre
// e nenhum detalhe técnico do protocolo nos avisos.
import 'dart:typed_data';

import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/painel_parametros.dart';
import 'package:anagram_app/apresentacao/textos.dart';
import 'package:anagram_app/l10n/app_localizations.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

/// Aparelho preso por outro programa, com o nome técnico do meio entre parênteses.
class _AparelhoOcupado implements TransporteAnagram {
  @override
  String get descricao => 'USB (hidapi)';
  @override
  Duration get pausaSugerida => Duration.zero;
  @override
  bool get aberto => false;
  @override
  Stream<EstadoTransporte> get estados => const Stream.empty();
  @override
  Stream<Uint8List> get relatoriosRecebidos => const Stream.empty();
  @override
  Future<void> abrir() async => throw const ErroInterfaceOcupada('hid_open_path falhou');
  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {}
  @override
  Future<void> fechar() async {}
}

class _Fabrica implements FabricaTransporte {
  const _Fabrica(this.suporte);
  @override
  final SuporteAparelho suporte;
  @override
  TransporteAnagram criarAparelho() => _AparelhoOcupado();
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

double _topo(WidgetTester tester, Key chave) => tester.getTopLeft(find.byKey(chave)).dy;

void main() {
  final pt = lookupAppLocalizations(const Locale('pt'));

  testWidgets('should_let_the_language_be_changed_on_the_connect_screen_when_not_connected', (tester) async {
    await montarApp(tester);

    await tester.tap(find.byKey(const ValueKey('menu-idioma')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('OPEN DEMO'), findsOneWidget);
  });

  testWidgets('should_show_the_connection_error_above_the_buttons_without_the_usb_library_name_when_opening_fails',
      (tester) async {
    await montarApp(tester, overrides: [
      fabricaTransporteProvider.overrideWithValue(const _Fabrica(AparelhoDisponivel('USB (hidapi)'))),
    ]);
    expect(find.textContaining('hidapi'), findsNothing, reason: 'nome de biblioteca não é para a pessoa');

    await tester.tap(find.byKey(const ValueKey('botao-conectar')));
    await tester.pumpAndSettle();

    expect(_topo(tester, const ValueKey('aviso-conexao')), lessThan(_topo(tester, const ValueKey('botao-conectar'))));
    expect(find.textContaining('hidapi'), findsNothing);
  });

  testWidgets('should_make_the_demo_the_main_action_when_the_platform_cannot_reach_the_pedal', (tester) async {
    await montarApp(tester, overrides: [
      fabricaTransporteProvider.overrideWithValue(const _Fabrica(AparelhoIndisponivel(MotivoIndisponivel.ios))),
    ]);

    expect(find.widgetWithText(FilledButton, 'ABRIR DEMONSTRAÇÃO'), findsOneWidget);
    expect(find.byKey(const ValueKey('botao-conectar')), findsNothing);
  });

  testWidgets('should_mark_the_active_area_apart_from_its_name_when_it_is_selected', (tester) async {
    await abrirDemonstracao(tester);

    expect(find.byKey(const ValueKey('etiqueta-area-ativa')), findsOneWidget);
    expect(find.textContaining('ativa na pedaleira'), findsNothing, reason: 'o nome não pode carregar a frase e cortar');
  });

  testWidgets('should_show_the_version_only_in_about_when_connected', (tester) async {
    await abrirDemonstracao(tester);
    expect(find.byKey(const ValueKey('versao-app')), findsNothing, reason: 'a barra de cima já tem informação demais');

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('versao-app')), findsOneWidget);
  });

  test('should_keep_protocol_details_out_of_portuguese_messages_when_an_operation_fails', () {
    const tecnico = 'Falha ao enviar "edit_anagram_presets": ErroDesconectado: cabo removido';
    final textos = [
      pt.erroDeOperacao(const ErroDesconectado(tecnico)),
      pt.erroDeOperacao(const ErroInterfaceOcupada(tecnico)),
      pt.erroDeOperacao(const ErroRespostaInvalida(tecnico)),
      pt.erroDeConexao(const ErroRespostaInvalida(tecnico)),
    ];

    for (final texto in textos) {
      expect(texto, isNot(contains('edit_anagram_presets')));
      expect(texto, isNotEmpty);
    }
  });

  test('should_speak_of_clicks_on_a_computer_and_of_taps_on_a_touch_screen_when_giving_hints', () {
    expect(pt.dicaMontarCadeiaPara(mouse: true), contains('Clique'));
    expect(pt.dicaMontarCadeiaPara(mouse: false), contains('Toque'));
    expect(pt.slotVazioTextoPara(mouse: true), contains('botão direito'));
    expect(pt.slotVazioTextoPara(mouse: false), contains('segure'));
  });

  test('should_hide_the_bypass_parameter_when_the_block_has_one_since_on_off_is_the_header_button', () {
    const definicao = DefinicaoBloco(
      uri: 'urn:teste:synth',
      nome: 'Synth',
      abreviacao: 'SYN',
      categoria: 'Utilities',
      parametros: [
        DefinicaoParametro(simbolo: 'enabled', nome: 'Enabled', minimo: 0, maximo: 1, padrao: 1, papel: 'bypass'),
        DefinicaoParametro(simbolo: 'level', nome: 'Level', minimo: 0, maximo: 1, padrao: 0.5),
      ],
    );

    final visiveis = parametrosVisiveis(definicao, const BlocoPreset(PosicaoBloco(1, 1), {'uri': 'urn:teste:synth'}));

    expect(visiveis.map((p) => p.simbolo), ['level']);
  });
}
