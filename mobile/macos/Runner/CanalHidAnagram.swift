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
///
/// Abrir e as consultas de permissão também saem da thread principal
/// (DECISOES CA5): sem Monitoramento de Entrada, o IOHIDManagerOpen pode ficar
/// esperando o sistema, e na principal isso deixava o app "pulando no Dock".
/// Uma abertura que termina depois de um fechar (o Dart desistiu pelo prazo)
/// é descartada pela geração.
final class CanalHidAnagram: NSObject, FlutterStreamHandler {
  private static let tamanhoRelatorio = 64
  private static let paginasFornecedor: Set<Int> = [0xFF00, 0xFF]
  private static let fornecedorDarkglass = 0x2FA6
  private static let produtoAnagram = 0x2500

  private let metodos: FlutterMethodChannel
  private let eventos: FlutterEventChannel
  private let filaEnvio = DispatchQueue(label: "anagram_app.hid.envio")
  private let filaAbertura = DispatchQueue(label: "anagram_app.hid.abertura")
  /// Só mexida na thread principal: cada abrir e cada fechar avançam.
  private var geracao = 0
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
      abrir(fornecedor: argumentos["idFornecedor"] as? Int ?? Self.fornecedorDarkglass,
            produto: argumentos["idProduto"] as? Int ?? Self.produtoAnagram, resultado)
    case "enviar":
      guard let dados = chamada.arguments as? FlutterStandardTypedData else {
        resultado(FlutterError(code: "argumento", message: "Relatório ausente", details: nil))
        return
      }
      enviar([UInt8](dados.data), resultado)
    case "fechar":
      fechar()
      resultado(nil)
    case "acessoEntrada":
      Self.foraDaPrincipal(resultado) { Self.acessoEntrada() }
    case "pedirAcessoEntrada":
      Self.foraDaPrincipal(resultado) { Self.pedirAcessoEntrada() }
    default:
      resultado(FlutterMethodNotImplemented)
    }
  }

  /// Roda [trabalho] numa fila de fundo e responde ao Flutter na principal.
  private static func foraDaPrincipal(_ resultado: @escaping FlutterResult, _ trabalho: @escaping () -> Any?) {
    DispatchQueue.global(qos: .userInitiated).async {
      let resposta = trabalho()
      DispatchQueue.main.async { resultado(resposta) }
    }
  }

  /// Monitoramento de Entrada (TCC), consultado sem pedir: o app só tenta
  /// conectar sozinho ao abrir com ele já concedido (DECISOES CA3). Pedir aqui
  /// faria o macOS mostrar o aviso no meio da abertura.
  private static func acessoEntrada() -> String {
    let acesso = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent)
    let texto = acesso == kIOHIDAccessTypeGranted ? "concedido" : acesso == kIOHIDAccessTypeDenied ? "negado" : "nao_decidido"
    NSLog("anagram_app: Monitoramento de Entrada consultado: %@", texto)
    return texto
  }

  /// Só no clique em CONECTAR com a permissão ainda não decidida (DECISOES
  /// CA5): mostra o pedido do sistema antes de abrir o USB.
  private static func pedirAcessoEntrada() -> String {
    NSLog("anagram_app: pedindo Monitoramento de Entrada ao macOS (IOHIDRequestAccess)")
    let concedido = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    NSLog("anagram_app: IOHIDRequestAccess devolveu %@", concedido ? "true" : "false")
    return concedido ? "concedido" : acessoEntrada()
  }

  private enum Abertura {
    case aberta(IOHIDManager, IOHIDDevice)
    case falhou(FlutterError)
  }

  private func abrir(fornecedor: Int, produto: Int, _ resultado: @escaping FlutterResult) {
    fechar()
    let minha = geracao
    NSLog("anagram_app: abrindo o HID fora da thread principal")
    filaAbertura.async { [weak self] in
      let abertura = Self.abrirAparelho(fornecedor: fornecedor, produto: produto)
      DispatchQueue.main.async { self?.concluir(abertura, geracao: minha, resultado) }
    }
  }

  private func concluir(_ abertura: Abertura, geracao minha: Int, _ resultado: @escaping FlutterResult) {
    switch abertura {
    case .falhou(let erro):
      resultado(erro)
    case .aberta(let gerente, let escolhido) where minha != geracao:
      // o Dart já desistiu (prazo ou CANCELAR): não fica com o aparelho
      NSLog("anagram_app: abertura do HID chegou depois de fechar; descartada")
      filaEnvio.async { Self.fecharAparelho(escolhido, gerente) }
      resultado(FlutterError(code: "cancelado", message: "Abertura descartada.", details: nil))
    case .aberta(let gerente, let escolhido):
      self.gerente = gerente
      dispositivo = escolhido
      IOHIDManagerScheduleWithRunLoop(gerente, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
      registrarCallbacks(gerente: gerente, dispositivo: escolhido)
      NSLog("anagram_app: HID aberto")
      resultado(nil)
    }
  }

  /// Fora da principal: pode esperar pelo sistema (TCC) sem travar a janela.
  private static func abrirAparelho(fornecedor: Int, produto: Int) -> Abertura {
    let gerente = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let filtro = [kIOHIDVendorIDKey: fornecedor, kIOHIDProductIDKey: produto] as CFDictionary
    IOHIDManagerSetDeviceMatching(gerente, filtro)
    // sem conferir, a recusa do sistema aparecia como "Nenhuma Anagram no USB"
    let aberturaGerente = IOHIDManagerOpen(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
    if aberturaGerente == kIOReturnNotPermitted {
      NSLog("anagram_app: IOHIDManagerOpen negado 0x%08x", aberturaGerente)
      return .falhou(FlutterError(code: "sem_permissao",
                                  message: "O macOS negou acesso ao USB (sandbox ou permissão do sistema).", details: nil))
    }
    if aberturaGerente != kIOReturnSuccess {
      NSLog("anagram_app: IOHIDManagerOpen devolveu 0x%08x; segue procurando o aparelho", aberturaGerente)
    }
    guard let escolhido = escolherInterface(gerente) else {
      IOHIDManagerClose(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
      return .falhou(FlutterError(code: "nao_encontrado", message: "Nenhuma Anagram no USB.", details: nil))
    }
    let aberto = IOHIDDeviceOpen(escolhido, IOOptionBits(kIOHIDOptionsTypeNone))
    if aberto != kIOReturnSuccess {
      NSLog("anagram_app: IOHIDDeviceOpen falhou 0x%08x", aberto)
      IOHIDManagerClose(gerente, IOOptionBits(kIOHIDOptionsTypeNone))
      let codigo = aberto == kIOReturnNotPermitted ? "sem_permissao" : "ocupado"
      return .falhou(FlutterError(code: codigo, message: String(format: "IOHIDDeviceOpen 0x%08x", aberto), details: nil))
    }
    return .aberta(gerente, escolhido)
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
    geracao += 1
    let dispositivo = self.dispositivo
    let gerente = self.gerente
    self.dispositivo = nil
    self.gerente = nil
    // espera os envios já enfileirados terminarem antes de fechar o aparelho;
    // uma abertura em curso fica na outra fila e não segura a principal
    filaEnvio.sync { Self.fecharAparelho(dispositivo, gerente) }
  }

  private static func fecharAparelho(_ dispositivo: IOHIDDevice?, _ gerente: IOHIDManager?) {
    if let dispositivo = dispositivo { IOHIDDeviceClose(dispositivo, IOOptionBits(kIOHIDOptionsTypeNone)) }
    if let gerente = gerente { IOHIDManagerClose(gerente, IOOptionBits(kIOHIDOptionsTypeNone)) }
  }
}
