import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // "Abrir com" o app ou arrastar para o ícone no Dock (DECISOES BB5): os
  // arquivos vão para o Dart, que os importa como coleções da biblioteca. O
  // FlutterAppDelegate repassa os endereços aos plugins: continua repassando.
  override func application(_ application: NSApplication, open urls: [URL]) {
    super.application(application, open: urls)
    CanalArquivosAbertos.receber(urls.filter { $0.isFileURL }.map { $0.path })
  }
}

/// Entrega ao Dart os arquivos abertos com o app. Os que chegam antes de o
/// Dart ouvir (o app abriu por causa do arquivo) esperam numa fila até o
/// "pronto" dele.
final class CanalArquivosAbertos {
  private static var canal: FlutterMethodChannel?
  private static var pendentes: [String] = []
  private static var dartPronto = false

  static func ligar(mensageiro: FlutterBinaryMessenger) {
    let novo = FlutterMethodChannel(name: "anagram/arquivos_abertos", binaryMessenger: mensageiro)
    novo.setMethodCallHandler { chamada, responder in
      guard chamada.method == "pronto" else {
        responder(FlutterMethodNotImplemented)
        return
      }
      dartPronto = true
      responder(pendentes)
      pendentes = []
    }
    canal = novo
  }

  static func receber(_ caminhos: [String]) {
    guard !caminhos.isEmpty else { return }
    if dartPronto, let canal {
      canal.invokeMethod("abrir", arguments: caminhos)
    } else {
      pendentes.append(contentsOf: caminhos)
    }
  }
}
