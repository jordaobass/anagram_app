import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/cliente_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

void main() {
  test('should_use_the_transport_suggested_pause_when_the_user_picks_none', () async {
    final (container, _) = await conectarDemonstracao();
    final medicoes = <MedicaoChamada>[];
    container.read(conexaoProvider.notifier).repositorio!.medicoes.listen(medicoes.add);
    final editor = container.read(editorProvider.notifier);

    await editor.abrirSlot(SlotPreset(3));
    expect(medicoes.last.pausa, Duration.zero, reason: 'sugerida pelo transporte');

    container.read(pausaRelatoriosProvider.notifier).definir(const Duration(milliseconds: 2));
    await editor.abrirSlot(SlotPreset(4));
    expect(medicoes.last.pausa, const Duration(milliseconds: 2));
  });
}
