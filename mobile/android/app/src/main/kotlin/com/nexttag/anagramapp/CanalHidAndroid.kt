package com.nexttag.anagramapp

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Interface HID de controle da Anagram pelo USB Host do Android.
 * Só move relatórios de 64 bytes; o protocolo fica no Dart.
 */
class CanalHidAndroid(private val contexto: Context, mensageiro: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val ACAO_PERMISSAO = "com.nexttag.anagramapp.PERMISSAO_USB"
        private const val TAMANHO = 64
        private const val PRAZO_MS = 1000
        private const val ETIQUETA = "anagram_app"
    }

    private val gerenciador = contexto.getSystemService(Context.USB_SERVICE) as UsbManager
    private val principal = Handler(Looper.getMainLooper())
    private val metodos = MethodChannel(mensageiro, "anagram_app/hid")
    private val eventos = EventChannel(mensageiro, "anagram_app/hid/eventos")
    private var emissor: EventChannel.EventSink? = null
    private var conexao: UsbDeviceConnection? = null
    private var interfaceHid: UsbInterface? = null
    private var entrada: UsbEndpoint? = null
    private var saida: UsbEndpoint? = null
    private var dispositivo: UsbDevice? = null
    @Volatile private var lendo = false

    private val vigiaRemocao = object : BroadcastReceiver() {
        override fun onReceive(c: Context, intent: Intent) {
            val removido = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
            if (removido != null && removido.deviceName == dispositivo?.deviceName) {
                fechar()
                principal.post { emissor?.success("perdido") }
            }
        }
    }

    init {
        metodos.setMethodCallHandler(this)
        eventos.setStreamHandler(this)
        registrar(vigiaRemocao, IntentFilter(UsbManager.ACTION_USB_DEVICE_DETACHED))
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { emissor = events }

    override fun onCancel(arguments: Any?) { emissor = null }

    override fun onMethodCall(chamada: MethodCall, resultado: MethodChannel.Result) {
        when (chamada.method) {
            "abrir" -> abrir(
                chamada.argument<Int>("idFornecedor") ?: 0x2FA6,
                chamada.argument<Int>("idProduto") ?: 0x2500,
                resultado,
            )
            "enviar" -> enviar(chamada.arguments as ByteArray, resultado)
            "fechar" -> { fechar(); resultado.success(null) }
            else -> resultado.notImplemented()
        }
    }

    private fun abrir(fornecedor: Int, produto: Int, resultado: MethodChannel.Result) {
        fechar()
        val alvo = gerenciador.deviceList.values.firstOrNull { it.vendorId == fornecedor && it.productId == produto }
        if (alvo == null) {
            resultado.error("nao_encontrado", "Nenhuma Anagram no USB.", null)
            return
        }
        if (gerenciador.hasPermission(alvo)) conectar(alvo, resultado) else pedirPermissao(alvo, resultado)
    }

    private fun pedirPermissao(alvo: UsbDevice, resultado: MethodChannel.Result) {
        val receptor = object : BroadcastReceiver() {
            override fun onReceive(c: Context, intent: Intent) {
                contexto.unregisterReceiver(this)
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    conectar(alvo, resultado)
                } else {
                    resultado.error("sem_permissao", "Permissão USB negada.", null)
                }
            }
        }
        registrar(receptor, IntentFilter(ACAO_PERMISSAO))
        val intencao = Intent(ACAO_PERMISSAO).setPackage(contexto.packageName)
        val bandeiras = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
        gerenciador.requestPermission(alvo, PendingIntent.getBroadcast(contexto, 0, intencao, bandeiras))
    }

    /** A interface de controle é a HID que tem endpoint de saída (as outras só leem). */
    private fun conectar(alvo: UsbDevice, resultado: MethodChannel.Result) {
        val interfaces = (0 until alvo.interfaceCount).map { alvo.getInterface(it) }
            .filter { it.interfaceClass == UsbConstants.USB_CLASS_HID }
        val escolhida = interfaces.firstOrNull { endpoint(it, UsbConstants.USB_DIR_OUT) != null } ?: interfaces.firstOrNull()
        val aberta = gerenciador.openDevice(alvo)
        if (escolhida == null || aberta == null || !aberta.claimInterface(escolhida, true)) {
            aberta?.close()
            resultado.error("ocupado", "A interface de controle não abriu.", null)
            return
        }
        dispositivo = alvo
        conexao = aberta
        interfaceHid = escolhida
        entrada = endpoint(escolhida, UsbConstants.USB_DIR_IN)
        saida = endpoint(escolhida, UsbConstants.USB_DIR_OUT)
        iniciarLeitura()
        resultado.success(null)
    }

    private fun endpoint(intf: UsbInterface, direcao: Int): UsbEndpoint? =
        (0 until intf.endpointCount).map { intf.getEndpoint(it) }
            .firstOrNull { it.type == UsbConstants.USB_ENDPOINT_XFER_INT && it.direction == direcao }

    private fun iniciarLeitura() {
        val conexaoAtual = conexao ?: return
        val endpointEntrada = entrada ?: return
        lendo = true
        Thread {
            val memoria = ByteArray(TAMANHO)
            while (lendo) {
                val lidos = conexaoAtual.bulkTransfer(endpointEntrada, memoria, TAMANHO, 200)
                if (lidos > 0) {
                    val copia = memoria.copyOf(lidos)
                    principal.post { emissor?.success(copia) }
                }
            }
        }.apply { name = "anagram-hid-leitura"; isDaemon = true }.start()
    }

    /** Sem endpoint de saída, vai por SET_REPORT no controle (id no byte 0). */
    private fun enviar(bytes: ByteArray, resultado: MethodChannel.Result) {
        val conexaoAtual = conexao
        if (conexaoAtual == null) {
            resultado.error("desconectado", "USB fechado.", null)
            return
        }
        val endpointSaida = saida
        val enviados = if (endpointSaida != null) {
            conexaoAtual.bulkTransfer(endpointSaida, bytes, bytes.size, PRAZO_MS)
        } else {
            val valor = (0x02 shl 8) or (bytes[0].toInt() and 0xFF)
            conexaoAtual.controlTransfer(0x21, 0x09, valor, interfaceHid?.id ?: 0, bytes, bytes.size, PRAZO_MS)
        }
        if (enviados < 0) {
            Log.e(ETIQUETA, "falha de escrita USB ($enviados)")
            resultado.error("desconectado", "Falha de escrita no USB.", null)
        } else {
            resultado.success(null)
        }
    }

    private fun fechar() {
        lendo = false
        interfaceHid?.let { conexao?.releaseInterface(it) }
        conexao?.close()
        conexao = null
        interfaceHid = null
        entrada = null
        saida = null
        dispositivo = null
    }

    fun liberar() {
        fechar()
        runCatching { contexto.unregisterReceiver(vigiaRemocao) }
    }

    private fun registrar(receptor: BroadcastReceiver, filtro: IntentFilter) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            contexto.registerReceiver(receptor, filtro, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            contexto.registerReceiver(receptor, filtro)
        }
    }
}
