// A faixa de medidores sob a barra, como a da tela do Axioma: em cada ponta
// um visor, as barras e a minimontanha em arame; no meio, os anéis. Os
// medidores mostram valores de verdade do bloco (Sensitivity na entrada,
// Level na saída), não um nível de áudio que o app não recebe.
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/catalogo/definicao_bloco.dart';
import '../../tema/paletas_painel.dart';
import '../../tema/tokens.dart';
import '../../textos.dart';
import 'decoracao_axioma.dart';
import 'neon.dart';

class FaixaMedidores extends StatelessWidget {
  const FaixaMedidores({super.key, required this.entrada, required this.saida});

  final (DefinicaoParametro, num)? entrada;
  final (DefinicaoParametro, num)? saida;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        key: const ValueKey('ax-medidores'),
        builder: (context, restricoes) {
          final largura = restricoes.maxWidth;
          // no celular os dois medidores empilham, sem a minimontanha
          if (largura < _larguraEmLinha) {
            return Wrap(spacing: Espacos.m, runSpacing: Espacos.s, children: [
              if (entrada case final e?) _Medidor(parametro: e.$1, valor: e.$2, compacto: true),
              if (saida case final s?) _Medidor(parametro: s.$1, valor: s.$2, compacto: true),
            ]);
          }
          return SizedBox(
            height: 40,
            child: Row(children: [
              if (entrada case final e?) _Medidor(parametro: e.$1, valor: e.$2),
              const Spacer(),
              if (largura > _larguraComAneis) const ExcludeSemantics(child: _Aneis()),
              const Spacer(),
              if (saida case final s?) _Medidor(parametro: s.$1, valor: s.$2, espelhado: true),
            ]),
          );
        },
      );

  static const _larguraEmLinha = 780.0;
  static const _larguraComAneis = 720.0;
}

class _Medidor extends StatelessWidget {
  const _Medidor({required this.parametro, required this.valor, this.espelhado = false, this.compacto = false});

  final DefinicaoParametro parametro;
  final num valor;
  final bool espelhado;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final brilho = BrilhoNeon.of(context);
    final faixa = parametro.maximo - parametro.minimo;
    final fracao = faixa == 0 ? 0.0 : ((valor - parametro.minimo) / faixa).toDouble();
    final texto = AppLocalizations.of(context).valorDe(parametro, valor);
    final pecas = [
      Flexible(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
        decoration: BoxDecoration(color: CoresNeon.lcdFundo, border: Border.all(color: CoresNeon.ciano)),
        child: Text('${parametro.nome} $texto',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: Fontes.tecno, fontSize: 13, color: CoresNeon.lcdTinta)),
      )),
      const SizedBox(width: Espacos.s),
      ExcludeSemantics(
        child: SizedBox(width: 84, height: 26, child: CustomPaint(painter: PintorMedidor(fracao: fracao, apagado: context.cores.painelElevado, brilho: brilho))),
      ),
      if (!compacto) const SizedBox(width: Espacos.s),
      if (!compacto) ExcludeSemantics(
        child: SizedBox(width: 64, height: 32, child: CustomPaint(painter: PintorMontanhaArame(brilho: brilho, espelhada: espelhado))),
      ),
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: espelhado ? pecas.reversed.toList() : pecas);
  }
}

/// Os cinco anéis do meio da faixa.
class _Aneis extends StatelessWidget {
  const _Aneis();

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < 5; i++)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CoresNeon.furo,
              border: Border.all(color: CoresNeon.ciano, width: 1.5),
              boxShadow: [BoxShadow(color: CoresNeon.ciano.withValues(alpha: 0.5), blurRadius: 6 * BrilhoNeon.of(context))],
            ),
          ),
      ]);
}
