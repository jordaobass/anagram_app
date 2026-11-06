package com.nexttag.anagramapp

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
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Interface HID de controle da Anagram pelo USB Host do Android.
 * Só move relatórios de 64 bytes; o protocolo fica no Dart.
 *
 * Toda operação de USB (abrir, enviar, fechar) roda numa fila serial própria:
 * um preset são dezenas de relatórios com prazo de até 1 s cada, e na thread
 * principal isso travaria toque e quadros durante o arraste de um knob. O
 * estado da conexão só é lido e escrito nessa fila; as respostas ao Flutter
 * voltam para a thread principal, como o MethodChannel exige.
 */
class CanalHidAndroid(private val contexto: Context, mensageiro: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val ACAO_PERMISSAO = "com.nexttag.anagramapp.PERMISSAO_USB"
        private const val PRAZO_MS = 1000
        private const val ETIQUETA = "anagram_app"
        private const val FORNECEDOR_DARKGLASS = 0x2FA6
        private const val PRODUTO_ANAGRAM = 0x2500

        // SET_REPORT pelo endpoint de controle (HID 1.11, seção 7.2.2)
        private const val REQUISICAO_CLASSE_PARA_INTERFACE = 0x21
        private const val HID_SET_REPORT = 0x09
        private const val TIPO_RELATORIO_SAIDA = 0x02
    }

    private val gerenciador = contexto.getSystemService(Context.USB_SERVICE) as UsbManager
    private val principal = Handler(Looper.getMainLooper())
    private val usb: ExecutorService = Executors.newSingleThreadExecutor { tarefa ->
        Thread(tarefa, "anagram-hid-usb").apply { isDaemon = true }
    }
    private val permissao = PedidoPermissaoUsb(contexto, ACAO_PERMISSAO, ::registrar)
    private val metodos = MethodChannel(mensageiro, "anagram_app/hid")
    private val eventos = EventChannel(mensageiro, "anagram_app/hid/eventos")
    private var emissor: EventChannel.EventSink? = null

    // só na fila `usb`
    private var conexao: UsbDeviceConnection? = null
    private var interfaceHid: UsbInterface? = null
    private var saida: UsbEndpoint? = null
    private var dispositivo: UsbDevice? = null
    private var leitura: LeituraHid? = null

    private val vigiaRemocao = object : BroadcastReceiver() {
        override fun onReceive(c: Context, intent: Intent) {
            val removido = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE) ?: return
            usb.execute { if (removido.deviceName == dispositivo?.deviceName) perder() }
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
        val resposta = RespostaNaPrincipal(resultado, principal)
        when (chamada.method) {
            "abrir" -> {
                val fornecedor = chamada.argument<Int>("idFornecedor") ?: FORNECEDOR_DARKGLASS
                val produto = chamada.argument<Int>("idProduto") ?: PRODUTO_ANAGRAM
                usb.execute { abrir(fornecedor, produto, resposta) }
            }
            "enviar" -> {
                val bytes = chamada.arguments as ByteArray
                usb.execute { enviar(bytes, resposta) }
            }
            "fechar" -> usb.execute { fechar(); resposta.sucesso() }
            else -> resultado.notImplemented()
        }
    }

    private fun abrir(fornecedor: Int, produto: Int, resposta: RespostaNaPrincipal) {
        fechar()
        val alvo = gerenciador.deviceList.values.firstOrNull { it.vendorId == fornecedor && it.productId == produto }
        when {
            alvo == null -> resposta.erro("nao_encontrado", "Nenhuma Anagram no USB.")
            gerenciador.hasPermission(alvo) -> conectar(alvo, resposta)
            else -> principal.post {
                permissao.pedir(alvo, gerenciador, aoConceder = { usb.execute { conectar(alvo, resposta) } },
                    aoNegar = { codigo, mensagem -> resposta.erro(codigo, mensagem) })
            }
        }
    }

    /** A interface de controle é a HID que tem endpoint de saída (as outras só leem). */
    private fun conectar(alvo: UsbDevice, resposta: RespostaNaPrincipal) {
        fechar()
        val interfaces = (0 until alvo.interfaceCount).map { alvo.getInterface(it) }
            .filter { it.interfaceClass == UsbConstants.USB_CLASS_HID }
        val escolhida = interfaces.firstOrNull { endpoint(it, UsbConstants.USB_DIR_OUT) != null } ?: interfaces.firstOrNull()
        val aberta = gerenciador.openDevice(alvo)
        if (escolhida == null || aberta == null || !aberta.claimInterface(escolhida, true)) {
            aberta?.close()
            resposta.erro("ocupado", "A interface de controle não abriu.")
            return
        }
        dispositivo = alvo
        conexao = aberta
        interfaceHid = escolhida
        saida = endpoint(escolhida, UsbConstants.USB_DIR_OUT)
        endpoint(escolhida, UsbConstants.USB_DIR_IN)?.let { iniciarLeitura(aberta, it) }
        resposta.sucesso()
    }

    private fun endpoint(intf: UsbInterface, direcao: Int): UsbEndpoint? =
        (0 until intf.endpointCount).map { intf.getEndpoint(it) }
            .firstOrNull { it.type == UsbConstants.USB_ENDPOINT_XFER_INT && it.direction == direcao }

    private fun iniciarLeitura(aberta: UsbDeviceConnection, entrada: UsbEndpoint) {
        lateinit var sessao: LeituraHid
        sessao = LeituraHid(aberta, entrada,
            aoReceber = { bytes -> principal.post { emissor?.success(bytes) } },
            aoPerder = { usb.execute { if (leitura === sessao) perder() } })
        leitura = sessao
        sessao.iniciar()
    }

    /** Sem endpoint de saída, vai por SET_REPORT no controle (id no byte 0). */
    private fun enviar(bytes: ByteArray, resposta: RespostaNaPrincipal) {
        val conexaoAtual = conexao
        if (conexaoAtual == null) {
            resposta.erro("desconectado", "USB fechado.")
            return
        }
        val endpointSaida = saida
        val enviados = if (endpointSaida != null) {
            conexaoAtual.bulkTransfer(endpointSaida, bytes, bytes.size, PRAZO_MS)
        } else {
            val valor = (TIPO_RELATORIO_SAIDA shl 8) or (bytes[0].toInt() and 0xFF)
            conexaoAtual.controlTransfer(REQUISICAO_CLASSE_PARA_INTERFACE, HID_SET_REPORT, valor,
                interfaceHid?.id ?: 0, bytes, bytes.size, PRAZO_MS)
        }
        if (enviados < 0) {
            Log.e(ETIQUETA, "falha de escrita USB ($enviados)")
            resposta.erro("desconectado", "Falha de escrita no USB.")
        } else {
            resposta.sucesso()
        }
    }

    private fun perder() {
        fechar()
        principal.post { emissor?.success("perdido") }
    }

    private fun fechar() {
        leitura?.parar()
        leitura = null
        interfaceHid?.let { conexao?.releaseInterface(it) }
        conexao?.close()
        conexao = null
        interfaceHid = null
        saida = null
        dispositivo = null
    }

    fun liberar() {
        permissao.cancelar()
        runCatching { contexto.unregisterReceiver(vigiaRemocao) }
        usb.execute { fechar() }
        usb.shutdown()
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
