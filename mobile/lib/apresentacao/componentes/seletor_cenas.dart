// Cenas como os snapshots do HX: trocar de cena soa na hora. Até três, elas
// dividem a linha; com mais (firmware 1.16+, issue #39), viram uma fita que
// rola na horizontal e mostra a ativa. À direita delas, as pílulas do modo dos footswitches; sem largura, logo abaixo. Por
// último, a chave "Controlar" (quais cenas a edição muda).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/cenas_do_bloco.dart' show cenasMinimas;
import '../tema/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'botao_tally.dart';
import 'chave_controlar_cenas.dart';
import 'pilulas_modo_footswitches.dart';

class SeletorCenas extends ConsumerWidget {
  const SeletorCenas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    final controlador = ref.read(editorProvider.notifier);
    Widget botao(int cena) => _BotaoCena(
          numero: cena,
          nome: documento.nomeDaCena(cena),
          ativa: documento.cenaAtiva == cena,
          aoTocar: () => controlador.escolherCena(cena),
        );
    return LayoutBuilder(builder: (context, restricoes) {
      final aoLado = restricoes.maxWidth >= Medidas.larguraCenasComModo;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          if (documento.quantidadeCenas <= cenasMinimas)
            for (final cena in documento.cenas) ...[
              if (cena > 1) const SizedBox(width: Espacos.s),
              Expanded(child: botao(cena)),
            ]
          else
            Expanded(child: _FitaDeCenas(cenas: documento.cenas, ativa: documento.cenaAtiva, botao: botao)),
          if (aoLado) const PilulasModoFootswitches(espacoAntes: Espacos.m),
        ]),
        if (!aoLado) const Align(alignment: Alignment.centerRight, child: PilulasModoFootswitches()),
        const SizedBox(height: Espacos.xs),
        const Align(alignment: Alignment.centerLeft, child: ChaveControlarCenas()),
        const AvisoErroModoFootswitches(),
      ]);
    });
  }
}

/// Mais de três cenas: rolam na horizontal, com a ativa trazida para a vista
/// ao abrir o preset ou trocar de cena por fora (pedal, MCP, atalho).
class _FitaDeCenas extends StatefulWidget {
  const _FitaDeCenas({required this.cenas, required this.ativa, required this.botao});

  final List<int> cenas;
  final int ativa;
  final Widget Function(int cena) botao;

  @override
  State<_FitaDeCenas> createState() => _FitaDeCenasState();
}

class _FitaDeCenasState extends State<_FitaDeCenas> {
  final _rolagem = ScrollController();

  @override
  void initState() {
    super.initState();
    _mostrarAtiva();
  }

  @override
  void didUpdateWidget(_FitaDeCenas antes) {
    super.didUpdateWidget(antes);
    if (antes.ativa != widget.ativa) _mostrarAtiva();
  }

  void _mostrarAtiva() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_rolagem.hasClients) return;
        final passo = Medidas.larguraCenaNaFita + Espacos.s;
        final alvo = (widget.ativa - 1) * passo - (_rolagem.position.viewportDimension - passo) / 2;
        _rolagem.jumpTo(alvo.clamp(0, _rolagem.position.maxScrollExtent));
      });

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MedidasDoTopo.daPlataforma.cena,
        child: Scrollbar(
          controller: _rolagem,
          child: ListView.separated(
            key: const ValueKey('fita-de-cenas'),
            controller: _rolagem,
            scrollDirection: Axis.horizontal,
            itemCount: widget.cenas.length,
            separatorBuilder: (_, _) => const SizedBox(width: Espacos.s),
            itemBuilder: (_, indice) =>
                SizedBox(width: Medidas.larguraCenaNaFita, child: widget.botao(widget.cenas[indice])),
          ),
        ),
      );
}

class _BotaoCena extends StatelessWidget {
  const _BotaoCena({required this.numero, required this.nome, required this.ativa, required this.aoTocar});

  final int numero;

  /// Nome que o preset deu à cena; sem nome, o botão mostra "1 CENA" em vez
  /// de "1 CENA 1".
  final String? nome;
  final bool ativa;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BotaoTally(
      chave: ValueKey('cena-$numero'),
      ativo: ativa,
      rotuloSemantico: l.cenaSemantica(numero, nome ?? l.cenaPadrao(numero)),
      aoTocar: aoTocar,
      alturaMinima: MedidasDoTopo.daPlataforma.cena,
      filho: _rotulo(Theme.of(context).textTheme, BotaoTally.corDoTexto(context.cores, ativo: ativa), nome ?? l.uiCena),
    );
  }

  Widget _rotulo(TextTheme tema, Color corTexto, String texto) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.xs),
        child: Row(children: [
          Text('$numero', style: tema.displaySmall?.copyWith(color: corTexto, fontSize: tema.titleLarge?.fontSize)),
          const SizedBox(width: Espacos.s),
          Expanded(
            child: Text(texto.toUpperCase(),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelLarge?.copyWith(color: corTexto)),
          ),
        ]),
      );
}
