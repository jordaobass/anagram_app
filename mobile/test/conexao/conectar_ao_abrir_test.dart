// Conectar ao abrir (DECISOES CA1–CA4): no computador, o app procura a
// pedaleira uma vez depois do primeiro quadro. Achou, entra no editor sem tocar
// nada (D5); não achou, fica na tela de conectar sem erro, com o motivo só no
// registro; desligado nas Configurações ou no Mac sem Monitoramento de Entrada,
// nem tenta.
import 'dart:typed_data';

import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/acesso_entrada_mac.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart';
import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';
import '../apoio/textos_pt.dart';
import '../apoio/versao_falsa.dart';

/// A pedaleira simulada fazendo o papel da que está no cabo.
class _PedaleiraNoCabo extends TransporteDemonstracao {
  _PedaleiraNoCabo() : super(presets: lerPresetsDemonstracao());

  @override
  String get descricao => 'USB (hidapi)';
}

/// Abre, mas nunca responde: o aperto de mão de 3 s estoura.
class _PedaleiraMuda implements TransporteAnagram {
  bool _aberto = false;

  @override
  String get descricao => 'USB (hidapi)';
  @override
  Duration get pausaSugerida => Duration.zero;
  @override
  bool get aberto => _aberto;
  @override
  Stream<EstadoTransporte> get estados => const Stream.empty();
  @override
  Stream<Uint8List> get relatoriosRecebidos => const Stream.empty();
  @override
  Future<void> abrir() async => _aberto = true;
  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {}
  @override
  Future<void> fechar() async => _aberto = false;
}

/// Nenhuma Anagram no USB, como diz o hidapi.
class _CaboVazio extends _PedaleiraMuda {
  @override
  Future<void> abrir() async => throw const ErroDesconectado('Nenhuma Anagram no USB.');
}

class _Fabrica implements FabricaTransporte {
  _Fabrica(this._criar);

  final TransporteAnagram Function() _criar;
  final criados = <TransporteAnagram>[];

  @override
  SuporteAparelho get suporte => const AparelhoDisponivel('USB (hidapi)');
  @override
  TransporteAnagram criarAparelho() {
    final transporte = _criar();
    criados.add(transporte);
    return transporte;
  }
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

Future<void> _abrirApp(WidgetTester tester, _Fabrica fabrica,
    {PlataformaDeAbertura plataforma = PlataformaDeAbertura.computador,
    bool ligado = true,
    AcessoEntrada acessoMac = AcessoEntrada.concedido}) async {
  await montarApp(tester,
      overrides: [fabricaTransporteProvider.overrideWithValue(fabrica)],
      abertura: plataforma,
      preferenciasConexao: PreferenciasConexaoEmMemoria(ligado),
      acessoEntradaMac: () async => acessoMac);
}

void _naTelaDeConectarSemErro(WidgetTester tester) {
  expect(find.byKey(const ValueKey('botao-conectar')), findsOneWidget);
  expect(find.text(textosPt.conectarPeloUsb), findsOneWidget, reason: 'o botão volta ao rótulo de sempre');
  expect(find.byKey(const ValueKey('aviso-conexao')), findsNothing, reason: 'não achar ao abrir não é erro');
  expect(find.text(textosPt.estadoFalha), findsNothing, reason: 'a barra também não acusa falha');
  expect(containerDaTela(tester).read(conexaoProvider), isA<SemConexao>());
}

void main() {
  testWidgets('should_connect_by_itself_and_open_the_editor_without_playing_anything_when_the_pedal_is_plugged',
      (tester) async {
    final fabrica = _Fabrica(_PedaleiraNoCabo.new);

    await _abrirApp(tester, fabrica);

    expect(fabrica.criados, hasLength(1), reason: 'uma tentativa só');
    final conexao = containerDaTela(tester).read(conexaoProvider);
    expect(conexao, isA<Conectada>().having((c) => c.demonstracao, 'demonstração', isFalse));
    expect(find.byKey(const ValueKey('botao-conectar')), findsNothing);
    expect(find.byKey(const ValueKey('slot-01A')), findsOneWidget, reason: 'entrou no editor, com a lista');
    final pedaleira = fabrica.criados.single as _PedaleiraNoCabo;
    expect(pedaleira.comandosRecebidos.map((c) => c.acao), isNot(contains(AcoesAnagram.tocarAoVivo)),
        reason: 'D5: conectar não toca nada');
  });

  testWidgets('should_stay_on_the_connect_screen_without_an_error_when_no_pedal_is_plugged', (tester) async {
    final registro = RegistroCapturado.ligar();
    final fabrica = _Fabrica(_CaboVazio.new);

    await _abrirApp(tester, fabrica);

    expect(fabrica.criados, hasLength(1));
    _naTelaDeConectarSemErro(tester);
    expect(registro.linhas.where((l) => l.contains('[I]') && l.contains('Nenhuma Anagram no USB')), isNotEmpty,
        reason: 'o motivo vai para o registro, como informação');
    expect(registro.linhas.where((l) => l.contains('[E]')), isEmpty);

    // o clique manual continua como antes: falhou, a tela diz
    await tester.tap(find.byKey(const ValueKey('botao-conectar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('aviso-conexao')), findsOneWidget);
    expect(fabrica.criados, hasLength(2));
  });

  testWidgets('should_say_it_is_looking_for_the_pedal_and_give_up_quietly_when_the_handshake_times_out',
      (tester) async {
    final registro = RegistroCapturado.ligar();
    final fabrica = _Fabrica(_PedaleiraMuda.new);

    // sem pumpAndSettle: ele atravessaria a espera inteira
    await tester.pumpWidget(appDeTeste(
        overrides: [fabricaTransporteProvider.overrideWithValue(fabrica)],
        abertura: PlataformaDeAbertura.computador,
        preferenciasConexao: PreferenciasConexaoEmMemoria()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(textosPt.caProcurando), findsNWidgets(2),
        reason: 'a barra e o botão dizem o que está acontecendo');
    expect(find.byKey(const ValueKey('botao-cancelar-conexao')), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    _naTelaDeConectarSemErro(tester);
    expect(fabrica.criados, hasLength(1), reason: 'sem laço de reconexão');
    expect(registro.linhas.where((l) => l.contains('[I]') && l.contains('fetch_firmware_version')), isNotEmpty);
    expect(registro.linhas.where((l) => l.contains('[E]')), isEmpty, reason: 'não achar ao abrir não é erro');
  });

  testWidgets('should_not_try_when_connect_on_launch_is_off', (tester) async {
    final fabrica = _Fabrica(_PedaleiraNoCabo.new);

    await _abrirApp(tester, fabrica, ligado: false);

    expect(fabrica.criados, isEmpty);
    _naTelaDeConectarSemErro(tester);
  });

  testWidgets('should_not_try_on_a_mac_without_input_monitoring_and_try_once_it_is_granted', (tester) async {
    for (final acesso in [AcessoEntrada.naoDecidido, AcessoEntrada.negado, AcessoEntrada.desconhecido]) {
      final fabrica = _Fabrica(_PedaleiraNoCabo.new);
      await _abrirApp(tester, fabrica, plataforma: PlataformaDeAbertura.macOS, acessoMac: acesso);
      expect(fabrica.criados, isEmpty, reason: 'Monitoramento de Entrada ${acesso.name}: espera o clique');
      _naTelaDeConectarSemErro(tester);
      await tester.pumpWidget(const SizedBox());
    }

    final fabrica = _Fabrica(_PedaleiraNoCabo.new);
    await _abrirApp(tester, fabrica, plataforma: PlataformaDeAbertura.macOS);
    expect(containerDaTela(tester).read(conexaoProvider), isA<Conectada>());
  });

  testWidgets('should_not_try_on_phone_or_web', (tester) async {
    final fabrica = _Fabrica(_PedaleiraNoCabo.new);

    await _abrirApp(tester, fabrica, plataforma: PlataformaDeAbertura.semTentativa);

    expect(fabrica.criados, isEmpty);
  });

  testWidgets('should_keep_the_switch_in_the_preferences', (tester) async {
    final preferencias = PreferenciasConexaoEmMemoria();
    await montarApp(tester,
        overrides: [fabricaTransporteProvider.overrideWithValue(_Fabrica(_CaboVazio.new))],
        abertura: PlataformaDeAbertura.computador,
        preferenciasConexao: preferencias);
    await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
    await tester.pumpAndSettle();

    final interruptor = find.byKey(const ValueKey('conectar-ao-abrir'));
    await tester.ensureVisible(interruptor);
    expect(tester.widget<SwitchListTile>(interruptor).value, isTrue, reason: 'ligado por padrão');
    await tester.tap(interruptor);
    await tester.pumpAndSettle();

    expect(preferencias.ligado, isFalse);
  });
}

