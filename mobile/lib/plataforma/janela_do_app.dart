// Traz a janela do app para a frente (DECISOES IA8). O pedido de gravação da
// IA é um diálogo no app, mas quem conversa com a IA está noutra janela (o
// cliente do MCP): sem isto, o diálogo esperava escondido atrás dela e o
// `save_preset` vencia sem ninguém ver. Só o macOS tem o canal; no resto não
// faz nada.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../nucleo/registro.dart';

class JanelaDoApp {
  const JanelaDoApp({this.canal});

  /// Sem janela para chamar (web, celular, testes).
  const JanelaDoApp.nenhuma() : canal = null;

  factory JanelaDoApp.daPlataforma() => JanelaDoApp(
    canal: !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS ? const MethodChannel('anagram/janela') : null,
  );

  final MethodChannel? canal;

  /// Mostra a janela na frente e pede atenção (o ícone pula no Dock até a
  /// pessoa vir). Falhar aqui não impede o diálogo: só registra.
  Future<void> pedirAtencao() async {
    final canal = this.canal;
    if (canal == null) return;
    try {
      await canal.invokeMethod<void>('pedirAtencao');
    } on Exception catch (erro) {
      registro.w('janela: o sistema não trouxe o app para a frente', error: erro);
    }
  }
}
