// Ajudantes de navegação sobre o go_router (o app não usa Navigator.push).
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Volta para a tela anterior, se houver: a lista de presets também aparece
/// embutida no editor largo, e ali não há rota para fechar.
void voltarSePuder(BuildContext context) {
  if (context.canPop()) context.pop();
}
