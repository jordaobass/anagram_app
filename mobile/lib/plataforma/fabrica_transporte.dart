// Escolhe o transporte do aparelho conforme a plataforma. A implementação
// de cada uma fica atrás de import condicional, para o web não puxar
// dart:ffi e o desktop não puxar WebHID.
import '../nucleo/midi/saida_midi.dart';
import '../nucleo/protocolo/transporte_anagram.dart';
import 'fabrica_plataforma_io.dart' if (dart.library.js_interop) 'fabrica_plataforma_web.dart'
    as plataforma;

/// O que esta plataforma consegue fazer com a pedaleira.
sealed class SuporteAparelho {
  const SuporteAparelho();
}

final class AparelhoDisponivel extends SuporteAparelho {
  const AparelhoDisponivel(this.meio);

  /// Ex.: "USB (IOKit)", "WebHID".
  final String meio;
}

final class AparelhoIndisponivel extends SuporteAparelho {
  const AparelhoIndisponivel(this.motivo);
  final String motivo;
}

abstract interface class FabricaTransporte {
  SuporteAparelho get suporte;
  TransporteAnagram criarAparelho();

  /// USB MIDI da pedaleira, onde a plataforma tem; `null` onde não tem.
  SaidaMidiAnagram? criarMidi();
}

FabricaTransporte criarFabricaDaPlataforma() => plataforma.criarFabrica();
