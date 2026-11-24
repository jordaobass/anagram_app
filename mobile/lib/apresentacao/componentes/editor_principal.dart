// Corpo do editor: fita do preset, cenas, cadeia de blocos, parâmetros e,
// no fim, os controles da pedaleira (o que se edita menos vai mais abaixo).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../tema/tokens.dart';
import 'editor_vazio.dart';
import 'faixa_preset.dart';
import 'grade_blocos.dart';
import 'grade_compacta.dart';
import 'moldura_case.dart';
import 'painel_controles.dart';
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
    // entre a fita, as cenas e a cadeia: mais junto com mouse (DECISOES BC1)
    final entreFaixas = compacto ? Espacos.m : MedidasDoTopo.daPlataforma.entreFaixas;
    return ListView(
      key: const ValueKey('rolagem-editor'),
      padding: EdgeInsets.all(espaco),
      children: [
        FaixaPreset(compacta: compacto, aoTocarSlot: aoAbrirLista),
        SizedBox(height: entreFaixas),
        const SeletorCenas(),
        SizedBox(height: espaco),
        MolduraCase(
          preenchimento: const EdgeInsets.all(Espacos.m),
          child: compacto ? const GradeCompacta() : const GradeBlocos(),
        ),
        SizedBox(height: espaco),
        if (ref.watch(editorProvider.select((e) => e.blocoSelecionado != null))) _painel() else const DicaMontarCadeia(),
        SizedBox(height: espaco),
        MolduraCase(child: PainelControles(compacto: compacto)),
      ],
    );
  }

  Widget _painel() => MolduraCase(
        child: PainelParametros(tamanhoKnob: compacto ? Medidas.knobCompacto : Medidas.knobAmplo, compacto: compacto),
      );
}
