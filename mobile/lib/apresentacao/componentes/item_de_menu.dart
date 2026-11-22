// O item de menu com ícone à esquerda: lido de relance, como os menus do
// sistema. Destrutivo (limpar o slot na pedaleira) vai em vermelho de erro.
// Desabilitado, o ícone apaga junto do texto.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

PopupMenuItem<T> itemDeMenu<T>(T valor,
        {required IconData icone, required String rotulo, Key? key, bool ativo = true, bool destrutivo = false}) =>
    PopupMenuItem<T>(
      key: key,
      value: valor,
      enabled: ativo,
      child: LinhaDeMenu(icone: icone, ativo: ativo, destrutivo: destrutivo, child: Text(rotulo, style: _estilo(destrutivo))),
    );

TextStyle? _estilo(bool destrutivo) => destrutivo ? const TextStyle(color: Cores.erro) : null;

/// Ícone + conteúdo do item; também serve aos itens que trazem mais coisas
/// à direita (o que cada controle da pedaleira já move).
class LinhaDeMenu extends StatelessWidget {
  const LinhaDeMenu({super.key, required this.icone, required this.child, this.ativo = true, this.destrutivo = false});

  final IconData icone;
  final Widget child;
  final bool ativo;
  final bool destrutivo;

  @override
  Widget build(BuildContext context) {
    final cor = destrutivo ? Cores.erro : Cores.aluminioClaro;
    return Row(children: [
      Icon(icone, size: Medidas.iconeMenu, color: ativo ? cor : cor.withValues(alpha: Opacidades.itemIndisponivel)),
      const SizedBox(width: Espacos.m),
      Expanded(child: child),
    ]);
  }
}
