// A pedaleira simulada fazendo o papel da que está no cabo USB: a barra e o
// editor se comportam como com o aparelho de verdade (não como demonstração).
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

class _PedaleiraNoCabo extends TransporteDemonstracao {
  _PedaleiraNoCabo() : super(presets: lerPresetsDemonstracao(), firmware: 'v1.18.1.23');

  @override
  String get descricao => 'USB (hidapi)';
}

class _FabricaNoCabo implements FabricaTransporte {
  const _FabricaNoCabo();

  @override
  SuporteAparelho get suporte => const AparelhoDisponivel('USB (hidapi)');
  @override
  TransporteAnagram criarAparelho() => _PedaleiraNoCabo();
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

/// Sobreposição para o app achar uma Anagram no USB.
final Override pedaleiraNoCabo = fabricaTransporteProvider.overrideWithValue(const _FabricaNoCabo());

/// Toca em "Conectar" num app montado com [pedaleiraNoCabo].
Future<void> conectarPeloCabo(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-conectar')));
  await tester.pumpAndSettle();
}
