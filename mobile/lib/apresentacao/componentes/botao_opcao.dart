// Uma opção de parâmetro como botão: a marcada preenchida na cor da família
// do bloco, as outras em contorno. Os botões empilhados do painel comum e a
// fileira de compassos do metrônomo usam o mesmo.
// Família de cor neutra (utilitário, gabinete): preenchida, a marcada parecia
// desabilitada; aí ela fica no painel elevado, com contorno âmbar e um check.
import 'package:flutter/material.dart';

import '../tema/tokens.dart';

class BotaoOpcao extends StatelessWidget {
  const BotaoOpcao(
      {super.key, required this.texto, required this.marcada, required this.cor, required this.aoTocar, this.estreito = false});

  final String texto;
  final bool marcada;
  final Color cor;
  final VoidCallback aoTocar;

  /// Botão curto numa fileira (os compassos): a margem lateral encolhe para
  /// "12/8" caber sem diminuir a letra.
  final bool estreito;

  EdgeInsetsGeometry? get _margem => estreito ? const EdgeInsets.symmetric(horizontal: Espacos.s) : null;

  @override
  Widget build(BuildContext context) => Semantics(selected: marcada, button: true, child: _botao(context.cores));

  Widget _botao(Paleta cores) {
    if (!marcada) {
      return OutlinedButton(onPressed: aoTocar, style: OutlinedButton.styleFrom(padding: _margem), child: _rotulo());
    }
    if (Paleta.pareceDesabilitada(cor)) {
      return OutlinedButton(
        onPressed: aoTocar,
        style: OutlinedButton.styleFrom(
          backgroundColor: cores.painelElevado,
          foregroundColor: cores.texto,
          side: BorderSide(color: cores.tallyTinta, width: Medidas.contornoSelecao),
          padding: _margem,
        ),
        child: _rotulo(marca: true),
      );
    }
    return FilledButton(
      onPressed: aoTocar,
      style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: cores.tintaMarcador, padding: _margem),
      child: _rotulo(),
    );
  }

  /// Rótulo inteiro, encolhendo se a coluna for estreita (nada de "Deslig…").
  Widget _rotulo({bool marca = false}) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (marca) ...[const Icon(Icons.check, size: Medidas.iconeMarcaOpcao), const SizedBox(width: Espacos.xs)],
          Text(texto, maxLines: 1),
        ]),
      );
}
