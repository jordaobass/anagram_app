// Global EQ da pedaleira: a curva com um ponto por banda, que se arrasta em
// frequência × ganho, e os knobs das mesmas bandas para digitar o valor
// exato. "Plano" zera os ganhos (como o Reset da tela da Anagram).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'controles_ajuste.dart';
import 'pintor_global_eq.dart';

class CartaoGlobalEq extends ConsumerStatefulWidget {
  const CartaoGlobalEq({super.key});

  @override
  ConsumerState<CartaoGlobalEq> createState() => _CartaoGlobalEqState();
}

class _CartaoGlobalEqState extends ConsumerState<CartaoGlobalEq> {
  int? _ativa;

  /// As bandas com chave conhecida, com o valor da tela (o mexido ou o lido).
  List<(DefinicaoAjuste, DefinicaoAjuste, BandaGlobalEq)> _bandas(EstadoAjustes estado) => [
        for (final (tipo, idFreq, idGanho) in bandasGlobalEq)
          if ((ajustePorIdOuChave(idFreq), ajustePorIdOuChave(idGanho)) case (final f?, final g?)
              when f.confirmado && g.confirmado)
            (f, g, BandaGlobalEq(tipo, (estado.valor(f) ?? f.padrao).toDouble(), (estado.valor(g) ?? g.padrao).toDouble())),
      ];

  void _arrastar(Offset local, Size tamanho, {bool comecando = false}) {
    final bandas = _bandas(ref.read(controladorAjustesProvider));
    final g = GeometriaGlobalEq(tamanho);
    if (comecando) _ativa = _maisPerto(bandas.map((b) => g.ponto(b.$3)).toList(), local);
    final i = _ativa;
    if (i == null) return;
    final controlador = ref.read(controladorAjustesProvider.notifier);
    controlador.alterar(bandas[i].$1, g.frequencia(local.dx));
    controlador.alterar(bandas[i].$2, g.ganho(local.dy));
    setState(() {});
  }

  static int? _maisPerto(List<Offset> pontos, Offset alvo) {
    int? melhor;
    var menor = Medidas.alcancePontoEq;
    for (var i = 0; i < pontos.length; i++) {
      final d = (pontos[i] - alvo).distance;
      if (d <= menor) (melhor, menor) = (i, d);
    }
    return melhor;
  }

  void _plano(List<(DefinicaoAjuste, DefinicaoAjuste, BandaGlobalEq)> bandas) {
    final controlador = ref.read(controladorAjustesProvider.notifier);
    for (final b in bandas) {
      controlador.alterar(b.$2, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bandas = _bandas(ref.watch(controladorAjustesProvider));
    return CartaoSecaoSynth(
      titulo: l.pdGlobalEq,
      largura: double.infinity,
      chave: TextButton(key: const ValueKey('eq-plano'), onPressed: () => _plano(bandas), child: Text(l.pdEqPlano)),
      desenho: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _curva(bandas),
        const SizedBox(height: Espacos.xs),
        Text(l.pdEqDica, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      ]),
      filhos: [
        for (final b in bandas) ...[
          ControleAjuste(definicao: b.$1),
          ControleAjuste(definicao: b.$2),
        ],
        AvisoErroAjustes(ids: {for (final b in bandas) ...[b.$1.id, b.$2.id]}),
      ],
    );
  }

  Widget _curva(List<(DefinicaoAjuste, DefinicaoAjuste, BandaGlobalEq)> bandas) => SizedBox(
        height: Medidas.alturaCurvaGlobalEq,
        child: LayoutBuilder(builder: (context, restricoes) {
          final tamanho = Size(restricoes.maxWidth, Medidas.alturaCurvaGlobalEq);
          // arraste vertical e horizontal (não "pan"): assim o ponto vence o
          // rolar da tela, como os knobs; a posição inteira vale nos dois eixos
          return GestureDetector(
            key: const ValueKey('curva-global-eq'),
            // o ponto pego é o do toque, não o de onde o dedo já tinha andado
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onVerticalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onVerticalDragEnd: (_) => setState(() => _ativa = null),
            onHorizontalDragStart: (d) => _arrastar(d.localPosition, tamanho, comecando: true),
            onHorizontalDragUpdate: (d) => _arrastar(d.localPosition, tamanho),
            onHorizontalDragEnd: (_) => setState(() => _ativa = null),
            child: CustomPaint(size: tamanho, painter: PintorGlobalEq([for (final b in bandas) b.$3], ativa: _ativa)),
          );
        }),
      );
}
