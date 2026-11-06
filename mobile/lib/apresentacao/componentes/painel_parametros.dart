// Parâmetros do bloco selecionado em knobs grandes, todos à vista: a tela
// rola, então esconder parâmetro atrás de página só custava toques.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cabecalho_bloco.dart';
import 'controle_parametro.dart';

class PainelParametros extends ConsumerWidget {
  const PainelParametros({super.key, required this.tamanhoKnob, this.compacto = false});

  final double tamanhoKnob;

  /// No celular os knobs se espalham pela fileira; no amplo ficam agrupados no centro.
  final bool compacto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(editorProvider);
    final bloco = estado.blocoSelecionado;
    if (bloco == null) return const SizedBox.shrink();
    // sem o catálogo, faixas seriam chutadas: espera em vez de editar errado
    if (!ref.watch(catalogoProvider).hasValue) return const Center(child: CircularProgressIndicator());
    final definicao = ref.watch(definicaoBlocoProvider(bloco.uri));
    final parametros = parametrosVisiveis(definicao, bloco);
    final cena = estado.atual!.cenaAtiva;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CabecalhoBloco(bloco: bloco, definicao: definicao, cena: cena),
      const SizedBox(height: Espacos.m),
      LayoutBuilder(builder: (context, restricoes) {
        final tamanho = _tamanhoQueCabe(restricoes.maxWidth, parametros.length);
        return Wrap(
          alignment: compacto ? WrapAlignment.spaceEvenly : WrapAlignment.center,
          spacing: _vao,
          runSpacing: Espacos.l,
          children: [
            if (parametros.isEmpty)
              Text('Este bloco não tem parâmetros ajustáveis.', style: Theme.of(context).textTheme.bodyMedium),
            for (final p in parametros) _controle(context, ref, p, bloco, definicao, cena, tamanho),
          ],
        );
      }),
    ]);
  }

  double get _vao => compacto ? Espacos.m : Espacos.xl;

  /// No amplo, encolhe o knob (até o tamanho do celular) para não deixar
  /// um parâmetro sozinho numa segunda fileira.
  double _tamanhoQueCabe(double largura, int quantidade) {
    if (compacto || quantidade == 0) return tamanhoKnob;
    final porControle = (largura + _vao) / quantidade - _vao - Espacos.l;
    return porControle.clamp(Medidas.knobCompacto, tamanhoKnob);
  }

  Widget _controle(
    BuildContext context,
    WidgetRef ref,
    DefinicaoParametro p,
    BlocoPreset bloco,
    DefinicaoBloco definicao,
    int cena,
    double tamanho,
  ) {
    final controlador = ref.read(editorProvider.notifier);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ControleParametro(
        key: ValueKey('param-${p.simbolo}'),
        parametro: p,
        valor: bloco.valorNaCena(p.simbolo, cena) ?? p.padrao,
        cor: Cores.daFamilia(definicao.familia),
        tamanho: tamanho,
        aoMudar: (valor, {required arrastando}) =>
            controlador.alterarParametro(p.simbolo, valor, arrastando: arrastando, nome: p.nome, posicao: bloco.posicao),
      ),
      // como o valor "atribuído ao snapshot" do HX: esta cena sobrepõe
      if (bloco.sobreposicaoDaCena(p.simbolo, cena) != null)
        Text('SÓ NA CENA $cena', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.tally)),
    ]);
  }
}

/// Parâmetros do catálogo; para bloco desconhecido, os que o preset guarda,
/// com faixa estimada (marcada no nome).
List<DefinicaoParametro> parametrosVisiveis(DefinicaoBloco definicao, BlocoPreset bloco) {
  if (definicao.parametros.isNotEmpty) return definicao.parametros;
  return [
    for (final simbolo in bloco.simbolosGuardados)
      DefinicaoParametro(
        simbolo: simbolo,
        nome: '$simbolo (faixa estimada)',
        minimo: 0,
        maximo: ((bloco.valorBase(simbolo) ?? 0).abs() * 2).clamp(10, 100000),
        padrao: bloco.valorBase(simbolo) ?? 0,
      ),
  ];
}
