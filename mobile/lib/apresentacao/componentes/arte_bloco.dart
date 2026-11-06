// Arte do bloco: miniatura (quando há uma para a uri/nome) ou arte própria
// da família. Desligado = a imagem de bypass da pedaleira, quando existe;
// senão esmaecido e em cinza, como LED apagado.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/arte/indice_miniaturas.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import 'pintor_arte_familia.dart';

class ArteBlocoWidget extends ConsumerWidget {
  const ArteBlocoWidget({super.key, required this.definicao, required this.tamanho, this.ligado = true});

  final DefinicaoBloco definicao;
  final double tamanho;
  final bool ligado;

  static const _cinza = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indice = ref.watch(indiceMiniaturasProvider).value;
    final arte = indice?.arteDe(definicao) ?? ArteDaFamilia(definicao.familia);
    if (!ligado && arte is ArteMiniatura && arte.caminhoDesligado != null) {
      return SizedBox.square(dimension: tamanho, child: _imagem(arte.caminhoDesligado!));
    }
    final desenho = SizedBox.square(dimension: tamanho, child: _desenho(arte));
    if (ligado) return desenho;
    return Opacity(
      opacity: Opacidades.blocoDesligado,
      child: ColorFiltered(colorFilter: _cinza, child: desenho),
    );
  }

  Widget _desenho(ArteBloco arte) => switch (arte) {
        ArteMiniatura(:final caminhoAsset) => _imagem(caminhoAsset),
        ArteDaFamilia(:final familia) => CustomPaint(painter: PintorArteFamilia(familia)),
      };

  Widget _imagem(String caminho) => Image.asset(
        caminho,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => CustomPaint(painter: PintorArteFamilia(definicao.familia)),
      );
}
