package com.nexttag.anagramapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var canalHid: CanalHidAndroid? = null
    private var canalMidi: CanalMidiAndroid? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        canalHid = CanalHidAndroid(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        canalMidi = CanalMidiAndroid(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        canalHid?.liberar()
        canalMidi?.fechar()
        super.onDestroy()
    }
}
