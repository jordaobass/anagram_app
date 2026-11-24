// A barra de cima da tela do Axioma, no desenho da pedaleira, com tudo de
// verdade: X fecha o painel; Templates abre os templates (ou diz que ainda
// não há); as cinco abas levam à seção; a pílula liga e desliga o bloco; o
// LCD mostra o slot aberto; o campo "Controlar" alterna todas as cenas / só a
// ativa; lixeira remove (com desfazer), as setas trocam de linha e o menu é o
// do bloco. As molas são só enfeite.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../aplicacao/estado/controlador_editor.dart';
import '../../../aplicacao/estado/escopo_cenas.dart';
import '../../../aplicacao/provedores.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../../nucleo/catalogo/biblioteca_blocos.dart' show podeMover;
import '../../../nucleo/catalogo/definicao_bloco.dart';
import '../../../nucleo/modelo/bloco_preset.dart';
import '../../../nucleo/modelo/cenas_do_bloco.dart';
import '../../tema/paletas_painel.dart';
import '../../tema/tokens.dart';
import '../acoes_roteamento.dart' show removerBlocoComAviso;
import '../menu_bloco.dart' show abrirMenuBloco;
import '../secoes_sintetizador.dart' show tituloDaSecao;
import '../seletor_templates.dart';
import 'botoes_axioma.dart';
import 'decoracao_axioma.dart';
import 'icones_axioma.dart';
import 'neon.dart';

class BarraAxioma extends ConsumerWidget {
  const BarraAxioma({super.key, required this.bloco, required this.definicao, required this.cena, required this.aoIrPara});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final ValueChanged<SecaoSintetizador> aoIrPara;

  static const abas = [
    (IconeAxioma.mixer, SecaoSintetizador.osciladores),
    (IconeAxioma.onda, SecaoSintetizador.filtro),
    (IconeAxioma.envelope, SecaoSintetizador.envelope),
    (IconeAxioma.escada, SecaoSintetizador.arpejador),
    (IconeAxioma.engrenagem, SecaoSintetizador.entrada),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controlador = ref.read(editorProvider.notifier);
    return DecoratedBox(
      key: const ValueKey('barra-axioma'),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: CoresNeon.barra, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Padding(
        padding: const EdgeInsets.all(Espacos.s),
        child: Wrap(spacing: Espacos.s, runSpacing: Espacos.s, crossAxisAlignment: WrapCrossAlignment.center, children: [
          BotaoQuadradoNeon(chave: 'ax-fechar', icone: IconeAxioma.fechar, dica: l.axFecharPainel, aoTocar: controlador.desselecionarBloco),
          const LogotipoAxioma(),
          _templates(context, ref, l),
          for (final (icone, secao) in abas)
            BotaoQuadradoNeon(chave: 'ax-aba-${secao.name}', icone: icone, dica: tituloDaSecao(l, secao), aoTocar: () => aoIrPara(secao)),
          PilulaLigaNeon(ligado: bloco.habilitadoNaCena(cena), dica: l.ligarDesligar, aoTocar: () => controlador.alternarBypass(bloco.posicao)),
          ExcludeSemantics(child: SizedBox(width: 96, height: 40, child: CustomPaint(painter: PintorMolas(brilho: BrilhoNeon.of(context))))),
          VisorLcd(texto: ref.watch(editorProvider.select((e) => e.slot?.rotulo)) ?? '---', rotulo: l.axVisorSlot),
          _controlar(ref, l),
          ..._acoes(context, ref, l),
        ]),
      ),
    );
  }

  Widget _templates(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final tem = ref.watch(templatesProvider).value?.de(definicao.uri).isNotEmpty ?? false;
    if (tem) return SeletorTemplates(bloco: bloco, definicao: definicao, cena: cena);
    return Tooltip(
      message: l.axSemTemplates,
      child: OutlinedButton(key: const ValueKey('ax-templates'), onPressed: null, child: Text(l.ppTemplates)),
    );
  }

  Widget _controlar(WidgetRef ref, AppLocalizations l) {
    final escopo = ref.watch(escopoCenasProvider);
    final todas = escopo == EscopoCenas.todasAsCenas;
    return CampoControlar(
      texto: todas ? l.ceTodas : l.ceAtiva,
      rotulo: l.ceControlar,
      dica: todas ? l.ceTodasDica : l.ceAtivaDica,
      aoTocar: () => ref.read(escopoCenasProvider.notifier).definir(todas ? EscopoCenas.soNaCena : EscopoCenas.todasAsCenas),
    );
  }

  List<Widget> _acoes(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final posicao = bloco.posicao;
    final outra = PosicaoBloco(posicao.linha == 1 ? 2 : 1, posicao.casa);
    final documento = ref.watch(editorProvider).atual;
    final podeTrocar = documento != null && podeMover(documento, posicao, outra);
    return [
      BotaoQuadradoNeon(
          chave: 'ax-remover', icone: IconeAxioma.lixeira, dica: l.removerBloco, aoTocar: () => removerBlocoComAviso(context, ref, posicao)),
      BotaoQuadradoNeon(
          chave: 'ax-trocar-linha',
          icone: IconeAxioma.troca,
          dica: l.moverParaLinha(outra.linha),
          aoTocar: podeTrocar ? () => ref.read(editorProvider.notifier).moverBloco(posicao, outra) : null),
      Builder(
        builder: (botao) => BotaoQuadradoNeon(
          chave: 'ax-menu',
          icone: IconeAxioma.menu,
          dica: l.maisAcoesBloco,
          aoTocar: () {
            final caixa = botao.findRenderObject()! as RenderBox;
            abrirMenuBloco(botao, ref, posicao, caixa.localToGlobal(caixa.size.bottomLeft(Offset.zero)));
          },
        ),
      ),
    ];
  }
}
