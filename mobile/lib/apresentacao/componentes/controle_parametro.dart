// Escolhe o controle certo para o parâmetro: interruptor para liga/desliga,
// botões segmentados para poucas opções, knob para o resto.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart';

class ControleParametro extends StatelessWidget {
  const ControleParametro({
    super.key,
    required this.parametro,
    required this.valor,
    required this.cor,
    required this.tamanho,
    required this.aoMudar,
  });

  static const maximoSegmentos = 3;

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final double tamanho;
  final AoMudarValor aoMudar;

  @override
  Widget build(BuildContext context) {
    if (parametro.alternavel) return _escolha(context, const ['Desligado', 'Ligado']);
    if (parametro.opcoes.isNotEmpty && parametro.opcoes.length <= maximoSegmentos) {
      return _escolha(context, parametro.opcoes);
    }
    return BotaoGiratorio(parametro: parametro, valor: valor, cor: cor, tamanho: tamanho, aoMudar: aoMudar);
  }

  Widget _escolha(BuildContext context, List<String> opcoes) {
    final atual = parametro.alternavel ? (DefinicaoParametro.estaLigado(valor) ? 1 : 0) : parametro.indiceOpcao(valor);
    final tema = Theme.of(context).textTheme;
    return SizedBox(
      width: tamanho + Espacos.l,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(parametro.nome.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: tema.labelMedium),
        const SizedBox(height: Espacos.xs),
        for (var i = 0; i < opcoes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Espacos.xs),
            child: _opcao(opcoes[i], i == atual, () {
              final novo = parametro.alternavel ? i : parametro.valorDaOpcao(i);
              aoMudar(novo, arrastando: false);
            }),
          ),
      ]),
    );
  }

  Widget _opcao(String texto, bool marcada, VoidCallback aoTocar) => Semantics(
        selected: marcada,
        button: true,
        child: SizedBox(
          width: double.infinity,
          child: marcada
              ? FilledButton(
                  onPressed: aoTocar,
                  style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: Cores.tintaMarcador),
                  child: _rotulo(texto),
                )
              : OutlinedButton(onPressed: aoTocar, child: _rotulo(texto)),
        ),
      );

  /// Rótulo inteiro, encolhendo se a coluna for estreita (nada de "Deslig…").
  static Widget _rotulo(String texto) => FittedBox(fit: BoxFit.scaleDown, child: Text(texto, maxLines: 1));
}
