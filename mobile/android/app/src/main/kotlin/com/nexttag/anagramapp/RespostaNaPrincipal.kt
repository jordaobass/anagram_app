package com.nexttag.anagramapp

import android.os.Handler
import io.flutter.plugin.common.MethodChannel

/**
 * Responde ao Flutter sempre pela thread principal (o MethodChannel exige),
 * de onde quer que o trabalho tenha terminado. Responde uma vez só: a segunda
 * resposta a um mesmo Result derruba o app.
 */
class RespostaNaPrincipal(private val resultado: MethodChannel.Result, private val principal: Handler) {
    private var respondida = false

    fun sucesso() = responder { resultado.success(null) }

    fun erro(codigo: String, mensagem: String) = responder { resultado.error(codigo, mensagem, null) }

    private fun responder(acao: () -> Unit) {
        principal.post {
            if (respondida) return@post
            respondida = true
            acao()
        }
    }
}
