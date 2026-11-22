// Uma opção de parâmetro como botão: a marcada preenchida na cor da família
// do bloco, as outras em contorno. Os botões empilhados do painel comum e a
// fileira de compassos do metrônomo usam o mesmo.
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
  Widget build(BuildContext context) => Semantics(
        selected: marcada,
        button: true,
        child: marcada
            ? FilledButton(
                onPressed: aoTocar,
                style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: Cores.tintaMarcador, padding: _margem),
                child: _rotulo(),
              )
            : OutlinedButton(onPressed: aoTocar, style: OutlinedButton.styleFrom(padding: _margem), child: _rotulo()),
      );

  /// Rótulo inteiro, encolhendo se a coluna for estreita (nada de "Deslig…").
  Widget _rotulo() => FittedBox(fit: BoxFit.scaleDown, child: Text(texto, maxLines: 1));
}
