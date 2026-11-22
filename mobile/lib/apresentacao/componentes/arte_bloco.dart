// Arte do bloco: miniatura (quando há uma para a uri/nome) ou arte própria
// da família. Desligado = a imagem de bypass da pedaleira, quando existe;
// senão esmaecido e em cinza. Nos dois casos vai por cima o mesmo selo "OFF":
// algumas imagens de bypass são quase pretas e sozinhas somem no case.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/arte/indice_miniaturas.dart';
import '../../aplicacao/arte/tons_tone3000.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import 'pintor_arte_familia.dart';

/// O tom/arquivo que o bloco carrega (TONE3000, neural, IR do usuário), pelo
/// título de fábrica quando há; nulo nos outros blocos.
String? nomeDoModeloNoBloco(WidgetRef ref, BlocoPreset bloco) => nomeDoModeloCarregado(
    bloco.uri, bloco.arquivoDeIr, ref.watch(indiceMiniaturasProvider).value?.tons ?? TonsTone3000.vazio);

class ArteBlocoWidget extends ConsumerWidget {
  const ArteBlocoWidget(
      {super.key, required this.definicao, required this.tamanho, this.ligado = true, this.arquivoIr});

  final DefinicaoBloco definicao;
  final double tamanho;
  final bool ligado;

  /// Gabinete: o IR escolhido no bloco decide a foto do modelo (Darkglass Suite).
  final String? arquivoIr;

  static const _cinza = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indice = ref.watch(indiceMiniaturasProvider).value;
    final arte = indice?.arteDe(definicao, arquivoIr: arquivoIr) ?? ArteDaFamilia(definicao.familia);
    if (ligado) return SizedBox.square(dimension: tamanho, child: _desenho(arte));
    return SizedBox.square(
      dimension: tamanho,
      child: Stack(fit: StackFit.expand, children: [
        _apagado(arte),
        const Align(alignment: Alignment.bottomRight, child: _SeloDesligado()),
      ]),
    );
  }

  /// A imagem de bypass da pedaleira, se houver; senão a arte em cinza.
  Widget _apagado(ArteBloco arte) {
    if (arte is ArteMiniatura && arte.caminhoDesligado != null) return _imagem(arte.caminhoDesligado!);
    return Opacity(
      opacity: Opacidades.blocoDesligado,
      child: ColorFiltered(colorFilter: _cinza, child: _desenho(arte)),
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

/// "OFF" como o LED apagado da pedaleira: o mesmo em toda arte desligada.
class _SeloDesligado extends StatelessWidget {
  const _SeloDesligado();

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('selo-desligado'),
        height: Medidas.seloDesligadoAltura,
        padding: const EdgeInsets.symmetric(horizontal: Espacos.xs),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Cores.fundoCase,
          borderRadius: BorderRadius.circular(Raios.canto),
          border: Border.all(color: Cores.ledDesligado),
        ),
        child: Text(
          AppLocalizations.of(context).uiSeloDesligado,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Cores.aluminioClaro, height: 1),
        ),
      );
}
