// A barra de cima da tela do Ignissor e do Entropia, como na pedaleira, numa
// linha só: o nome fino e espaçado ("I G N I S S O R") gravado numa placa de
// alumínio claro escovado, o botão Templates em placa com o template
// aplicado ao lado, a legenda das linhas e, à direita, a pílula de
// liga/desliga do bloco. No celular os itens quebram linha. Dentro da barra
// as tintas viram as gravadas (escuras), medidas no teste de contraste.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../aplicacao/estado/controlador_editor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/catalogo/definicao_bloco.dart';
import '../../../nucleo/modelo/bloco_preset.dart';
import '../../tema/desenho_metal.dart';
import '../../tema/paletas_painel.dart';
import '../../tema/tema_app.dart';
import '../../tema/tema_painel.dart';
import '../../tema/tokens.dart';
import '../seletor_templates.dart';
import 'botoes_axioma.dart' show PilulaLigaNeon;

class BarraPainelMetal extends ConsumerWidget {
  const BarraPainelMetal({super.key, required this.bloco, required this.definicao, required this.cena, required this.legendas});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final List<Widget> legendas;

  static const _larguraEmLinha = 720.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pilula = PilulaLigaNeon(
      ligado: bloco.habilitadoNaCena(cena),
      dica: l.ligarDesligar,
      aoTocar: () => ref.read(editorProvider.notifier).alternarBypass(bloco.posicao),
    );
    final letreiro = _Letreiro(definicao.nome);
    final templates = SeletorTemplates(bloco: bloco, definicao: definicao, cena: cena);
    final tema = context.temaPainel;
    final conteudo = Container(
      key: const ValueKey('barra-painel'),
      padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Raios.controle),
        border: Border.all(color: CoresChassi.biselSombra),
        boxShadow: const [BoxShadow(color: CoresChassi.sombraRelevo, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, restricoes) => restricoes.maxWidth < _larguraEmLinha
            ? Wrap(spacing: Espacos.m, runSpacing: Espacos.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
                letreiro, templates, ...legendas, pilula,
              ])
            : Row(children: [
                letreiro,
                const SizedBox(width: Espacos.l),
                templates,
                const Spacer(),
                for (final legenda in legendas) ...[legenda, const SizedBox(width: Espacos.m)],
                pilula,
              ]),
      ),
    );
    if (tema == null) return conteudo;
    return Theme(
      data: TemaApp.doPainel(tema.comPaleta(_tintasGravadas(tema.paleta))),
      child: CustomPaint(painter: const _PintorPlacaClara(), child: conteudo),
    );
  }

  /// Dentro da placa clara: tinta gravada escura e botão em placa mais clara.
  static Paleta _tintasGravadas(Paleta p) => p.copyWith(
        texto: CoresChassi.tintaGravada,
        textoSecundario: CoresChassi.tintaSecundariaGravada,
        painelElevado: CoresChassi.placaBotao,
        aluminio: CoresChassi.biselSombra,
        filete: CoresChassi.biselSombra,
      );
}

/// A placa de alumínio claro escovado, com bisel em relevo.
class _PintorPlacaClara extends CustomPainter {
  const _PintorPlacaClara();

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    final borda = RRect.fromRectAndRadius(area, const Radius.circular(Raios.controle));
    canvas.drawRRect(borda, Paint()
      ..shader = const LinearGradient(colors: CoresChassi.barra, begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(area));
    canvas.save();
    canvas.clipRRect(borda);
    pintarEscovado(canvas, area, claro: CoresChassi.riscoClaro, escuro: CoresChassi.riscoEscuro, passo: 1.3, semente: 3);
    pintarEspecular(canvas, area, CoresChassi.especular);
    canvas.restore();
    pintarBisel(canvas, borda, luz: CoresChassi.biselLuz, sombra: CoresChassi.biselSombra, largura: 1.5);
  }

  @override
  bool shouldRepaint(_PintorPlacaClara antigo) => false;
}

/// O nome do bloco fino, em caixa alta e espaçado, estampado na placa.
class _Letreiro extends StatelessWidget {
  const _Letreiro(this.nome);

  final String nome;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Text(
          nome.toUpperCase(),
          key: const ValueKey('letreiro-painel'),
          style: TextStyle(
            fontFamily: Fontes.ui,
            fontSize: 20,
            height: 1,
            letterSpacing: 8,
            color: context.cores.texto,
            shadows: const [
              Shadow(color: CoresChassi.sombraRelevo, offset: Offset(0, -1)),
              Shadow(color: CoresChassi.luzGravacaoPlaca, offset: Offset(0, 1)),
            ],
          ),
        ),
      );
}
