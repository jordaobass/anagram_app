// Menu de contexto de uma casa: copiar, colar, ligar/desligar e remover.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/bloco_preset.dart';

enum _AcaoMenu { copiar, colar, bypass, remover }

Future<void> abrirMenuBloco(BuildContext context, WidgetRef ref, PosicaoBloco posicao, Offset ponto) async {
  final estado = ref.read(editorProvider);
  final temBloco = estado.atual?.bloco(posicao) != null;
  final acao = await showMenu<_AcaoMenu>(
    context: context,
    position: RelativeRect.fromLTRB(ponto.dx, ponto.dy, ponto.dx, ponto.dy),
    items: [
      PopupMenuItem(value: _AcaoMenu.copiar, enabled: temBloco, child: const Text('Copiar bloco')),
      PopupMenuItem(
          value: _AcaoMenu.colar, enabled: estado.blocoCopiado != null, child: const Text('Colar aqui')),
      PopupMenuItem(value: _AcaoMenu.bypass, enabled: temBloco, child: const Text('Ligar / desligar')),
      PopupMenuItem(value: _AcaoMenu.remover, enabled: temBloco, child: const Text('Remover bloco')),
    ],
  );
  final controlador = ref.read(editorProvider.notifier);
  switch (acao) {
    case _AcaoMenu.copiar:
      controlador.copiarBloco(posicao);
    case _AcaoMenu.colar:
      await controlador.colarBloco(posicao);
    case _AcaoMenu.bypass:
      await controlador.alternarBypass(posicao);
    case _AcaoMenu.remover:
      await controlador.removerBloco(posicao);
    case null:
      break;
  }
}
