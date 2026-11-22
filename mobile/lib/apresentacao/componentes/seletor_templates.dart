// "Templates" no topo do painel do bloco, como o "Select Block Template" da
// pedaleira: os da Darkglass primeiro, depois os do app, cada um com a frase
// que o descreve. O botão mostra o template aplicado enquanto o bloco estiver
// igual a ele; mexeu em algo, vira "Personalizado". Template da pedaleira
// ainda sem valores lidos aparece desabilitado, com o motivo (DECISOES PP).
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
import 'dialogo_confirmar.dart';

class SeletorTemplates extends ConsumerWidget {
  const SeletorTemplates({super.key, required this.bloco, required this.definicao, required this.cena});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

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
    return Semantics(
      button: true,
      label: l.ppTemplates,
      value: aplicado?.nome.em(idioma) ?? l.ppPersonalizado,
      child: OutlinedButton.icon(
        key: const ValueKey('abrir-templates'),
        onPressed: () => _abrir(context, ref, templates, aplicado),
        icon: const Icon(Icons.auto_awesome_motion_outlined),
        label: Text('${l.ppTemplates.toUpperCase()} · ${aplicado?.nome.em(idioma) ?? l.ppPersonalizado}',
            key: const ValueKey('template-aplicado'), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Future<void> _abrir(BuildContext context, WidgetRef ref, List<TemplateBloco> templates, TemplateBloco? aplicado) async {
    final escolhido = await showDialog<TemplateBloco>(
      context: context,
      builder: (_) => _ListaTemplates(templates: templates, aplicado: aplicado),
    );
    if (escolhido == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    await alterarEmGrupo(context, ref,
        bloco: bloco,
        definicao: definicao,
        cena: cena,
        valores: escolhido.valores!,
        aviso: l.ppAplicado(escolhido.nome.em(Localizations.localeOf(context).languageCode)));
  }
}

class _ListaTemplates extends StatelessWidget {
  const _ListaTemplates({required this.templates, required this.aplicado});

  final List<TemplateBloco> templates;
  final TemplateBloco? aplicado;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.ppEscolherTemplate),
      contentPadding: const EdgeInsets.symmetric(vertical: Espacos.s),
      content: SizedBox(
        width: Medidas.larguraDialogoTemplates,
        child: ListView(shrinkWrap: true, children: [
          for (final origem in OrigemTemplate.values)
            if (templates.where((t) => t.origem == origem).toList() case final grupo when grupo.isNotEmpty) ...[
              _cabecalho(context, origem == OrigemTemplate.darkglass ? l.ppDaDarkglass : l.ppDoApp),
              for (final t in grupo) _item(context, t),
            ],
        ]),
      ),
      actions: [BotaoCancelarDialogo(rotulo: l.cancelar, aoTocar: () => Navigator.pop(context))],
    );
  }

  Widget _cabecalho(BuildContext context, String texto) => Padding(
        padding: const EdgeInsets.fromLTRB(Espacos.l, Espacos.m, Espacos.l, Espacos.xs),
        child: Text(texto.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Cores.textoSecundario)),
      );

  Widget _item(BuildContext context, TemplateBloco t) {
    final idioma = Localizations.localeOf(context).languageCode;
    final l = AppLocalizations.of(context);
    final descricao = t.disponivel ? t.descricao.em(idioma) : '${t.descricao.em(idioma)}\n${l.ppAConfirmar}';
    return ListTile(
      key: ValueKey('template-${t.id}'),
      enabled: t.disponivel,
      selected: identical(t, aplicado),
      title: Text(t.nome.em(idioma)),
      subtitle: Text(descricao),
      onTap: t.disponivel ? () => Navigator.pop(context, t) : null,
    );
  }
}
