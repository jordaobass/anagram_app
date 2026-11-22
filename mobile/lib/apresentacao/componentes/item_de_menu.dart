// O item de menu com ícone à esquerda: lido de relance, como os menus do
// sistema. Destrutivo (limpar o slot na pedaleira) vai em vermelho de erro.
// Desabilitado, o ícone apaga junto do texto.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

PopupMenuItem<T> itemDeMenu<T>(T valor,
        {required IconData icone, required String rotulo, Key? key, bool ativo = true, bool destrutivo = false}) =>
    PopupMenuItem<T>(
      key: key,
      value: valor,
      enabled: ativo,
      height: alturaItemDeMenu,
      child: LinhaDeMenu(icone: icone, ativo: ativo, destrutivo: destrutivo, child: Text(rotulo, style: _estilo(destrutivo))),
    );

/// Item de escolha única (opção de parâmetro, tipo de drive): o check em
/// âmbar na coluna do ícone. Substitui o CheckedPopupMenuItem, cujo ListTile
/// interno fixava 56px de altura e ignorava a densidade do menu.
PopupMenuItem<T> itemMarcado<T>(T valor, {required String rotulo, required bool marcado, Key? key}) =>
    PopupMenuItem<T>(
      key: key,
      value: valor,
      height: alturaItemDeMenu,
      child: Semantics(
        checked: marcado,
        child: Row(children: [
          SizedBox.square(
              dimension: Medidas.iconeMenu,
              child: marcado ? const Icon(Icons.check, size: Medidas.iconeMenu, color: Cores.tally) : null),
          const SizedBox(width: Espacos.m),
          Expanded(child: Text(rotulo)),
        ]),
      ),
    );

/// Com mouse o item é compacto, como os menus de contexto do Windows e do
/// macOS; no toque (celular, tablet) fica no alvo mínimo de 48dp (DECISOES UI12).
double get alturaItemDeMenu => switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => Medidas.alvoMinimo,
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => Medidas.alturaItemMenuComMouse,
    };

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
