// Escolhe o controle certo para o parâmetro: chave para liga/desliga,
// botões para poucas opções, fader nas bandas do GEQ e knob para o resto.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart';
import 'botao_opcao.dart';
import 'explicacao_parametro.dart';
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
    this.corChip,
  });

  static const maximoSegmentos = 3;

  /// O valor num chip dessa cor (o modo do equalizador), como na pedaleira.
  final Color? corChip;

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
        parametro: parametro,
        valor: valor,
        cor: cor,
        tamanho: tamanho,
        aoMudar: aoMudar,
        rotulo: rotulo,
        forma: forma,
        corChipValor: corChip);
  }

  Widget _comTitulo(BuildContext context, Widget controle) => SizedBox(
        width: tamanho + Espacos.l,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RotuloParametro(parametro: parametro, texto: rotulo ?? parametro.nome),
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
          child: SizedBox(
            width: double.infinity,
            child: BotaoOpcao(
                texto: opcoes[i],
                marcada: i == atual,
                cor: cor,
                aoTocar: () => aoMudar(parametro.valorDaOpcao(i), arrastando: false)),
          ),
        ),
    ]);
  }
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
    this.parametro,
  });

  final Key? chave;

  /// Com ele, segurar (ou parar o mouse sobre) a chave explica o que ela faz;
  /// no meio dos knobs quem explica é o título, então ali ele fica de fora.
  final DefinicaoParametro? parametro;

  /// No meio dos knobs, o estado fica embaixo da chave, como o valor do knob;
  /// no título da banda, ao lado.
  final bool empilhada;
  final String nome;
  final bool ligado;
  final Color cor;
  final String texto;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    final explicado = parametro;
    final controle = _chave(context);
    return explicado == null ? controle : comExplicacao(context, explicado, controle, aoTocar: false);
  }

  Widget _chave(BuildContext context) => MergeSemantics(
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
                  activeThumbColor: context.cores.tintaMarcador,
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
      Theme.of(context).textTheme.titleMedium?.copyWith(color: ligado ? context.cores.texto : context.cores.textoSecundario);
}
