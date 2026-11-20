package com.nexttag.anagramapp

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build

/**
 * O pedido de permissão USB em aberto — no máximo um.
 *
 * Cancelar a conexão no app e tentar de novo pede permissão outra vez antes de
 * a pessoa responder a primeira. Com um receptor por pedido, a resposta única
 * do sistema acordava os dois e abria o aparelho duas vezes, vazando a primeira
 * conexão. Aqui o pedido novo encerra o anterior (que recebe "cancelado").
 * Só é usado na thread principal.
 */
class PedidoPermissaoUsb(
    private val contexto: Context,
    private val acao: String,
    private val registrar: (BroadcastReceiver, IntentFilter) -> Unit,
) {
    private var receptor: BroadcastReceiver? = null
    private var aoNegarPendente: ((String, String) -> Unit)? = null

    fun pedir(
        alvo: UsbDevice,
        gerenciador: UsbManager,
        aoConceder: () -> Unit,
        aoNegar: (codigo: String, mensagem: String) -> Unit,
    ) {
        encerrar()?.invoke("cancelado", "Pedido de permissão USB substituído por um novo.")
        val novo = object : BroadcastReceiver() {
            override fun onReceive(c: Context, intent: Intent) {
                encerrar()
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    aoConceder()
                } else {
                    aoNegar("sem_permissao", "Permissão USB negada.")
                }
            }
        }
        receptor = novo
        aoNegarPendente = aoNegar
        registrar(novo, IntentFilter(acao))
        val intencao = Intent(acao).setPackage(contexto.packageName)
        val bandeiras = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
        gerenciador.requestPermission(alvo, PendingIntent.getBroadcast(contexto, 0, intencao, bandeiras))
    }

    /** Descarta o pedido em aberto sem responder (o app está fechando). */
    fun cancelar() {
        encerrar()
    }

    /** Desregistra o receptor e devolve quem esperava a resposta, se havia alguém. */
    private fun encerrar(): ((String, String) -> Unit)? {
        val anterior = aoNegarPendente
        receptor?.let { runCatching { contexto.unregisterReceiver(it) } }
        receptor = null
        aoNegarPendente = null
        return anterior
    }
}
