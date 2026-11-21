// O envio ao vivo agendado durante o arraste sai até 100 ms depois: nesse
// meio-tempo a pessoa pode desligar o "Ao vivo", abrir outro preset ou o
// cabo pode sair. Nada disso pode fazer a pedaleira tocar o que já não vale,
// nem acusar erro de uma conexão que já acabou.
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/conexao_demo.dart';

int _enviosAoVivo(TransporteDemonstracao pedaleira) =>
    pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.tocarAoVivo).length;

/// Mais que a janela de 100 ms do envio agendado.
Future<void> _passarDaJanela() => Future<void>.delayed(const Duration(milliseconds: 250));

void main() {
  test('should_not_send_the_scheduled_drag_value_when_live_is_turned_off', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    addTearDown(container.dispose);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final antes = _enviosAoVivo(pedaleira);

    editor.alterarParametro('Threshold', -20, arrastando: true);
    await editor.definirAoVivo(false);
    await _passarDaJanela();

    expect(_enviosAoVivo(pedaleira), antes, reason: 'desligado o "Ao vivo", nada mais vai para a pedaleira');
  });

  test('should_not_play_the_previous_preset_drag_after_another_slot_was_opened', () async {
    final (container, pedaleira) = await conectarDemonstracao();
    addTearDown(container.dispose);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset(3));
    final antes = _enviosAoVivo(pedaleira);

    editor.alterarParametro('Threshold', -20, arrastando: true);
    await editor.abrirSlot(SlotPreset(4));
    final depoisDeAbrir = _enviosAoVivo(pedaleira);
    await _passarDaJanela();

    expect(_enviosAoVivo(pedaleira), depoisDeAbrir,
        reason: 'o arraste do 01C não pode chegar depois de o 02A abrir (de $antes envios)');
    final tocando = pedaleira.presetTocando?['preset']['name'];
    expect(tocando, anyOf(isNull, container.read(editorProvider).atual!.nome));
  });

}
