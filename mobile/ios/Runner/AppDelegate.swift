import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // iPhone/iPad não abrem o HID da Anagram, mas USB MIDI (classe padrão) funciona.
  // CanalMidiAnagram vem de apple_compartilhado/, o mesmo arquivo do app de macOS.
  private var canalMidi: CanalMidiAnagram?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CanalMidiAnagram") {
      canalMidi = CanalMidiAnagram(mensageiro: registrar.messenger())
    }
  }
}
