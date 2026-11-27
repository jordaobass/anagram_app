import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // mantém os canais vivos enquanto a janela existir
  private var canalHid: CanalHidAnagram?
  private var canalMidi: CanalMidiAnagram?
  private var canalJanela: CanalJanela?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    // menor área útil: a mesma de Medidas.larguraMinimaJanela/alturaMinimaJanela
    // (lib/apresentacao/tema/tokens.dart); abaixo disto a barra e o EQ estouram
    self.contentMinSize = NSSize(width: 480, height: 480)

    RegisterGeneratedPlugins(registry: flutterViewController)
    canalHid = CanalHidAnagram(mensageiro: flutterViewController.engine.binaryMessenger)
    canalMidi = CanalMidiAnagram(mensageiro: flutterViewController.engine.binaryMessenger)
    canalJanela = CanalJanela(mensageiro: flutterViewController.engine.binaryMessenger, janela: self)

    super.awakeFromNib()
  }
}

/// Traz a janela para a frente quando a IA pede para gravar (DECISOES IA8):
/// o diálogo de confirmação só vale se a pessoa o vir, e ela está conversando
/// com a IA noutra janela.
final class CanalJanela {
  private let canal: FlutterMethodChannel

  init(mensageiro: FlutterBinaryMessenger, janela: NSWindow) {
    canal = FlutterMethodChannel(name: "anagram/janela", binaryMessenger: mensageiro)
    canal.setMethodCallHandler { [weak janela] chamada, responder in
      guard chamada.method == "pedirAtencao" else {
        responder(FlutterMethodNotImplemented)
        return
      }
      if let janela {
        if janela.isMiniaturized { janela.deminiaturize(nil) }
        janela.orderFrontRegardless()
        janela.makeKey()
      }
      NSApp.activate(ignoringOtherApps: true)
      // pula no Dock até a pessoa vir, se o sistema não deixou tomar a frente
      NSApp.requestUserAttention(.criticalRequest)
      responder(nil)
    }
  }
}
