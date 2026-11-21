// Escolhe o controle certo para o parâmetro: chave para liga/desliga,
// botões para poucas opções, fader nas bandas do GEQ e knob para o resto.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart';
import '../../l10n/app_localizations.dart';

class ControleParametro extends StatelessWidget {
  const ControleParametro({
    super.key,
    required this.parametro,
    required this.valor,
    required this.cor,
    required this.tamanho,
    required this.aoMudar,
    this.rotulo,
    this.forma = FormaControle.knob,
  });

  static const maximoSegmentos = 3;

  /// Nome curto dentro de um grupo (ver [BotaoGiratorio.rotulo]).
  final String? rotulo;
  final FormaControle forma;

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final double tamanho;
  final AoMudarValor aoMudar;

  @override
  Widget build(BuildContext context) {
    if (parametro.alternavel) return _comTitulo(context, _chave(context));
    if (parametro.opcoes.isNotEmpty && parametro.opcoes.length <= maximoSegmentos) {
      return _comTitulo(context, _escolha(parametro.opcoes));
    }
    return BotaoGiratorio(
        parametro: parametro, valor: valor, cor: cor, tamanho: tamanho, aoMudar: aoMudar, rotulo: rotulo, forma: forma);
  }

  Widget _comTitulo(BuildContext context, Widget controle) => SizedBox(
        width: tamanho + Espacos.l,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text((rotulo ?? parametro.nome).toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: Espacos.xs),
          controle,
        ]),
      );

  /// Liga/desliga é uma chave com o estado escrito ao lado: dois botões
  /// empilhados, com o "Desligado" pintado na cor da família, liam como ligado.
  Widget _chave(BuildContext context) {
    final ligado = DefinicaoParametro.estaLigado(valor);
    final l = AppLocalizations.of(context);
    return ChaveParametro(
      chave: ValueKey('chave-${parametro.simbolo}'),
      nome: parametro.nome,
      ligado: ligado,
      cor: cor,
      texto: ligado ? l.valorLigado : l.valorDesligado,
      empilhada: true,
      aoMudar: (novo) => aoMudar(novo ? 1 : 0, arrastando: false),
    );
  }

  Widget _escolha(List<String> opcoes) {
    final atual = parametro.indiceOpcao(valor);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < opcoes.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: Espacos.xs),
          child: _opcao(opcoes[i], i == atual, () => aoMudar(parametro.valorDaOpcao(i), arrastando: false)),
        ),
    ]);
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

/// A chave de um liga/desliga: usada no controle e no título das bandas do
/// paramétrico. Tocar no texto também muda, para o alvo não ser só a chave.
class ChaveParametro extends StatelessWidget {
  const ChaveParametro({
    super.key,
    this.chave,
    required this.nome,
    required this.ligado,
    required this.cor,
    required this.texto,
    required this.aoMudar,
    this.empilhada = false,
  });

  final Key? chave;

  /// No meio dos knobs, o estado fica embaixo da chave, como o valor do knob;
  /// no título da banda, ao lado.
  final bool empilhada;
  final String nome;
  final bool ligado;
  final Color cor;
  final String texto;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: Semantics(
          label: nome,
          child: InkWell(
            borderRadius: BorderRadius.circular(Raios.controle),
            onTap: () => aoMudar(!ligado),
            child: Flex(
              direction: empilhada ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  key: chave,
                  value: ligado,
                  onChanged: aoMudar,
                  activeThumbColor: Cores.tintaMarcador,
                  activeTrackColor: cor,
                ),
                const SizedBox(width: Espacos.xs, height: Espacos.xs),
                Text(texto, style: _estiloTexto(context)),
              ],
            ),
          ),
        ),
      );

  TextStyle? _estiloTexto(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(color: ligado ? Cores.texto : Cores.textoSecundario);
}
