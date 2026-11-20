// Bancada: roda contra a Anagram REAL plugada no Mac e responde as hipóteses
// marcadas em docs/DECISOES.md (L4, P2, D4, round-trip do formato).
//   flutter test integration_test/bancada_test.dart -d macos
// Só lê e toca ao vivo. A escrita (grava num slot VAZIO, relê e apaga) só roda
// com --dart-define=BANCADA_ESCRITA=1. A troca de slot por MIDI só com
// --dart-define=BANCADA_MIDI=17A: confira no visor da pedaleira qual slot abriu.
import 'dart:convert';

import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:anagram_app/nucleo/registro.dart';
import 'package:anagram_app/plataforma/saida_midi_nativa.dart';
import 'package:anagram_app/plataforma/transporte_canal_nativo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _escrever = bool.fromEnvironment('BANCADA_ESCRITA');
const _slotMidi = String.fromEnvironment('BANCADA_MIDI');
const _pausasMs = [0, 2, 10];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ApiAnagram api;
  late TransporteCanalNativo transporte;
  var pausa = Duration.zero;

  setUpAll(() async {
    transporte = TransporteCanalNativo('USB (IOKit)', pausaSugerida: Duration.zero);
    await transporte.abrir();
    final cliente = ClienteAnagram(transporte, pausaEntreRelatorios: () => pausa);
    cliente.medicoes.listen((m) => registro.i(
        'BANCADA medição ${m.acao}: ${m.duracao.inMilliseconds} ms, ${m.relatoriosEnviados} relatórios, pausa ${m.pausa.inMilliseconds} ms'));
    api = ApiAnagram(cliente);
  });

  tearDownAll(() => transporte.fechar());

  testWidgets('bancada: firmware, lista e leitura sem perder campo', (tester) async {
    registro.i('BANCADA firmware: ${await api.firmware(prazo: const Duration(seconds: 3))}');
    final slots = await api.listarSlots();
    registro.i('BANCADA ${slots.length} presets na lista: '
        '${slots.take(6).map((s) => '${s.slot.rotulo}=${s.nome}').join(', ')}…');
    expect(slots, isNotEmpty);

    for (final resumo in slots.take(5)) {
      final preset = await api.lerPreset(resumo.slot);
      expect(preset, isNotNull, reason: '${resumo.slot.rotulo} está na lista mas não leu');
      final ida = jsonEncode(preset!.paraJson());
      expect(jsonEncode(DocumentoPreset.doJson(jsonDecode(ida) as Map<String, dynamic>).paraJson()), ida);
      registro.i('BANCADA ${resumo.slot.rotulo} "${preset.nome}" leu e preservou ${ida.length} bytes');
    }
  });

  testWidgets('bancada: latência do ao vivo com pausa 0, 2 e 10 ms (L4)', (tester) async {
    final primeiro = (await api.listarSlots()).first;
    final preset = (await api.lerPreset(primeiro.slot))!;
    for (final ms in _pausasMs) {
      pausa = Duration(milliseconds: ms);
      final tempos = <int>[];
      for (var i = 0; i < 3; i++) {
        final relogio = Stopwatch()..start();
        await api.tocarAoVivo(preset);
        tempos.add(relogio.elapsedMilliseconds);
      }
      registro.i('BANCADA ao vivo "${preset.nome}" pausa $ms ms: $tempos ms');
    }
    pausa = Duration.zero;
  });

  testWidgets('bancada: grava num slot vazio, relê igual e apaga (P2)', (tester) async {
    final ocupados = {for (final s in await api.listarSlots()) s.slot.numero};
    final vazio = SlotPreset.todos().lastWhere((s) => !ocupados.contains(s.numero));
    final teste = DocumentoPreset.vazio('BANCADA ${vazio.rotulo}');

    await api.salvar(vazio, teste);
    final relido = await api.lerPreset(vazio);
    registro.i('BANCADA gravou ${vazio.rotulo}, releu "${relido?.nome}"');
    expect(relido?.nome, teste.nome);

    await api.excluir(vazio);
    expect(await api.lerPreset(vazio), isNull, reason: '${vazio.rotulo} devia ter voltado a vazio');
    registro.i('BANCADA apagou ${vazio.rotulo}: slot vazio de novo');
  }, skip: !_escrever);

  testWidgets('bancada: Program Change para o slot pedido (D4)', (tester) async {
    final midi = SaidaMidiNativa();
    await midi.abrir();
    final slot = SlotPreset.doRotulo(_slotMidi);
    await midi.enviar(MensagensMidi.trocaDePrograma(slot));
    await midi.fechar();
    registro.i('BANCADA mandei programa ${slot.numero} para ${slot.rotulo}: confira no visor qual slot abriu');
  }, skip: _slotMidi.isEmpty);
}
