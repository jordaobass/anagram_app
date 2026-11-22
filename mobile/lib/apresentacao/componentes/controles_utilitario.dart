// Os controles próprios dos painéis da bateria e do metrônomo: a fileira de
// botões (o compasso, com os tempos desenhados), o DISPARAR do Action e o
// BATER do tap tempo. Todo valor gravado passa pelo ControleNoPainel.alterar,
// o mesmo caminho dos knobs (ao vivo, cena, desfazer, "não salvo").
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_utilitario.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/toque_de_tempo.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'botao_opcao.dart';
import 'controle_no_painel.dart';
import 'explicacao_parametro.dart';

/// As opções numa fileira de botões; num compasso ("6/8"), os tempos
/// desenhados embaixo, com o 1 acentuado.
class BotoesDeOpcao extends ConsumerWidget {
  const BotoesDeOpcao({super.key, required this.parametro, required this.bloco, required this.valor, required this.cor});

  final DefinicaoParametro parametro;
  final BlocoPreset bloco;
  final num valor;
  final Color cor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atual = parametro.indiceOpcao(valor);
    // sem opções (catálogo novo, arquivo mexido) fica só o rótulo
    final tempos = parametro.opcoes.isEmpty ? null : temposDoCompasso(parametro.opcoes[atual]);
    return SizedBox(
      width: Medidas.larguraBotoesUtilitario,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        RotuloParametro(parametro: parametro, texto: parametro.nome),
        const SizedBox(height: Espacos.xs),
        Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [
          for (var i = 0; i < parametro.opcoes.length; i++)
            SizedBox(
              key: ValueKey('opcao-${parametro.simbolo}-$i'),
              width: Medidas.larguraBotaoCompasso,
              child: BotaoOpcao(
                texto: parametro.opcoes[i],
                marcada: i == atual,
                cor: cor,
                estreito: true,
                aoTocar: () => ControleNoPainel.alterar(ref, parametro, bloco)(parametro.valorDaOpcao(i), arrastando: false),
              ),
            ),
        ]),
        if (tempos != null) ...[const SizedBox(height: Espacos.s), PontosDoCompasso(tempos: tempos, cor: cor)],
      ]),
    );
  }
}

/// Um ponto por tempo, o acentuado maior e cheio. Ilustração do compasso
/// escolhido, sem andar no tempo (a batida real só a pedaleira sabe).
class PontosDoCompasso extends StatelessWidget {
  const PontosDoCompasso({super.key, required this.tempos, required this.cor});

  final List<bool> tempos;
  final Color cor;

  @override
  Widget build(BuildContext context) => Semantics(
        label: AppLocalizations.of(context).utTemposDoCompasso(tempos.length),
        child: ExcludeSemantics(
          child: Wrap(
            key: const ValueKey('pontos-compasso'),
            spacing: Espacos.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [for (final acento in tempos) _ponto(acento)],
          ),
        ),
      );

  Widget _ponto(bool acento) {
    final lado = acento ? Medidas.pontoCompassoAcento : Medidas.pontoCompasso;
    return Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: acento ? cor : null,
        border: Border.all(color: acento ? cor : Cores.aluminio, width: Medidas.contornoSelecao),
      ),
    );
  }
}

/// O DISPARAR do Action: um toque ao vivo (1 e logo 0) que não entra no
/// preset. Sem ao vivo não há o que tocar, e o botão diz por quê.
class BotaoPulso extends ConsumerWidget {
  const BotaoPulso({super.key, required this.parametro, required this.bloco});

  final DefinicaoParametro parametro;
  final BlocoPreset bloco;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final aoVivo = ref.watch(editorProvider.select((e) => e.aoVivo));
    final editor = ref.read(editorProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      FilledButton(
        key: ValueKey('pulso-${parametro.simbolo}'),
        onPressed: aoVivo ? () => editor.pulsar(bloco.posicao, parametro.simbolo) : null,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(Medidas.alvoMinimo)),
        child: Text(l.utDisparar.toUpperCase()),
      ),
      const SizedBox(height: Espacos.s),
      notaDoCartao(context, aoVivo ? l.utGestosAcao : l.utDispararSemAoVivo),
    ]);
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
      style: OutlinedButton.styleFrom(minimumSize: const Size(Medidas.larguraBotaoCompasso, Medidas.alvoMinimo)),
      child: Text(l.utBater.toUpperCase()),
    );
    if (widget.habilitado) return botao;
    return SizedBox(
      width: Medidas.larguraSeletorSynth,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        botao,
        const SizedBox(height: Espacos.xs),
        notaDoCartao(context, l.utBaterSoNoFixo),
      ]),
    );
  }
}

/// A frase discreta de apoio (o gesto, o motivo, o que só o visor mostra).
Widget notaDoCartao(BuildContext context, String texto) => Text(texto,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario));
