// Corpo do editor: fita do preset, cenas, cadeia de blocos e parâmetros.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';
import 'editor_vazio.dart';
import 'faixa_preset.dart';
import 'grade_blocos.dart';
import 'grade_compacta.dart';
import 'moldura_case.dart';
import 'painel_parametros.dart';
import 'seletor_cenas.dart';

class EditorPrincipal extends ConsumerWidget {
  const EditorPrincipal({super.key, required this.compacto, this.aoAbrirLista});

  final bool compacto;
  final VoidCallback? aoAbrirLista;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temPreset = ref.watch(editorProvider.select((e) => e.atual != null));
    final carregando = ref.watch(editorProvider.select((e) => e.carregando));
    if (!temPreset) {
      return carregando ? const Center(child: CircularProgressIndicator()) : EditorVazio(aoAbrirLista: aoAbrirLista);
    }
    final espaco = compacto ? Espacos.m : Espacos.l;
    return ListView(
      key: const ValueKey('rolagem-editor'),
      padding: EdgeInsets.all(espaco),
      children: [
        FaixaPreset(compacta: compacto, aoTocarSlot: aoAbrirLista),
        SizedBox(height: espaco),
        const SeletorCenas(),
        SizedBox(height: espaco),
        MolduraCase(
          preenchimento: const EdgeInsets.all(Espacos.m),
          child: compacto ? const GradeCompacta() : const GradeBlocos(),
        ),
        SizedBox(height: espaco),
        if (ref.watch(editorProvider.select((e) => e.blocoSelecionado != null)))
          MolduraCase(
            child: PainelParametros(
              tamanhoKnob: compacto ? Medidas.knobCompacto : Medidas.knobAmplo,
              compacto: compacto,
            ),
          ),
      ],
    );
  }
}
