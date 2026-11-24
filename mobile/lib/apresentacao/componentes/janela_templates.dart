// "Select Block Template" como a tela da pedaleira: uma janela com a barra
// do título centralizado e o X, e embaixo uma fileira horizontal rolável de
// cartões (nome em destaque e a descrição). Os da Darkglass primeiro; depois
// de um separador, os do app. O aplicado fica com o contorno âmbar; o sem
// valores lidos, apagado e com o motivo. Setas andam entre os cartões, Enter
// aplica, Esc fecha. O desenho segue o painel de onde a janela abriu: placas
// de metal (Ignissor, Entropia), módulos de neon (Axioma) ou o case.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/templates_bloco.dart';
import '../tema/tokens.dart';
import 'cartao_template.dart';
import 'estilo_janela_templates.dart';
import 'tela_pedaleira/modulo_neon.dart';

/// Abre a janela e devolve o template escolhido (nulo se fechou).
Future<TemplateBloco?> escolherTemplate(BuildContext context, List<TemplateBloco> templates, TemplateBloco? aplicado) =>
    showDialog<TemplateBloco>(context: context, builder: (_) => JanelaTemplates(templates: templates, aplicado: aplicado));

class JanelaTemplates extends StatefulWidget {
  const JanelaTemplates({super.key, required this.templates, required this.aplicado});

  final List<TemplateBloco> templates;
  final TemplateBloco? aplicado;

  static const larguraMaxima = 1240.0;

  @override
  State<JanelaTemplates> createState() => _EstadoJanelaTemplates();
}

class _EstadoJanelaTemplates extends State<JanelaTemplates> {
  final _rolagem = ScrollController();

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final estilo = EstiloJanela.de(context);
    return Dialog(
      key: const ValueKey('janela-templates'),
      insetPadding: const EdgeInsets.all(Espacos.xl),
      backgroundColor: estilo.fundo,
      shape: estilo.forma,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: JanelaTemplates.larguraMaxima),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BarraTituloJanela(titulo: l.ppEscolherTemplate, estilo: estilo, aoFechar: () => Navigator.pop(context)),
          Scrollbar(
            controller: _rolagem,
            thumbVisibility: true,
            thickness: Espacos.xs,
            child: SingleChildScrollView(
              controller: _rolagem,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(Espacos.l, Espacos.l, Espacos.l, Espacos.xl),
              child: FocusTraversalGroup(
                  child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: _fileira(context, l, estilo)))),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _fileira(BuildContext context, AppLocalizations l, EstiloJanela estilo) {
    final pecas = <Widget>[];
    for (final origem in OrigemTemplate.values) {
      final grupo = [for (final t in widget.templates) if (t.origem == origem) t];
      if (grupo.isEmpty) continue;
      if (pecas.isNotEmpty) pecas.add(SeparadorGrupo(texto: origem == OrigemTemplate.app ? l.ppDoApp : l.ppDaDarkglass, estilo: estilo));
      for (final (i, t) in grupo.indexed) {
        if (i > 0) pecas.add(estilo.neon ? const GradeFuros() : const SizedBox(width: Espacos.m));
        pecas.add(CartaoTemplate(
          key: ValueKey('template-${t.id}'),
          template: t,
          aplicado: identical(t, widget.aplicado),
          estilo: estilo,
          aoEscolher: () => Navigator.pop(context, t),
        ));
      }
    }
    return pecas;
  }
}

/// A barra do título: X à esquerda, o título no centro.
class BarraTituloJanela extends StatelessWidget {
  const BarraTituloJanela({super.key, required this.titulo, required this.estilo, required this.aoFechar});

  final String titulo;
  final EstiloJanela estilo;
  final VoidCallback aoFechar;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: estilo.barra,
        child: Padding(
          padding: const EdgeInsets.all(Espacos.s),
          child: Row(children: [
            IconButton(
              key: const ValueKey('fechar-templates'),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: aoFechar,
              color: estilo.tintaBarra,
              icon: const Icon(Icons.close),
            ),
            Expanded(child: Text(titulo, textAlign: TextAlign.center, style: estilo.estiloTitulo)),
            const SizedBox(width: Medidas.alvoMinimo),
          ]),
        ),
      );
}

/// Onde começam os templates do app, na mesma fileira.
class SeparadorGrupo extends StatelessWidget {
  const SeparadorGrupo({super.key, required this.texto, required this.estilo});

  final String texto;
  final EstiloJanela estilo;

  static const largura = 112.0;

  @override
  Widget build(BuildContext context) => Container(
        width: largura,
        margin: const EdgeInsets.symmetric(horizontal: Espacos.m),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: estilo.tintaTexto))),
        alignment: Alignment.center,
        child: Text(texto.toUpperCase(),
            key: const ValueKey('separador-templates-app'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: estilo.tintaTexto, shadows: const [])),
      );
}
