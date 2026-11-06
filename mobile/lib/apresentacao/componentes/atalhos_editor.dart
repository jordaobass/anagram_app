// Atalhos do HX Edit que valem aqui (Espaço e 1–3 só sem botão/campo focado): Ctrl/Cmd+S salva, Ctrl/Cmd+Shift+S salva como, Espaço liga/desliga
// o bloco selecionado, 1–3 trocam de cena, Ctrl/Cmd+C/V copiam e colam.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import 'fluxo_salvar.dart';

class AtalhosEditor extends ConsumerWidget {
  const AtalhosEditor({super.key, required this.child, required this.listaEmOutraTela});

  final Widget child;

  /// Celular: a lista de presets é outra rota (Salvar sem slot a abre).
  final bool listaEmOutraTela;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(editorProvider.notifier);
    void comSelecionado(void Function(PosicaoBloco posicao) acao) {
      final posicao = ref.read(editorProvider).selecionado;
      if (posicao != null) acao(posicao);
    }

    final atalhos = <ShortcutActivator, VoidCallback>{
      for (final modificador in [true, false]) ...{
        SingleActivator(LogicalKeyboardKey.keyS, meta: modificador, control: !modificador): () =>
            executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela),
        SingleActivator(LogicalKeyboardKey.keyS, meta: modificador, control: !modificador, shift: true): () =>
            abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
        SingleActivator(LogicalKeyboardKey.keyC, meta: modificador, control: !modificador): () =>
            comSelecionado((p) => controlador.copiarBloco(p)),
        SingleActivator(LogicalKeyboardKey.keyV, meta: modificador, control: !modificador): () =>
            comSelecionado((p) => controlador.colarBloco(p)),
      },
    };
    // Espaço e 1–3 só valem com o foco no próprio editor: com um botão ou
    // campo focado, a tecla é dele (Espaço aperta o botão).
    final soDoEditor = <LogicalKeyboardKey, VoidCallback>{
      LogicalKeyboardKey.space: () => comSelecionado((p) => controlador.alternarBypass(p)),
      LogicalKeyboardKey.digit1: () => controlador.escolherCena(1),
      LogicalKeyboardKey.digit2: () => controlador.escolherCena(2),
      LogicalKeyboardKey.digit3: () => controlador.escolherCena(3),
    };
    return CallbackShortcuts(
      bindings: atalhos,
      child: Focus(
        autofocus: true,
        onKeyEvent: (no, evento) {
          final acao = soDoEditor[evento.logicalKey];
          if (evento is! KeyDownEvent || acao == null || !no.hasPrimaryFocus) return KeyEventResult.ignored;
          acao();
          return KeyEventResult.handled;
        },
        child: child,
      ),
    );
  }
}
