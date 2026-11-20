import FlutterMacOS
import IOKit.hid

/// Interface HID de fornecedor da Anagram via IOKit. Só move relatórios de
/// 64 bytes; enquadramento e JSON ficam no Dart.
///
/// O IOHIDDeviceSetReport é síncrono e um preset são dezenas de relatórios:
/// na thread principal isso travaria a interface durante o arraste de um knob.
/// Os envios vão para uma fila serial própria (na ordem em que chegam) e a
/// resposta ao Flutter volta para a principal. Fechar passa pela mesma fila,
/// para nunca fechar o aparelho no meio de um envio.
final class CanalHidAnagram: NSObject, FlutterStreamHandler {
  private static let tamanhoRelatorio = 64
  private static let paginasFornecedor: Set<Int> = [0xFF00, 0xFF]
  private static let fornecedorDarkglass = 0x2FA6
  private static let produtoAnagram = 0x2500

  private let metodos: FlutterMethodChannel
  private let eventos: FlutterEventChannel
  private let filaEnvio = DispatchQueue(label: "anagram_app.hid.envio")
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
      resultado(abrir(fornecedor: argumentos["idFornecedor"] as? Int ?? Self.fornecedorDarkglass,
                      produto: argumentos["idProduto"] as? Int ?? Self.produtoAnagram))
    case "enviar":
      guard let dados = chamada.arguments as? FlutterStandardTypedData else {
        resultado(FlutterError(code: "argumento", message: "Relatório ausente", details: nil))
        return
      }
      enviar([UInt8](dados.data), resultado)
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
    self.gerente = gerente
    // sem conferir, a recusa do sistema aparecia como "Nenhuma Anagram no USB"
    let aberturaGerente = IOHIDManagerOpen(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
    if aberturaGerente == kIOReturnNotPermitted {
      NSLog("anagram_app: IOHIDManagerOpen negado 0x%08x", aberturaGerente)
      return FlutterError(code: "sem_permissao",
                          message: "O macOS negou acesso ao USB (sandbox ou permissão do sistema).", details: nil)
    }
    if aberturaGerente != kIOReturnSuccess {
      NSLog("anagram_app: IOHIDManagerOpen devolveu 0x%08x; segue procurando o aparelho", aberturaGerente)
    }
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
  private func enviar(_ bytes: [UInt8], _ resultado: @escaping FlutterResult) {
    guard let dispositivo = dispositivo, let id = bytes.first else {
      resultado(FlutterError(code: "desconectado", message: "USB fechado.", details: nil))
      return
    }
    let corpo = id == 0 ? Array(bytes.dropFirst()) : bytes
    filaEnvio.async {
      let retorno = corpo.withUnsafeBufferPointer { ponteiro in
        IOHIDDeviceSetReport(dispositivo, kIOHIDReportTypeOutput, CFIndex(id), ponteiro.baseAddress!, ponteiro.count)
      }
      DispatchQueue.main.async { resultado(Self.respostaDoEnvio(retorno)) }
    }
  }

  private static func respostaDoEnvio(_ retorno: IOReturn) -> Any? {
    if retorno == kIOReturnSuccess { return nil }
    NSLog("anagram_app: IOHIDDeviceSetReport falhou 0x%08x", retorno)
    return FlutterError(code: "desconectado", message: String(format: "SetReport 0x%08x", retorno), details: nil)
  }

  private func fechar() {
    let dispositivo = self.dispositivo
    let gerente = self.gerente
    self.dispositivo = nil
    self.gerente = nil
    // espera os envios já enfileirados terminarem antes de fechar o aparelho
    filaEnvio.sync {
      if let dispositivo = dispositivo { IOHIDDeviceClose(dispositivo, IOOptionBits(kIOHIDOptionsTypeNone)) }
      if let gerente = gerente { IOHIDManagerClose(gerente, IOOptionBits(kIOHIDOptionsTypeNone)) }
    }
  }
}
