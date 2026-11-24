// "Templates" na barra do painel do bloco, como na pedaleira: um botão
// compacto em placa e, ao lado, discreto, o template aplicado enquanto o
// bloco estiver igual a ele (mexeu em algo, vira "Personalizado"). Abre a
// janela "Select Block Template" (janela_templates.dart), com os da Darkglass
// primeiro e os do app depois (DECISOES PP, PT).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/templates_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'alteracao_em_grupo.dart';
import 'controle_no_painel.dart';
import 'janela_templates.dart';

class SeletorTemplates extends ConsumerWidget {
  const SeletorTemplates({super.key, required this.bloco, required this.definicao, required this.cena});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  static const _larguraNome = 180.0;

  num? _valor(String simbolo) {
    final p = definicao.parametro(simbolo);
    return p == null ? null : ControleNoPainel.valorNaCena(bloco, p, cena);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider).value?.de(definicao.uri) ?? const [];
    if (templates.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final aplicado = templates.where((t) => t.aplicadoEm(_valor)).firstOrNull;
    final nome = aplicado?.nome.em(idioma) ?? l.ppPersonalizado;
    // Wrap: no celular o nome do template desce para baixo do botão
    return Wrap(spacing: Espacos.s, runSpacing: Espacos.xxs, crossAxisAlignment: WrapCrossAlignment.center, children: [
      Semantics(
        button: true,
        label: l.ppTemplates,
        value: nome,
        child: OutlinedButton(
          key: const ValueKey('abrir-templates'),
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Espacos.m)),
            minimumSize: WidgetStatePropertyAll(Size(Medidas.alvoMinimo, Medidas.alvoMinimo)),
          ),
          onPressed: () => _abrir(context, ref, templates, aplicado),
          child: Text(l.ppTemplates),
        ),
      ),
      // a barra pode ter largura livre: o nome tem teto em vez de flex
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraNome),
        child: ExcludeSemantics(
          child: Text(nome,
              key: const ValueKey('template-aplicado'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.cores.textoSecundario)),
        ),
      ),
    ]);
  }

  Future<void> _abrir(BuildContext context, WidgetRef ref, List<TemplateBloco> templates, TemplateBloco? aplicado) async {
    final escolhido = await escolherTemplate(context, templates, aplicado);
    if (escolhido == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    await alterarEmGrupo(context, ref,
        bloco: bloco,
        definicao: definicao,
        valores: escolhido.valores!,
        aviso: l.ppAplicado(escolhido.nome.em(Localizations.localeOf(context).languageCode)));
  }
}
