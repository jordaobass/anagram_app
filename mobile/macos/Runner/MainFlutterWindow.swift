import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  // mantém os canais vivos enquanto a janela existir
  private var canalHid: CanalHidAnagram?
  private var canalMidi: CanalMidiAnagram?

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

    super.awakeFromNib()
  }
}
