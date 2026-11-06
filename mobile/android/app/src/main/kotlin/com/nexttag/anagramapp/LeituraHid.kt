package com.nexttag.anagramapp

import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.os.SystemClock
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Uma sessão de leitura do endpoint de entrada, na sua própria thread.
 *
 * Cada sessão tem o seu sinal de parada: reconectar cria outra sessão, e a
 * anterior (ainda presa num bulkTransfer) sai sozinha ao voltar, em vez de
 * herdar o "lendo = true" da nova e girar para sempre sobre uma conexão fechada.
 */
class LeituraHid(
    private val conexao: UsbDeviceConnection,
    private val entrada: UsbEndpoint,
    private val aoReceber: (ByteArray) -> Unit,
    private val aoPerder: () -> Unit,
) {
    companion object {
        private const val TAMANHO = 64
        private const val PRAZO_MS = 200

        // bulkTransfer devolve -1 tanto no prazo esgotado quanto com a conexão
        // morta; a diferença é que morta ele volta na hora. Muitas voltas
        // instantâneas seguidas = o aparelho saiu antes do aviso do sistema.
        private const val VOLTA_INSTANTANEA_MS = 20
        private const val VOLTAS_INSTANTANEAS_ATE_PERDER = 50
        private const val PAUSA_APOS_VOLTA_INSTANTANEA_MS = 10L
    }

    private val ativa = AtomicBoolean(true)

    fun iniciar() {
        Thread(::ler).apply { name = "anagram-hid-leitura"; isDaemon = true }.start()
    }

    fun parar() = ativa.set(false)

    private fun ler() {
        val memoria = ByteArray(TAMANHO)
        var instantaneas = 0
        while (ativa.get()) {
            val inicio = SystemClock.elapsedRealtime()
            val lidos = conexao.bulkTransfer(entrada, memoria, TAMANHO, PRAZO_MS)
            if (lidos > 0) {
                instantaneas = 0
                aoReceber(memoria.copyOf(lidos))
            } else if (lidos < 0 && SystemClock.elapsedRealtime() - inicio < VOLTA_INSTANTANEA_MS) {
                instantaneas++
                if (instantaneas >= VOLTAS_INSTANTANEAS_ATE_PERDER) break
                SystemClock.sleep(PAUSA_APOS_VOLTA_INSTANTANEA_MS)
            } else {
                instantaneas = 0
            }
        }
        // saiu por conta própria (não por parar()): a conexão morreu
        if (ativa.getAndSet(false)) aoPerder()
    }
}
