package com.nexttag.anagramapp

import android.content.Context
import android.media.midi.MidiDevice
import android.media.midi.MidiDeviceInfo
import android.media.midi.MidiInputPort
import android.media.midi.MidiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** USB MIDI da Anagram (android.media.midi): só Program Change para trocar de slot. */
class CanalMidiAndroid(contexto: Context, mensageiro: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val gerente: MidiManager? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) contexto.getSystemService(Context.MIDI_SERVICE) as MidiManager? else null
    private val principal = Handler(Looper.getMainLooper())
    private var dispositivo: MidiDevice? = null
    private var porta: MidiInputPort? = null

    init {
        MethodChannel(mensageiro, "anagram_app/midi").setMethodCallHandler(this)
    }

    override fun onMethodCall(chamada: MethodCall, resultado: MethodChannel.Result) {
        when (chamada.method) {
            "abrir" -> abrir(chamada.argument<String>("nome") ?: "Anagram", resultado)
            "enviar" -> enviar(chamada.arguments as ByteArray, resultado)
            "fechar" -> { fechar(); resultado.success(null) }
            else -> resultado.notImplemented()
        }
    }

    @Suppress("DEPRECATION")
    private fun abrir(nome: String, resultado: MethodChannel.Result) {
        // reabrir sem fechar vazaria a porta anterior (e a pedaleira só aceita um dono)
        fechar()
        val midi = gerente
        if (midi == null) {
            resultado.error("sem_midi", "Este Android não tem MIDI.", null)
            return
        }
        val info = midi.devices.firstOrNull {
            (it.properties.getString(MidiDeviceInfo.PROPERTY_NAME) ?: "").contains(nome, ignoreCase = true) &&
                it.inputPortCount > 0
        }
        if (info == null) {
            resultado.error("nao_encontrado", "Nenhuma saída MIDI '$nome'.", null)
            return
        }
        midi.openDevice(info, { aberto ->
            if (aberto == null) {
                resultado.error("ocupado", "Não abriu o MIDI da pedaleira.", null)
            } else {
                dispositivo = aberto
                porta = aberto.openInputPort(0)
                resultado.success(null)
            }
        }, principal)
    }

    private fun enviar(bytes: ByteArray, resultado: MethodChannel.Result) {
        val destino = porta
        if (destino == null) {
            resultado.error("desconectado", "MIDI fechado.", null)
            return
        }
        // send declara IOException (cabo arrancado): o MethodChannel só segura
        // RuntimeException, e a IOException solta derrubaria o app
        runCatching { destino.send(bytes, 0, bytes.size) }
            .onSuccess { resultado.success(null) }
            .onFailure { resultado.error("desconectado", "Falha ao enviar MIDI: ${it.message}", null) }
    }

    fun fechar() {
        runCatching { porta?.close() }
        runCatching { dispositivo?.close() }
        porta = null
        dispositivo = null
    }
}
