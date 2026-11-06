import Cocoa
import FlutterMacOS
import CoreMIDI
import IOKit.hid

class MainFlutterWindow: NSWindow {
  // mantém o canal vivo enquanto a janela existir
  private var canalHid: CanalHidAnagram?
  private var canalMidi: CanalMidiAnagram?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    canalHid = CanalHidAnagram(mensageiro: flutterViewController.engine.binaryMessenger)
    canalMidi = CanalMidiAnagram(mensageiro: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}

/// Interface HID de fornecedor da Anagram via IOKit. Só move relatórios de
/// 64 bytes; enquadramento e JSON ficam no Dart.
final class CanalHidAnagram: NSObject, FlutterStreamHandler {
  private static let tamanhoRelatorio = 64
  private static let paginasFornecedor: Set<Int> = [0xFF00, 0xFF]

  private let metodos: FlutterMethodChannel
  private let eventos: FlutterEventChannel
  private var emissor: FlutterEventSink?
  private var gerente: IOHIDManager?
  private var dispositivo: IOHIDDevice?
  private let memoriaEntrada = UnsafeMutablePointer<UInt8>.allocate(capacity: tamanhoRelatorio)

  init(mensageiro: FlutterBinaryMessenger) {
    metodos = FlutterMethodChannel(name: "anagram_app/hid", binaryMessenger: mensageiro)
    eventos = FlutterEventChannel(name: "anagram_app/hid/eventos", binaryMessenger: mensageiro)
    super.init()
    metodos.setMethodCallHandler { [weak self] chamada, resultado in self?.tratar(chamada, resultado) }
    eventos.setStreamHandler(self)
  }

  deinit { memoriaEntrada.deallocate() }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    emissor = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    emissor = nil
    return nil
  }

  private func tratar(_ chamada: FlutterMethodCall, _ resultado: @escaping FlutterResult) {
    switch chamada.method {
    case "abrir":
      let argumentos = chamada.arguments as? [String: Any] ?? [:]
      resultado(abrir(fornecedor: argumentos["idFornecedor"] as? Int ?? 0x2FA6,
                      produto: argumentos["idProduto"] as? Int ?? 0x2500))
    case "enviar":
      guard let dados = chamada.arguments as? FlutterStandardTypedData else {
        resultado(FlutterError(code: "argumento", message: "Relatório ausente", details: nil))
        return
      }
      resultado(enviar([UInt8](dados.data)))
    case "fechar":
      fechar()
      resultado(nil)
    default:
      resultado(FlutterMethodNotImplemented)
    }
  }

  private func abrir(fornecedor: Int, produto: Int) -> Any? {
    fechar()
    let gerente = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let filtro = [kIOHIDVendorIDKey: fornecedor, kIOHIDProductIDKey: produto] as CFDictionary
    IOHIDManagerSetDeviceMatching(gerente, filtro)
    IOHIDManagerScheduleWithRunLoop(gerente, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDManagerOpen(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
    self.gerente = gerente
    guard let escolhido = Self.escolherInterface(gerente) else {
      return FlutterError(code: "nao_encontrado", message: "Nenhuma Anagram no USB.", details: nil)
    }
    let aberto = IOHIDDeviceOpen(escolhido, IOOptionBits(kIOHIDOptionsTypeNone))
    if aberto != kIOReturnSuccess {
      NSLog("anagram_app: IOHIDDeviceOpen falhou 0x%08x", aberto)
      let codigo = aberto == kIOReturnNotPermitted ? "sem_permissao" : "ocupado"
      return FlutterError(code: codigo, message: String(format: "IOHIDDeviceOpen 0x%08x", aberto), details: nil)
    }
    dispositivo = escolhido
    registrarCallbacks(gerente: gerente, dispositivo: escolhido)
    return nil
  }

  /// Interface de fornecedor (usage page 0xFF00) primeiro; senão a primeira.
  private static func escolherInterface(_ gerente: IOHIDManager) -> IOHIDDevice? {
    guard let conjunto = IOHIDManagerCopyDevices(gerente) as? Set<IOHIDDevice>, !conjunto.isEmpty else { return nil }
    let fornecedor = conjunto.first { dispositivo in
      let pagina = IOHIDDeviceGetProperty(dispositivo, kIOHIDPrimaryUsagePageKey as CFString) as? Int ?? 0
      return paginasFornecedor.contains(pagina)
    }
    return fornecedor ?? conjunto.first
  }

  private func registrarCallbacks(gerente: IOHIDManager, dispositivo: IOHIDDevice) {
    let contexto = Unmanaged.passUnretained(self).toOpaque()
    IOHIDDeviceScheduleWithRunLoop(dispositivo, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDDeviceRegisterInputReportCallback(dispositivo, memoriaEntrada, Self.tamanhoRelatorio, { contexto, _, _, _, _, relatorio, tamanho in
      guard let contexto = contexto else { return }
      let canal = Unmanaged<CanalHidAnagram>.fromOpaque(contexto).takeUnretainedValue()
      canal.emissor?(FlutterStandardTypedData(bytes: Data(bytes: relatorio, count: tamanho)))
    }, contexto)
    IOHIDManagerRegisterDeviceRemovalCallback(gerente, { contexto, _, _, removido in
      guard let contexto = contexto else { return }
      let canal = Unmanaged<CanalHidAnagram>.fromOpaque(contexto).takeUnretainedValue()
      if canal.dispositivo == removido {
        canal.dispositivo = nil
        canal.emissor?("perdido")
      }
    }, contexto)
  }

  /// Como a hidapi: com id de relatório ≠ 0, o buffer vai inteiro (id incluso).
  private func enviar(_ bytes: [UInt8]) -> Any? {
    guard let dispositivo = dispositivo, let id = bytes.first else {
      return FlutterError(code: "desconectado", message: "USB fechado.", details: nil)
    }
    let corpo = id == 0 ? Array(bytes.dropFirst()) : bytes
    let resultado = corpo.withUnsafeBufferPointer { ponteiro in
      IOHIDDeviceSetReport(dispositivo, kIOHIDReportTypeOutput, CFIndex(id), ponteiro.baseAddress!, ponteiro.count)
    }
    if resultado != kIOReturnSuccess {
      NSLog("anagram_app: IOHIDDeviceSetReport falhou 0x%08x", resultado)
      return FlutterError(code: "desconectado", message: String(format: "SetReport 0x%08x", resultado), details: nil)
    }
    return nil
  }

  private func fechar() {
    if let dispositivo = dispositivo {
      IOHIDDeviceClose(dispositivo, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    if let gerente = gerente {
      IOHIDManagerClose(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
    }
    dispositivo = nil
    gerente = nil
  }
}

/// USB MIDI da Anagram via CoreMIDI: só Program Change (trocar de slot).
/// A mesma classe existe no app de macOS e no de iOS (alvos separados).
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
