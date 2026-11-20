// No Windows a troca de slot é Program Change pela winmm: a porta certa é
// achada pelo nome, e a mensagem vai empacotada num DWORD.
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/plataforma/midi_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_pick_the_anagram_port_when_other_midi_outputs_come_first', () {
    final nomes = ['Microsoft GS Wavetable Synth', 'loopMIDI Port', 'Anagram'];

    expect(escolherPortaAnagram(nomes), 2);
  });

  test('should_accept_a_darkglass_named_port_ignoring_case_when_the_driver_renames_it', () {
    expect(escolherPortaAnagram(['Microsoft GS Wavetable Synth', 'DARKGLASS MIDI 1']), 1);
  });

  test('should_prefer_the_anagram_when_another_darkglass_device_is_plugged_in', () {
    expect(escolherPortaAnagram(['Darkglass Element', 'Anagram']), 1);
  });

  test('should_find_no_port_when_usb_midi_is_off_on_the_pedal', () {
    expect(escolherPortaAnagram(['Microsoft GS Wavetable Synth']), isNull);
  });

  test('should_pack_status_in_the_low_byte_and_program_next_when_switching_to_17A', () {
    // 17A = slot 49 = programa 49 (0x31), canal 1 (0xC0)
    final mensagem = MensagensMidi.trocaDePrograma(SlotPreset.doRotulo('17A'));

    expect(empacotarMensagemCurta(mensagem), 0x31C0);
  });

  test('should_refuse_to_pack_when_the_message_does_not_fit_a_short_midi_message', () {
    expect(() => empacotarMensagemCurta(const []), throwsArgumentError);
    expect(() => empacotarMensagemCurta(const [0xF0, 1, 2, 0xF7]), throwsArgumentError);
  });
}
