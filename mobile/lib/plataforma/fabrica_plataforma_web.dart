// Navegador: WebHID (Chrome, Edge e Opera no desktop). Safari e Firefox não
// têm WebHID.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../nucleo/protocolo/transporte_anagram.dart';
import '../nucleo/midi/saida_midi.dart';
import 'fabrica_transporte.dart';
import 'saida_midi_web.dart';
import 'transporte_webhid.dart';

FabricaTransporte criarFabrica() => const _FabricaWeb();

class _FabricaWeb implements FabricaTransporte {
  const _FabricaWeb();

  @override
  SuporteAparelho get suporte {
    final navegador = globalContext.getProperty<JSObject>('navigator'.toJS);
    return navegador.has('hid')
        ? const AparelhoDisponivel('WebHID')
        : const AparelhoIndisponivel(
            'Este navegador não tem WebHID. Use Chrome ou Edge no computador, ou o modo demonstração.');
  }

  @override
  TransporteAnagram criarAparelho() => TransporteWebHid();

  @override
  SaidaMidiAnagram? criarMidi() => SaidaMidiWeb();
}
