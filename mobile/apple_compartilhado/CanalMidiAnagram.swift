// Compartilhado pelos alvos macOS (macos/Runner) e iOS (ios/Runner): os dois
// projetos Xcode referenciam este mesmo arquivo. Só o módulo do Flutter muda.
import CoreMIDI
#if os(macOS)
import FlutterMacOS
#else
import Flutter
#endif

/// USB MIDI da Anagram via CoreMIDI: só Program Change (trocar de slot).
final class CanalMidiAnagram {
  private let canal: FlutterMethodChannel
  private var cliente = MIDIClientRef()
  private var porta = MIDIPortRef()
  private var destino = MIDIEndpointRef()

  init(mensageiro: FlutterBinaryMessenger) {
    canal = FlutterMethodChannel(name: "anagram_app/midi", binaryMessenger: mensageiro)
    canal.setMethodCallHandler { [weak self] chamada, resultado in self?.tratar(chamada, resultado) }
  }

  private func tratar(_ chamada: FlutterMethodCall, _ resultado: @escaping FlutterResult) {
    switch chamada.method {
    case "abrir":
      let nome = (chamada.arguments as? [String: Any])?["nome"] as? String ?? "Anagram"
      resultado(abrir(nome))
    case "enviar":
      guard let dados = chamada.arguments as? FlutterStandardTypedData else {
        resultado(FlutterError(code: "argumento", message: "Mensagem ausente", details: nil))
        return
      }
      resultado(enviar([UInt8](dados.data)))
    case "fechar":
      destino = MIDIEndpointRef()
      resultado(nil)
    default:
      resultado(FlutterMethodNotImplemented)
    }
  }

  private func abrir(_ nome: String) -> Any? {
    if cliente == 0 {
      MIDIClientCreate("AnagramApp" as CFString, nil, nil, &cliente)
      MIDIOutputPortCreate(cliente, "saida" as CFString, &porta)
    }
    for indice in 0..<MIDIGetNumberOfDestinations() {
      let candidato = MIDIGetDestination(indice)
      var nomeCF: Unmanaged<CFString>?
      MIDIObjectGetStringProperty(candidato, kMIDIPropertyDisplayName, &nomeCF)
      let exibido = (nomeCF?.takeRetainedValue() as String?) ?? ""
      if exibido.localizedCaseInsensitiveContains(nome) {
        destino = candidato
        NSLog("anagram_app: MIDI em '%@'", exibido)
        return nil
      }
    }
    return FlutterError(code: "nao_encontrado", message: "Nenhuma saída MIDI '\(nome)'. Ligue o USB MIDI nos ajustes da pedaleira.", details: nil)
  }

  private func enviar(_ bytes: [UInt8]) -> Any? {
    guard destino != 0 else { return FlutterError(code: "desconectado", message: "MIDI fechado.", details: nil) }
    var lista = MIDIPacketList()
    let pacote = MIDIPacketListInit(&lista)
    let resultado: OSStatus = bytes.withUnsafeBufferPointer { ponteiro in
      MIDIPacketListAdd(&lista, MemoryLayout<MIDIPacketList>.size, pacote, 0, ponteiro.count, ponteiro.baseAddress!)
      return MIDISend(porta, destino, &lista)
    }
    if resultado != noErr {
      return FlutterError(code: "desconectado", message: "MIDISend \(resultado)", details: nil)
    }
    return nil
  }
}
