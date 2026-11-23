// Monitoramento de Entrada no clique em CONECTAR, no macOS (DECISOES CA5):
// ainda não decidido, o app mostra o pedido do sistema ANTES de abrir o USB;
// negado, não abre o USB e a tela explica, leva aos Ajustes e pede para
// reabrir o app.
import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/aplicacao/versao_nova.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/acesso_entrada_mac.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';
import '../apoio/textos_pt.dart';

/// Guarda, em ordem, o que aconteceu: pedido ao sistema e abertura do USB.
class _Linha {
  final eventos = <String>[];
}

class _PedaleiraNoCabo extends TransporteDemonstracao {
  _PedaleiraNoCabo(this._linha) : super(presets: lerPresetsDemonstracao());

  final _Linha _linha;

  @override
  String get descricao => 'USB (IOKit)';

  @override
  Future<void> abrir() async {
    _linha.eventos.add('abrir-usb');
    await super.abrir();
  }
}

class _FabricaMac implements FabricaTransporte {
  _FabricaMac(this._linha);

  final _Linha _linha;

  @override
  SuporteAparelho get suporte => const AparelhoDisponivel('USB (IOKit)');
  @override
  TransporteAnagram criarAparelho() => _PedaleiraNoCabo(_linha);
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

Future<_Linha> _abrirNoMac(WidgetTester tester,
    {required AcessoEntrada acesso, AcessoEntrada depoisDoPedido = AcessoEntrada.naoDecidido, List<Uri>? links}) async {
  final linha = _Linha();
  await montarApp(tester,
      overrides: [
        fabricaTransporteProvider.overrideWithValue(_FabricaMac(linha)),
        abridorDeLinkProvider.overrideWithValue((endereco) async {
          links?.add(endereco);
          return true;
        }),
      ],
      abertura: PlataformaDeAbertura.macOS,
      // a abertura não tenta sozinha: o que se testa aqui é o clique
      preferenciasConexao: PreferenciasConexaoEmMemoria(false),
      acessoEntradaMac: () async => acesso,
      pedidoAcessoEntradaMac: () async {
        linha.eventos.add('pedido-ao-sistema');
        return depoisDoPedido;
      });
  return linha;
}

Future<void> _tocarConectar(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-conectar')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should_explain_and_not_open_usb_when_input_monitoring_is_denied', (tester) async {
    final links = <Uri>[];
    final linha = await _abrirNoMac(tester, acesso: AcessoEntrada.negado, links: links);

    await _tocarConectar(tester);

    expect(linha.eventos, isEmpty, reason: 'negado: nem pede de novo, nem abre o USB');
    expect(find.text(textosPt.caMonitoramentoNegado), findsOneWidget);
    expect(find.text(textosPt.caReabraDepois), findsOneWidget, reason: 'a permissão só vale reabrindo o app');
    expect(containerDaTela(tester).read(conexaoProvider), isA<FalhaDeConexao>());

    await tester.tap(find.byKey(const ValueKey('abrir-ajustes-monitoramento')));
    await tester.pumpAndSettle();
    expect(links, [Uri.parse('x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent')]);
  });

  testWidgets('should_ask_the_system_before_opening_usb_when_input_monitoring_is_undecided', (tester) async {
    final linha = await _abrirNoMac(tester, acesso: AcessoEntrada.naoDecidido, depoisDoPedido: AcessoEntrada.concedido);

    await _tocarConectar(tester);

    expect(linha.eventos, ['pedido-ao-sistema', 'abrir-usb'], reason: 'o pedido sai antes de o USB abrir');
    expect(containerDaTela(tester).read(conexaoProvider), isA<Conectada>());
  });

  testWidgets('should_explain_instead_of_opening_usb_when_the_request_is_still_pending', (tester) async {
    final linha = await _abrirNoMac(tester, acesso: AcessoEntrada.naoDecidido);

    await _tocarConectar(tester);

    expect(linha.eventos, ['pedido-ao-sistema'], reason: 'sem resposta do sistema, o USB fica fechado');
    expect(find.text(textosPt.caMonitoramentoNegado), findsOneWidget);
    expect(find.byKey(const ValueKey('abrir-ajustes-monitoramento')), findsOneWidget);
  });

  testWidgets('should_open_usb_without_asking_when_input_monitoring_is_granted', (tester) async {
    final linha = await _abrirNoMac(tester, acesso: AcessoEntrada.concedido);

    await _tocarConectar(tester);

    expect(linha.eventos, ['abrir-usb']);
    expect(containerDaTela(tester).read(conexaoProvider), isA<Conectada>());
    expect(find.byKey(const ValueKey('abrir-ajustes-monitoramento')), findsNothing);
  });
}
