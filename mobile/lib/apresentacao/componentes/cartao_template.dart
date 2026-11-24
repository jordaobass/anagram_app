// Um cartão da janela de templates: o nome em destaque e a descrição em até
// três linhas. Placa de alumínio claro (metal), módulo de moldura dupla
// (neon) ou painel do case. O aplicado leva o contorno âmbar de seleção; sem
// valores lidos da pedaleira, fica apagado, não recebe foco e diz por quê.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/templates_bloco.dart';
import '../tema/paletas_painel.dart';
import '../tema/tokens.dart';
import 'estilo_janela_templates.dart';
import 'tela_pedaleira/modulo_neon.dart';
import 'tela_pedaleira/neon.dart';

class CartaoTemplate extends StatelessWidget {
  const CartaoTemplate({
    super.key,
    required this.template,
    required this.aplicado,
    required this.estilo,
    required this.aoEscolher,
  });

  final TemplateBloco template;
  final bool aplicado;
  final EstiloJanela estilo;
  final VoidCallback aoEscolher;

  static const largura = 184.0;
  static const altura = 184.0;

  bool get habilitado => template.disponivel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final descricao = template.descricao.em(idioma);
    return Tooltip(
      message: habilitado ? descricao : '$descricao\n${l.ppAConfirmar}',
      child: Semantics(
        button: true,
        enabled: habilitado,
        selected: aplicado,
        child: InkWell(
          autofocus: aplicado,
          onTap: habilitado ? aoEscolher : null,
          child: SizedBox(width: largura, height: altura, child: _corpo(context, l, idioma, descricao)),
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, AppLocalizations l, String idioma, String descricao) {
    final (fundo, nome, texto) = _cores(context);
    final fonte = estilo.neon ? Fontes.tecno : Fontes.ui;
    final conteudo = Padding(
      padding: const EdgeInsets.all(Espacos.m + 2),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // sem valores, o texto apaga; o selo embaixo fica inteiro, à vista
        Opacity(
          opacity: habilitado ? 1 : Medidas.opacidadeBandaDesligada,
          child: Column(children: [
            Text(template.nome.em(idioma),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontFamily: fonte, fontSize: 17, fontWeight: FontWeight.w600, color: nome)),
            const SizedBox(height: Espacos.xs),
            Text(descricao,
                textAlign: TextAlign.center,
                maxLines: habilitado ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: fonte, fontSize: 13, height: 1.25, color: texto)),
          ]),
        ),
        if (!habilitado) ...[const SizedBox(height: Espacos.xs), _SeloSemValores(texto: l.ppAConfirmar, cor: nome)],
      ]),
    );
    final selecao = aplicado ? BorderSide(color: context.cores.tallyTinta, width: Medidas.contornoSelecao) : BorderSide.none;
    if (estilo.neon) {
      return CustomPaint(
        painter: PintorModuloNeon(fundo: fundo, brilho: BrilhoNeon.of(context)),
        foregroundPainter: aplicado ? _PintorSelecaoNeon(selecao.color) : null,
        child: conteudo,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: estilo.metal ? const LinearGradient(colors: CoresChassi.barra, begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
        color: estilo.metal ? null : fundo,
        borderRadius: BorderRadius.circular(Raios.painel),
        border: Border.fromBorderSide(aplicado ? selecao : BorderSide(color: estilo.metal ? CoresChassi.biselSombra : context.cores.filete)),
        boxShadow: estilo.metal ? const [BoxShadow(color: CoresChassi.sombraRelevo, blurRadius: 6, offset: Offset(0, 3))] : null,
      ),
      child: conteudo,
    );
  }

  /// Fundo, cor do nome e cor da descrição para o estilo da janela.
  (Color, Color, Color) _cores(BuildContext context) {
    final cores = context.cores;
    if (estilo.metal) return (CoresChassi.barra.last, CoresChassi.tintaGravada, CoresChassi.tintaSecundariaGravada);
    if (estilo.neon) return (cores.painelElevado, CoresNeon.sobreFaixa, cores.textoSecundario);
    return (cores.painel, cores.texto, cores.textoSecundario);
  }
}

/// "Valores ainda não lidos da pedaleira", sempre à vista no desabilitado.
class _SeloSemValores extends StatelessWidget {
  const _SeloSemValores({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('selo-sem-valores'),
        padding: const EdgeInsets.symmetric(horizontal: Espacos.xs, vertical: Espacos.xxs),
        decoration: BoxDecoration(border: Border.all(color: cor), borderRadius: BorderRadius.circular(Raios.canto)),
        child: Text(texto, textAlign: TextAlign.center, style: TextStyle(fontFamily: Fontes.rotulo, fontSize: 12, height: 1.15, color: cor)),
      );
}

/// O contorno âmbar do aplicado, por dentro da moldura chanfrada.
class _PintorSelecaoNeon extends CustomPainter {
  const _PintorSelecaoNeon(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
      PintorModuloNeon.chanfrado((Offset.zero & size).deflate(9), 6),
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = Medidas.contornoSelecao);

  @override
  bool shouldRepaint(_PintorSelecaoNeon antigo) => antigo.cor != cor;
}
