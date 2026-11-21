// Global EQ da pedaleira, como a tela dela: o seletor de modo (ganho em
// verde, frequência em roxo, largura em laranja), a curva somada das 6
// bandas na cor do modo, com um ponto por banda que se arrasta em
// frequência × ganho, e as 6 bandas com o valor do modo. "Input Gain" leva
// ao cartão Entrada; "Reset" volta aos padrões de fábrica, com desfazer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'controles_ajuste.dart';
import 'dialogo_confirmar.dart';
import 'curva_eq_arrastavel.dart';
import 'fileira_bandas_eq.dart';

class CartaoGlobalEq extends ConsumerStatefulWidget {
  const CartaoGlobalEq({super.key, this.aoIrParaEntrada});

  final VoidCallback? aoIrParaEntrada;

  @override
  ConsumerState<CartaoGlobalEq> createState() => _CartaoGlobalEqState();
}

class _CartaoGlobalEqState extends ConsumerState<CartaoGlobalEq> {
  ModoEq _modo = ModoEq.gain;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bandas = bandasDaTela(ref.watch(controladorAjustesProvider));
    return CartaoSecaoSynth(
      key: const ValueKey('cartao-global-eq'),
      titulo: l.pdGlobalEq,
      largura: double.infinity,
      chave: _acoes(l),
      desenho: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SeletorModoEq(modo: _modo, aoEscolher: (m) => setState(() => _modo = m)),
        const SizedBox(height: Espacos.s),
        _curva(bandas),
        const SizedBox(height: Espacos.xs),
        Text(l.pdEqDica, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      ]),
      filhos: [
        FileiraBandasEq(modo: _modo),
        AvisoErroAjustes(ids: {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a.id}),
      ],
    );
  }

  Widget _acoes(AppLocalizations l) => Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(key: const ValueKey('eq-input-gain'), onPressed: widget.aoIrParaEntrada, child: Text(l.pdEqInputGain)),
        TextButton(key: const ValueKey('eq-reset'), onPressed: _reset, child: Text(l.pdEqReset)),
      ]);

  /// Pergunta, volta as 18 chaves ao padrão de fábrica e oferece desfazer.
  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final sim = await confirmar(context,
        titulo: l.pdEqResetTitulo,
        texto: l.pdEqResetTexto,
        rotuloCancelar: l.cancelar,
        rotuloConfirmar: l.pdEqResetConfirmar,
        chaveConfirmar: const ValueKey('confirmar-reset-eq'));
    if (!sim || !mounted) return;
    final controlador = ref.read(controladorAjustesProvider.notifier);
    final estado = ref.read(controladorAjustesProvider);
    final antes = {for (final a in ajustesConfirmados(GrupoAjuste.globalEq)) a: estado.valor(a) ?? a.padrao};
    antes.forEach((a, _) => controlador.alterar(a, a.padrao));
    mensageiro.showSnackBar(SnackBar(
      content: Text(l.pdEqResetFeito),
      action: SnackBarAction(label: l.desfazer, onPressed: () => antes.forEach(controlador.alterar)),
    ));
  }

  /// Arrastar o ponto da banda [i] muda frequência e ganho dela. Os ajustes
  /// globais vão a cada mudança (sem janela de arraste), então o soltar repete o último.
  void _arrastar(int i, double frequencia, double ganho, {required bool arrastando}) {
    final controlador = ref.read(controladorAjustesProvider.notifier);
    final banda = bandasEqGlobal[i];
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.freq))!, frequencia);
    controlador.alterar(ajustePorIdOuChave(banda.id(ModoEq.gain))!, ganho);
  }

  Widget _curva(List<BandaGlobalEq> bandas) => CurvaEqArrastavel(
        key: const ValueKey('curva-global-eq'),
        bandas: bandas,
        cor: Cores.doModoEq(_modo),
        aoArrastar: _arrastar,
      );
}

/// As 6 bandas com o valor da tela (o mexido ou o lido; sem leitura, o padrão).
List<BandaGlobalEq> bandasDaTela(EstadoAjustes estado) => [
      for (final banda in bandasEqGlobal)
        BandaGlobalEq(
          banda.tipo,
          _valor(estado, banda, ModoEq.freq),
          _valor(estado, banda, ModoEq.gain),
          _valor(estado, banda, ModoEq.width),
        ),
    ];

double _valor(EstadoAjustes estado, BandaEqGlobal banda, ModoEq modo) {
  final a = ajustePorIdOuChave(banda.id(modo))!;
  return (estado.valor(a) ?? a.padrao).toDouble();
}

/// Os três modos, botões de ícone na cor de cada um, como o canto da tela da
/// Anagram: o escolhido fica cheio, os outros só com o contorno.
class SeletorModoEq extends StatelessWidget {
  const SeletorModoEq({super.key, required this.modo, required this.aoEscolher});

  final ModoEq modo;
  final ValueChanged<ModoEq> aoEscolher;

  static IconData _icone(ModoEq m) => switch (m) {
        ModoEq.gain => Icons.unfold_more,
        ModoEq.freq => Icons.code,
        ModoEq.width => Icons.width_normal_outlined,
      };

  static String _nome(AppLocalizations l, ModoEq m) => switch (m) {
        ModoEq.gain => l.pdEqModoGanho,
        ModoEq.freq => l.pdEqModoFrequencia,
        ModoEq.width => l.pdEqModoLargura,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(children: [
      for (final m in ModoEq.values)
        Padding(
          padding: const EdgeInsets.only(right: Espacos.s),
          child: Tooltip(
            message: _nome(l, m),
            child: IconButton(
              key: ValueKey('modo-eq-${m.name}'),
              onPressed: () => aoEscolher(m),
              isSelected: m == modo,
              icon: Icon(_icone(m), color: m == modo ? Cores.textoSobreModoEq : Cores.doModoEq(m)),
              style: IconButton.styleFrom(
                backgroundColor: m == modo ? Cores.doModoEq(m) : Colors.transparent,
                side: BorderSide(color: Cores.doModoEq(m)),
              ),
            ),
          ),
        ),
      Text(_nome(l, modo), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Cores.textoDoModoEq(modo))),
    ]);
  }
}
