// Atalhos do HX Edit que valem aqui: Ctrl/Cmd+S salva, Ctrl/Cmd+Shift+S salva
// como, Ctrl/Cmd+C/V copiam e colam o bloco selecionado. Espaço (bypass do
// bloco) e 1–3 (cena) só valem sem botão ou campo focado.
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
    final soDoEditor = _teclasDoEditor(ref);
    return CallbackShortcuts(
      bindings: _atalhosComModificador(context, ref),
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

  /// Cmd no macOS e Ctrl no resto: os dois valem em qualquer plataforma.
  Map<ShortcutActivator, VoidCallback> _atalhosComModificador(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(editorProvider.notifier);
    SingleActivator tecla(LogicalKeyboardKey tecla, {required bool meta, bool shift = false}) =>
        SingleActivator(tecla, meta: meta, control: !meta, shift: shift);
    return {
      for (final meta in [true, false]) ...{
        tecla(LogicalKeyboardKey.keyS, meta: meta): () =>
            executarSalvar(context, ref, listaEmOutraTela: listaEmOutraTela),
        tecla(LogicalKeyboardKey.keyS, meta: meta, shift: true): () =>
            abrirEscolhaDeDestino(context, ref, listaEmOutraTela: listaEmOutraTela),
        tecla(LogicalKeyboardKey.keyC, meta: meta): () => _comSelecionado(ref, controlador.copiarBloco),
        tecla(LogicalKeyboardKey.keyV, meta: meta): () => _comSelecionado(ref, controlador.colarBloco),
      },
    };
  }

  /// Teclas sem modificador: com um botão ou campo focado, a tecla é dele
  /// (Espaço aperta o botão), então só valem com o foco no próprio editor.
  Map<LogicalKeyboardKey, VoidCallback> _teclasDoEditor(WidgetRef ref) {
    final controlador = ref.read(editorProvider.notifier);
    return {
      LogicalKeyboardKey.space: () => _comSelecionado(ref, controlador.alternarBypass),
      LogicalKeyboardKey.digit1: () => controlador.escolherCena(1),
      LogicalKeyboardKey.digit2: () => controlador.escolherCena(2),
      LogicalKeyboardKey.digit3: () => controlador.escolherCena(3),
    };
  }

  static void _comSelecionado(WidgetRef ref, void Function(PosicaoBloco posicao) acao) {
    final posicao = ref.read(editorProvider).selecionado;
    if (posicao != null) acao(posicao);
  }
}
