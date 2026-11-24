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
      child: LinhaDeMenu(icone: icone, ativo: ativo, destrutivo: destrutivo, child: _TextoDoItem(rotulo, destrutivo: destrutivo)),
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
              child: marcado ? const _MarcaDoItem() : null),
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

/// O texto do item; destrutivo, em vermelho de erro.
class _TextoDoItem extends StatelessWidget {
  const _TextoDoItem(this.rotulo, {required this.destrutivo});

  final String rotulo;
  final bool destrutivo;

  @override
  Widget build(BuildContext context) =>
      Text(rotulo, style: destrutivo ? TextStyle(color: context.cores.erro) : null);
}

/// O que fica à direita do item (o que o controle já move), como um atalho
/// de teclado: menor e em texto secundário.
class DetalheDeMenu extends StatelessWidget {
  const DetalheDeMenu(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto, style: Tipos.detalheMenu.copyWith(color: context.cores.textoSecundario));
}

/// O check da opção marcada, em âmbar (é seleção).
class _MarcaDoItem extends StatelessWidget {
  const _MarcaDoItem();

  @override
  Widget build(BuildContext context) => Icon(Icons.check, size: Medidas.iconeMenu, color: context.cores.tallyTinta);
}

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
    final cor = destrutivo ? context.cores.erro : context.cores.aluminioClaro;
    return Row(children: [
      Icon(icone, size: Medidas.iconeMenu, color: ativo ? cor : cor.withValues(alpha: Opacidades.itemIndisponivel)),
      const SizedBox(width: Espacos.m),
      Expanded(child: child),
    ]);
  }
}
