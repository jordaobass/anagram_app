// Plataformas com dart:io: macOS e Android por canal nativo, Linux e
// Windows por hidapi (FFI). iPhone/iPad não abrem HID de fornecedor.
import 'dart:io';

import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/midi/saida_midi.dart';
import 'fabrica_transporte.dart';
import 'saida_midi_nativa.dart';
import 'transporte_canal_nativo.dart';
import 'transporte_hidapi.dart';

FabricaTransporte criarFabrica() => const FabricaIo();

class FabricaIo implements FabricaTransporte {
  const FabricaIo();

  static const motivoIos =
      'iPhone e iPad não deixam apps comuns abrirem a interface USB de controle da Anagram: '
      'isso exige um driver DriverKit com permissão especial da Apple, que este app ainda não tem. '
      'Use o modo demonstração aqui, ou edite pelo Mac, PC, Android ou Chrome.';

  @override
  SuporteAparelho get suporte {
    if (Platform.isMacOS) return const AparelhoDisponivel('USB (IOKit)');
    if (Platform.isAndroid) return const AparelhoDisponivel('USB Host');
    if (Platform.isLinux || Platform.isWindows) return const AparelhoDisponivel('USB (hidapi)');
    if (Platform.isIOS) return const AparelhoIndisponivel(motivoIos);
    return const AparelhoIndisponivel('Esta plataforma não tem acesso USB à pedaleira.');
  }

  @override
  SaidaMidiAnagram? criarMidi() =>
      Platform.isMacOS || Platform.isIOS || Platform.isAndroid ? SaidaMidiNativa() : null;

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
