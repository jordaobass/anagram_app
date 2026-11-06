// Capturas dos estados da interface (salvar, conectar, erros, avisos, celular,
// tablet, iOS, créditos), com arte própria. Os nomes dos PNGs mantêm o prefixo
// "rodada2-" de quando foram criados.
import 'dart:async';
import 'dart:typed_data';

import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/fabrica_plataforma_io.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/capturas_apoio.dart';

const desktop = Tamanho('desktop', 1440, 900, 1);
const celular = Tamanho('celular-retrato', 390, 844, 2);
const tabletRetrato = Tamanho('tablet-retrato', 820, 1180, 1);

/// Aparelho que existe mas está preso por outro programa (Darkglass Suite aberto).
class _AparelhoOcupado implements TransporteAnagram {
  @override
  String get descricao => 'USB';
  @override
  Duration get pausaSugerida => Duration.zero;
  @override
  bool get aberto => false;
  @override
  Stream<EstadoTransporte> get estados => const Stream.empty();
  @override
  Stream<Uint8List> get relatoriosRecebidos => const Stream.empty();
  @override
  Future<void> abrir() async => throw const ErroInterfaceOcupada('IOHIDDeviceOpen 0xe00002c5');
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

Future<void> foto(String nome) => expectLater(find.byType(MaterialApp), matchesGoldenFile('$pasta/rodada2-$nome.png'));

ProviderContainer container(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));

void main() {
  setUpAll(carregarFontes);

  testWidgets('salvar como: destino escolhido na lista e confirmação', (tester) async {
    await preparar(tester, desktop);
    final c = await abrirSlot(tester, '01C');
    c.read(editorProvider.notifier).alterarParametro('Threshold', -18, arrastando: false);
    await tester.tap(find.byKey(const ValueKey('botao-salvar-como')));
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await foto('01-salvar-como-lista');
    await tester.tap(find.byKey(const ValueKey('slot-02B')));
    await tester.pumpAndSettle();
    await foto('02-salvar-como-confirmar');
  });

  testWidgets('largar edições ao trocar de preset', (tester) async {
    await preparar(tester, desktop);
    final c = await abrirSlot(tester, '01C');
    c.read(editorProvider.notifier).alterarParametro('Threshold', -18, arrastando: false);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slot-02B')));
    await tester.pumpAndSettle();
    await foto('03-largar-edicoes');
  });

  testWidgets('conectando com cancelar', (tester) async {
    await preparar(tester, desktop, overrides: [
      ajusteDemonstracaoProvider.overrideWithValue((p) => p.naoResponder = AcoesAnagram.firmware),
    ]);
    await tester.tap(find.byKey(const ValueKey('botao-demonstracao')));
    await tester.pump(const Duration(milliseconds: 300));
    await foto('04-conectando-cancelar');
    await tester.tap(find.byKey(const ValueKey('botao-cancelar-conexao')));
    await tester.pump();
    expect(container(tester).read(conexaoProvider), isA<SemConexao>(), reason: 'Cancelar responde na hora');
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('erro: outro programa segura a pedaleira', (tester) async {
    await preparar(tester, desktop, overrides: [
      fabricaTransporteProvider.overrideWithValue(const _Fabrica(AparelhoDisponivel('USB (IOKit)'))),
    ]);
    await tester.tap(find.byKey(const ValueKey('botao-conectar')));
    await tester.pumpAndSettle();
    await foto('05-erro-ocupada');
  });

  testWidgets('aviso: pedaleira desconectada', (tester) async {
    await preparar(tester, desktop);
    final c = await abrirSlot(tester, '01C');
    (c.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao).desconectar();
    await tester.pumpAndSettle();
    await foto('06-desconectada');
  });

  testWidgets('ao vivo desligado', (tester) async {
    await preparar(tester, desktop);
    final c = await abrirSlot(tester, '02A');
    unawaited(c.read(editorProvider.notifier).definirAoVivo(false));
    c.read(editorProvider.notifier).alterarParametro('Threshold', -18, arrastando: false);
    await tester.pumpAndSettle();
    await assentarImagens(tester);
    await foto('07-ao-vivo-desligado');
  });

  testWidgets('celular: bloco com muitos parâmetros, sem páginas', (tester) async {
    await preparar(tester, celular);
    final c = await abrirSlot(tester, '02C');
    c.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 2));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const ValueKey('rolagem-editor')), const Offset(0, -700));
    await tester.pumpAndSettle();
    await foto('08-celular-parametros');
  });

  testWidgets('celular: cadeia completa (paralela)', (tester) async {
    await preparar(tester, celular);
    final c = await abrirSlot(tester, '03A');
    c.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(2, 4));
    await tester.pumpAndSettle();
    await foto('09-celular-cadeia');
  });

  testWidgets('slot vazio e preset novo', (tester) async {
    await preparar(tester, desktop);
    await abrirSlot(tester, '03C');
    await foto('10-slot-vazio');
    await tester.tap(find.byKey(const ValueKey('botao-novo-preset')));
    await tester.pumpAndSettle();
    await foto('11-preset-novo');
  });

  testWidgets('tablet retrato', (tester) async {
    await preparar(tester, tabletRetrato);
    final c = await abrirSlot(tester, '02A');
    unawaited(c.read(editorProvider.notifier).escolherCena(3));
    await tester.pumpAndSettle();
    c.read(editorProvider.notifier).selecionarBloco(const PosicaoBloco(1, 3));
    await tester.pumpAndSettle();
    await foto('12-tablet-retrato');
  });

  testWidgets('iOS: conectar indisponível', (tester) async {
    await preparar(tester, celular, overrides: [
      fabricaTransporteProvider.overrideWithValue(const _Fabrica(AparelhoIndisponivel(FabricaIo.motivoIos))),
    ]);
    await foto('13-ios-indisponivel');
  });

  testWidgets('sobre e diagnóstico', (tester) async {
    await preparar(tester, celular);
    await tester.tap(find.byTooltip('Créditos'));
    await tester.pumpAndSettle();
    await foto('14-sobre-diagnostico');
  });

  testWidgets('desfazer depois de segurar o knob', (tester) async {
    await preparar(tester, desktop);
    final c = await abrirSlot(tester, '02A');
    c.read(editorProvider.notifier).alterarParametro('Threshold', -12, arrastando: false);
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('param-Threshold')));
    await tester.pumpAndSettle();
    await foto('15-knob-desfazer');
  });
}
