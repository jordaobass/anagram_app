// Plataformas com dart:io: macOS e Android por canal nativo, Linux e
// Windows por hidapi (FFI). MIDI: canal nativo no macOS/iOS/Android e winmm
// (FFI) no Windows. iPhone/iPad não abrem HID de fornecedor.
import 'dart:io';

import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/midi/saida_midi.dart';
import 'fabrica_transporte.dart';
import 'saida_midi_nativa.dart';
import 'saida_midi_windows.dart';
import 'transporte_canal_nativo.dart';
import 'transporte_hidapi.dart';

FabricaTransporte criarFabrica() => const FabricaIo();

class FabricaIo implements FabricaTransporte {
  const FabricaIo();

  @override
  SuporteAparelho get suporte {
    if (Platform.isMacOS) return const AparelhoDisponivel('USB (IOKit)');
    if (Platform.isAndroid) return const AparelhoDisponivel('USB Host');
    if (Platform.isLinux || Platform.isWindows) return const AparelhoDisponivel('USB (hidapi)');
    if (Platform.isIOS) return const AparelhoIndisponivel(MotivoIndisponivel.ios);
    return const AparelhoIndisponivel(MotivoIndisponivel.semUsb);
  }

  @override
  SaidaMidiAnagram? criarMidi() {
    if (Platform.isMacOS || Platform.isIOS || Platform.isAndroid) return SaidaMidiNativa();
    // Windows fala MIDI pela winmm por FFI; o Linux ainda não tem saída MIDI
    if (Platform.isWindows) return SaidaMidiWindows();
    return null;
  }

  @override
  TransporteAnagram criarAparelho() {
    // IOKit: SetReport síncrono → sem pausa. Android: bulkTransfer com prazo → 10 ms como a referência
    if (Platform.isMacOS) return TransporteCanalNativo('USB (IOKit)', pausaSugerida: Duration.zero);
    if (Platform.isAndroid) {
      return TransporteCanalNativo('USB Host', pausaSugerida: const Duration(milliseconds: 10));
    }
    return TransporteHidapi();
  }
}
