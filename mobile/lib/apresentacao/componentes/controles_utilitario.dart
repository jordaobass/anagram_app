// Os controles próprios dos painéis da bateria e do metrônomo, como na tela
// da Anagram: a lista rolante (a marcada entre as vizinhas), o rolo do
// compasso e o BATER do tap tempo. Todo valor gravado passa pelo
// ControleNoPainel.alterar, o mesmo caminho dos knobs (ao vivo, cena,
// desfazer, "não salvo").
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_utilitario.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/toque_de_tempo.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'botao_giratorio.dart' show AoMudarValor;
import 'botao_opcao.dart';
import 'controle_no_painel.dart';
import 'explicacao_parametro.dart';
import 'seletor_opcao.dart';

/// A lista do visor: a marcada (destacada) entre as vizinhas. Tocar numa
/// vizinha escolhe; tocar na marcada abre todas as opções.
class ListaRolante extends StatelessWidget {
  const ListaRolante({super.key, required this.parametro, required this.valor, required this.cor, required this.aoMudar});

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final AoMudarValor aoMudar;

  @override
  Widget build(BuildContext context) {
    final atual = parametro.indiceOpcao(valor);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Center(child: RotuloParametro(parametro: parametro, texto: parametro.nome)),
      const SizedBox(height: Espacos.xs),
      for (final i in opcoesVisiveis(parametro.opcoes.length, atual)) _linha(context, i, atual),
    ]);
  }

  Widget _linha(BuildContext context, int indice, int atual) {
    final simbolo = parametro.simbolo;
    if (indice == atual) {
      return BotaoOpcao(
        key: ValueKey('abrir-$simbolo'),
        texto: parametro.opcoes[indice],
        marcada: true,
        cor: cor,
        aoTocar: () => _abrir(context, atual),
      );
    }
    return TextButton(
      key: ValueKey('vizinha-$simbolo-$indice'),
      onPressed: () => aoMudar(parametro.valorDaOpcao(indice), arrastando: false),
      style: TextButton.styleFrom(foregroundColor: context.cores.textoSecundario, minimumSize: const Size.fromHeight(Medidas.alvoMinimo)),
      child: Text(parametro.opcoes[indice], maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Future<void> _abrir(BuildContext context, int atual) async {
    final escolhida = await escolherOpcao(context, parametro, atual);
    if (escolhida != null && escolhida != atual) aoMudar(parametro.valorDaOpcao(escolhida), arrastando: false);
  }
}

/// O rolo do compasso: a opção grande no meio ("4" sobre "4"), as vizinhas
/// apagadas dos lados. Tocar numa vizinha ou girar a roda do mouse anda uma;
/// tocar no meio abre todas.
class RoloOpcoes extends StatelessWidget {
  const RoloOpcoes({super.key, required this.parametro, required this.valor, required this.cor, required this.aoMudar});

  final DefinicaoParametro parametro;
  final num valor;
  final Color cor;
  final AoMudarValor aoMudar;

  @override
  Widget build(BuildContext context) {
    final atual = parametro.indiceOpcao(valor);
    final temOpcoes = parametro.opcoes.isNotEmpty;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      RotuloParametro(parametro: parametro, texto: parametro.nome),
      const SizedBox(height: Espacos.xs),
      if (temOpcoes)
        Listener(
          onPointerSignal: (evento) => _girar(evento, atual),
          child: Row(children: [
            _vizinha(context, atual - 1, 'anterior'),
            Expanded(child: _centro(context, atual)),
            _vizinha(context, atual + 1, 'proxima'),
          ]),
        ),
    ]);
  }

  void _escolher(int indice) {
    if (indice >= 0 && indice < parametro.opcoes.length) aoMudar(parametro.valorDaOpcao(indice), arrastando: false);
  }

  void _girar(PointerSignalEvent evento, int atual) {
    if (evento is PointerScrollEvent && evento.scrollDelta.dy != 0) _escolher(atual + evento.scrollDelta.dy.sign.toInt());
  }

  Widget _vizinha(BuildContext context, int indice, String lado) {
    final existe = indice >= 0 && indice < parametro.opcoes.length;
    return SizedBox(
      width: Medidas.alvoMinimo,
      height: Medidas.alturaRoloUtilitario,
      child: TextButton(
        key: ValueKey('$lado-${parametro.simbolo}'),
        onPressed: existe ? () => _escolher(indice) : null,
        style: TextButton.styleFrom(foregroundColor: context.cores.textoSecundario, padding: EdgeInsets.zero),
        child: existe ? FittedBox(child: Text(parametro.opcoes[indice])) : const SizedBox.shrink(),
      ),
    );
  }

  Widget _centro(BuildContext context, int atual) {
    final rotulo = parametro.opcoes[atual];
    final partes = rotulo.split('/');
    final estilo = Theme.of(context).textTheme.displaySmall;
    return Semantics(
      button: true,
      label: parametro.nome,
      value: rotulo,
      child: InkWell(
        key: ValueKey('abrir-${parametro.simbolo}'),
        borderRadius: BorderRadius.circular(Raios.controle),
        onTap: () => _abrir(context, atual),
        child: SizedBox(
          height: Medidas.alturaRoloUtilitario,
          child: FittedBox(
            child: ExcludeSemantics(
              child: Column(mainAxisSize: MainAxisSize.min, children: [for (final p in partes) Text(p, style: estilo)]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context, int atual) async {
    final escolhida = await escolherOpcao(context, parametro, atual);
    if (escolhida != null) _escolher(escolhida);
  }
}

/// O BATER do metrônomo: o app mede os toques e grava o BPM no Tempo. Só
/// vale no modo em que o knob vale; fora dele, desabilitado com o motivo.
class BotaoToque extends ConsumerStatefulWidget {
  const BotaoToque({super.key, required this.parametro, required this.bloco, required this.habilitado});

  final DefinicaoParametro parametro;
  final BlocoPreset bloco;
  final bool habilitado;

  @override
  ConsumerState<BotaoToque> createState() => _EstadoBotaoToque();
}

class _EstadoBotaoToque extends ConsumerState<BotaoToque> {
  final _toque = ToqueDeTempo();

  void _tocar() {
    final bpm = _toque.tocar(ref.read(relogioDoToqueProvider)());
    if (bpm == null) return;
    final p = widget.parametro;
    ControleNoPainel.alterar(ref, p, widget.bloco)(p.limitar(bpm), arrastando: false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final botao = OutlinedButton(
      key: ValueKey('toque-${widget.parametro.simbolo}'),
      onPressed: widget.habilitado ? _tocar : null,
      style: OutlinedButton.styleFrom(minimumSize: const Size(Medidas.larguraBotaoBater, Medidas.alvoMinimo)),
      child: Text(l.utBater.toUpperCase()),
    );
    // fora do Fixed Tempo, o motivo fica no próprio botão, sem crescer o cartão
    return widget.habilitado ? botao : Tooltip(message: l.utBaterSoNoFixo, child: botao);
  }
}

/// A frase discreta de apoio (o que só o visor mostra).
Widget notaDoCartao(BuildContext context, String texto) => Text(texto,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario));
