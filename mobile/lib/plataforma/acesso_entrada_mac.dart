// Permissão de Monitoramento de Entrada do macOS (DECISOES CA3). Só consulta,
// nunca pede: com a permissão ainda não decidida, abrir o HID ao abrir o app
// disparava o pedido do sistema e o app ficava "pulando no Dock" até a pessoa
// ligar a opção. O lado nativo está em `macos/Runner/CanalHidAnagram.swift`.
import 'package:flutter/services.dart';

import '../nucleo/registro.dart';

enum AcessoEntrada { concedido, negado, naoDecidido, desconhecido }

typedef ConsultaAcessoEntrada = Future<AcessoEntrada> Function();

Future<AcessoEntrada> consultarAcessoEntradaMac() async {
  try {
    final resposta = await const MethodChannel('anagram_app/hid').invokeMethod<String>('acessoEntrada');
    return switch (resposta) {
      'concedido' => AcessoEntrada.concedido,
      'negado' => AcessoEntrada.negado,
      'nao_decidido' => AcessoEntrada.naoDecidido,
      _ => AcessoEntrada.desconhecido,
    };
  } on Object catch (erro) {
    // canal ausente (build antigo do lado nativo): na dúvida, não tenta sozinho
    registro.i('conexão ao abrir: permissão de Monitoramento de Entrada não consultada', error: erro);
    return AcessoEntrada.desconhecido;
  }
}
