// Cadeia em grade: 2 linhas × 12 casas, entre o jaque IN e o OUT, com o
// caminho do sinal desenhado por trás (ver PintorLinhaSinal).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/catalogo/linha_paralela.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import 'biblioteca_efeitos.dart';
import 'casa_arrastavel.dart';
import 'casa_bloco.dart';
import 'faixa_linha_paralela.dart';
import 'menu_bloco.dart';
import 'pintor_linha_sinal.dart';

class GradeBlocos extends ConsumerWidget {
  const GradeBlocos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    if (documento == null) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, restricoes) {
      const casas = PosicaoBloco.casasPorLinha;
      final util = restricoes.maxWidth - Medidas.margemJaque * 2 - (casas - 1) * Medidas.vaoEntreCasas;
      final largura = (util / casas).clamp(Medidas.casaMinima, Medidas.casaMaxima);
      final geometria = geometriaDaCasa(largura);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: geometria.larguraTotal,
          height: geometria.alturaLinha * 2 + Espacos.s,
          child: CustomPaint(
            painter: _pintor(documento, geometria),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Medidas.margemJaque),
              child: Column(children: [
                _linha(context, ref, documento, 1, largura),
                const SizedBox(height: Espacos.s),
                if (mostraFaixaLinhaParalela(documento))
                  FaixaLinhaParalela(altura: geometria.alturaLinha)
                else
                  _linha(context, ref, documento, 2, largura),
              ]),
            ),
          ),
        ),
      );
    });
  }

  /// Altura da linha e centro da caixa do pedal para uma casa desta largura
  /// (as duas grades usam, para o fio passar no centro das caixas).
  static GeometriaGrade geometriaDaCasa(double largura) {
    final interno = largura - Espacos.xs * 2 - Medidas.contornoSelecao * 2;
    final arte = interno * Medidas.arteNaCasa;
    final alturaTexto = Medidas.alturaRotuloCasa + Medidas.fitaCategoria + Espacos.xs + Espacos.xxs;
    return GeometriaGrade(
      larguraCasa: largura,
      vao: Medidas.vaoEntreCasas,
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
      ocupadas: [for (final bloco in documento.blocosDaLinha(1)) bloco.posicao.casa]..sort(),
      ocupadas2: [for (final bloco in documento.blocosDaLinha(2)) bloco.posicao.casa]..sort(),
      casaSplit: casaCom(':split'),
      casaMerge: casaCom(':merge'),
    );
  }

  /// Altura fixa: a linha 2 fica no mesmo lugar com a linha 1 cheia ou vazia,
  /// e a pista do sinal continua passando no centro das casas.
  Widget _linha(BuildContext context, WidgetRef ref, DocumentoPreset documento, int linha, double largura) => SizedBox(
        height: geometriaDaCasa(largura).alturaLinha,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var casa = 1; casa <= PosicaoBloco.casasPorLinha; casa++) ...[
            if (casa > 1) const SizedBox(width: Medidas.vaoEntreCasas),
            casaDaGrade(context, ref, documento, PosicaoBloco(linha, casa), largura),
          ],
        ]),
      );
}

/// Sem Split e com a linha 2 vazia, a linha 2 vira a faixa de criar a linha
/// paralela (as duas grades): ali os encaixes não receberiam sinal.
bool mostraFaixaLinhaParalela(DocumentoPreset documento) =>
    !temLinhaParalela(documento) && documento.blocosDaLinha(2).isEmpty;

/// Uma casa ligada ao editor (selecionar, bypass, menu, adicionar efeito na
/// vazia, arrastar para mudar de lugar). Usada nas duas grades.
Widget casaDaGrade(BuildContext context, WidgetRef ref, DocumentoPreset documento, PosicaoBloco posicao, double largura) {
  final selecionado = ref.watch(editorProvider.select((e) => e.selecionado));
  final controlador = ref.read(editorProvider.notifier);
  final bloco = documento.bloco(posicao);
  return CasaArrastavel(
    posicao: posicao,
    largura: largura,
    child: CasaBloco(
      key: ValueKey('casa-${posicao.linha}-${posicao.casa}'),
      posicao: posicao,
      bloco: bloco,
      ligado: bloco?.habilitadoNaCena(documento.cenaAtiva) ?? false,
      selecionado: selecionado == posicao && bloco != null,
      largura: largura,
      aoTocar: () =>
          bloco == null ? adicionarEfeitoNaCasa(context, ref, posicao) : controlador.selecionarBloco(posicao),
      aoTocarDuas: () => controlador.alternarBypass(posicao),
      aoPedirMenu: (ponto) => abrirMenuBloco(context, ref, posicao, ponto),
    ),
  );
}
