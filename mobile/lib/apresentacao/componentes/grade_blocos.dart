// Cadeia em grade: 2 linhas × 12 casas sobre a linha do sinal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import 'casa_bloco.dart';
import 'menu_bloco.dart';
import 'pintor_linha_sinal.dart';

class GradeBlocos extends ConsumerWidget {
  const GradeBlocos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, restricoes) {
      final largura = ((restricoes.maxWidth - 11 * Espacos.s) / 12).clamp(Medidas.casaMinima, Medidas.casaMaxima);
      final geometria = _geometria(largura);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: geometria.larguraTotal,
          height: geometria.alturaLinha * 2 + Espacos.s,
          child: CustomPaint(
            painter: _pintor(documento, geometria),
            child: Column(children: [
              _linha(context, ref, documento, 1, largura),
              const SizedBox(height: Espacos.s),
              _linha(context, ref, documento, 2, largura),
            ]),
          ),
        ),
      );
    });
  }

  static GeometriaGrade _geometria(double largura) {
    final interno = largura - Espacos.xs * 2 - Medidas.contornoSelecao * 2;
    final arte = interno * Medidas.arteNaCasa;
    final alturaTexto = Medidas.alturaRotuloCasa + Medidas.fitaCategoria + Espacos.xs + Espacos.xxs;
    return GeometriaGrade(
      larguraCasa: largura,
      vao: Espacos.s,
      alturaLinha: arte + alturaTexto + Espacos.xs * 2 + Medidas.contornoSelecao * 2,
      centroArte: Espacos.xs + Medidas.contornoSelecao + arte / 2,
    );
  }

  static PintorLinhaSinal _pintor(DocumentoPreset documento, GeometriaGrade geometria) {
    int? casaCom(String trecho) {
      for (final bloco in documento.blocosDaLinha(1)) {
        if (bloco.uri.endsWith(trecho)) return bloco.posicao.casa;
      }
      return null;
    }

    return PintorLinhaSinal(
      geometria: geometria,
      temLinha2: documento.blocosDaLinha(2).isNotEmpty,
      casaSplit: casaCom(':split'),
      casaMerge: casaCom(':merge'),
    );
  }

  Widget _linha(BuildContext context, WidgetRef ref, DocumentoPreset documento, int linha, double largura) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var casa = 1; casa <= PosicaoBloco.casasPorLinha; casa++) ...[
          if (casa > 1) const SizedBox(width: Espacos.s),
          casaDaGrade(context, ref, documento, PosicaoBloco(linha, casa), largura),
        ],
      ]);
}

/// Uma casa ligada ao editor (selecionar, bypass, menu). Usada nas duas grades.
Widget casaDaGrade(BuildContext context, WidgetRef ref, DocumentoPreset documento, PosicaoBloco posicao, double largura) {
  final selecionado = ref.watch(editorProvider.select((e) => e.selecionado));
  final controlador = ref.read(editorProvider.notifier);
  final bloco = documento.bloco(posicao);
  return CasaBloco(
    key: ValueKey('casa-${posicao.linha}-${posicao.casa}'),
    posicao: posicao,
    bloco: bloco,
    ligado: bloco?.habilitadoNaCena(documento.cenaAtiva) ?? false,
    selecionado: selecionado == posicao && bloco != null,
    largura: largura,
    aoTocar: () => bloco == null ? null : controlador.selecionarBloco(posicao),
    aoTocarDuas: () => controlador.alternarBypass(posicao),
    aoPedirMenu: (ponto) => abrirMenuBloco(context, ref, posicao, ponto),
  );
}
