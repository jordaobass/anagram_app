// Permissão de Monitoramento de Entrada do macOS (DECISOES CA3 e CA5). Ao
// abrir o app só consulta, nunca pede: com a permissão ainda não decidida,
// abrir o HID ao abrir o app disparava o pedido do sistema e o app ficava
// "pulando no Dock" até a pessoa ligar a opção. O pedido do sistema só sai
// no clique em CONECTAR. O lado nativo está em `macos/Runner/CanalHidAnagram.swift`.
import 'dart:async';

import 'package:flutter/services.dart';

import '../nucleo/registro.dart';

enum AcessoEntrada { concedido, negado, naoDecidido, desconhecido }

typedef ConsultaAcessoEntrada = Future<AcessoEntrada> Function();

/// Ajustes › Privacidade e Segurança › Monitoramento de Entrada.
final enderecoAjustesMonitoramentoEntrada =
    Uri.parse('x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent');

const _canal = MethodChannel('anagram_app/hid');

/// A consulta é instantânea no sistema; passar disto é o lado nativo preso.
const _prazoConsulta = Duration(seconds: 3);

/// O pedido só mostra o aviso do sistema e volta; a pessoa decide depois.
const _prazoPedido = Duration(seconds: 10);

Future<AcessoEntrada> consultarAcessoEntradaMac() async {
  try {
    return _traduzir(await _canal.invokeMethod<String>('acessoEntrada').timeout(_prazoConsulta));
  } on Object catch (erro) {
    // canal ausente (build antigo do lado nativo) ou preso: na dúvida, não tenta sozinho
    registro.i('Monitoramento de Entrada: permissão não consultada', error: erro);
    return AcessoEntrada.desconhecido;
  }
}

/// Mostra o pedido do sistema (`IOHIDRequestAccess`) e devolve como ficou.
/// Sem resposta, vale como ainda não decidido: o app não abre o USB às cegas.
Future<AcessoEntrada> pedirAcessoEntradaMac() async {
  try {
    final resposta = _traduzir(await _canal.invokeMethod<String>('pedirAcessoEntrada').timeout(_prazoPedido));
    return resposta == AcessoEntrada.desconhecido ? AcessoEntrada.naoDecidido : resposta;
  } on MissingPluginException catch (erro) {
    // build nativo sem o método: segue como antes, o próprio abrir pede ao sistema
    registro.i('Monitoramento de Entrada: pedido indisponível neste build', error: erro);
    return AcessoEntrada.desconhecido;
  } on Object catch (erro) {
    registro.w('Monitoramento de Entrada: o pedido ao sistema não respondeu', error: erro);
    return AcessoEntrada.naoDecidido;
  }
}

AcessoEntrada _traduzir(String? resposta) => switch (resposta) {
      'concedido' => AcessoEntrada.concedido,
      'negado' => AcessoEntrada.negado,
      'nao_decidido' => AcessoEntrada.naoDecidido,
      _ => AcessoEntrada.desconhecido,
    };
