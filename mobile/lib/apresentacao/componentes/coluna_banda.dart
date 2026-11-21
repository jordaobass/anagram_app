// A coluna de uma banda do multibanda: fita da cor da banda, nome e faixa de
// frequência, a chave da compressão (Ignissor) e o Mute em cima; embaixo, os
// seletores, os faders e os knobs. Banda mutada continua ajustável, apagada.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'controle_no_painel.dart';
import 'controle_parametro.dart';

class ColunaBanda extends ConsumerWidget {
  const ColunaBanda({
    super.key,
    required this.arranjo,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.largura,
  });

  final ArranjoBanda arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final double largura;

  num _valor(DefinicaoParametro p) => ControleNoPainel.valorNaCena(bloco, p, cena);

  bool _ligado(String? simbolo, {required bool seAusente}) {
    final p = simbolo == null ? null : definicao.parametro(simbolo);
    return p == null ? seAusente : DefinicaoParametro.estaLigado(_valor(p));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muda = _ligado(arranjo.mudo, seAusente: false);
    return Container(
      key: ValueKey('coluna-${arranjo.banda.name}'),
      width: largura,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Raios.painel),
        border: Border.all(color: Cores.filete),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Container(height: Medidas.fitaCategoria, color: Cores.daBanda(arranjo.banda)),
        Padding(
          padding: const EdgeInsets.all(Espacos.m),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            _titulo(context, ref, muda),
            if (arranjo.chave != null) _chaveComp(context, ref),
            const SizedBox(height: Espacos.s),
            Opacity(opacity: muda ? Medidas.opacidadeBandaDesligada : 1, child: _controles()),
          ]),
        ),
      ]),
    );
  }

  Widget _titulo(BuildContext context, WidgetRef ref, bool muda) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.mbNomeDaBanda(arranjo.banda).toUpperCase(), style: tema.titleSmall),
          Text(_faixa(l), style: tema.labelSmall?.copyWith(color: Cores.textoSecundario)),
        ]),
      ),
      if (definicao.parametro(arranjo.mudo) case final mudo?) _botaoMudo(ref, l, mudo, muda),
    ]);
  }

  /// "20 Hz – 250 Hz": onde a banda age, pelos cortes de agora.
  String _faixa(AppLocalizations l) {
    String limite(String? simbolo, String borda) {
      final p = simbolo == null ? null : definicao.parametro(simbolo);
      return p == null ? borda : l.valorDe(p, _valor(p));
    }

    return '${limite(arranjo.inferior, l.mbBordaGraves)} – ${limite(arranjo.superior, l.mbBordaAgudos)}';
  }

  /// O Mute pinta de alerta quando corta a banda: é o estado que mais se
  /// esquece ligado e deixa o grave sumido sem motivo aparente.
  Widget _botaoMudo(WidgetRef ref, AppLocalizations l, DefinicaoParametro mudo, bool muda) {
    void alternar() => ControleNoPainel.alterar(ref, mudo, bloco)(muda ? 0 : 1, arrastando: false);
    return Semantics(
      toggled: muda,
      label: mudo.nome,
      child: muda
          ? FilledButton(
              key: ValueKey('mudo-${mudo.simbolo}'),
              onPressed: alternar,
              style: FilledButton.styleFrom(backgroundColor: Cores.fitaAlerta, foregroundColor: Cores.sobreAlerta),
              child: Text(l.mbMudo),
            )
          : OutlinedButton(key: ValueKey('mudo-${mudo.simbolo}'), onPressed: alternar, child: Text(l.mbMudo)),
    );
  }

  Widget _chaveComp(BuildContext context, WidgetRef ref) {
    final chave = definicao.parametro(arranjo.chave!);
    if (chave == null) return const SizedBox.shrink();
    final ligada = DefinicaoParametro.estaLigado(_valor(chave));
    final l = AppLocalizations.of(context);
    // a chave e o estado numa linha só, encolhendo se a coluna for estreita
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: ChaveParametro(
        chave: ValueKey('chave-${chave.simbolo}'),
        nome: chave.nome,
        ligado: ligada,
        cor: Cores.daFamilia(definicao.familia),
        texto: ligada ? l.mbCompLigada : l.mbCompDesligada,
        aoMudar: (novo) => ControleNoPainel.alterar(ref, chave, bloco)(novo ? 1 : 0, arrastando: false),
      ),
    );
  }

  Widget _controles() {
    final seletores = _doTipo(TipoControleBanda.seletor);
    final faders = _doTipo(TipoControleBanda.fader);
    final knobs = _doTipo(TipoControleBanda.knob);
    final interno = largura - Espacos.m * 2 - Medidas.filete * 2;
    // até dois cabem numa fileira; mais que isso, faders numa e knobs na
    // outra, para nenhum knob sobrar sozinho embaixo
    final fileiras = faders.length + knobs.length <= 2 ? [[...faders, ...knobs]] : [faders, knobs];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      for (final (c, p) in seletores)
        Padding(padding: const EdgeInsets.only(bottom: Espacos.s), child: _controle(c, p, interno)),
      for (final fileira in fileiras)
        Padding(
          padding: const EdgeInsets.only(top: Espacos.s),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: Espacos.s,
            runSpacing: Espacos.m,
            children: [for (final (c, p) in fileira) _controle(c, p, Medidas.knobBanda)],
          ),
        ),
    ]);
  }

  List<(ControleBanda, DefinicaoParametro)> _doTipo(TipoControleBanda tipo) => [
        for (final c in arranjo.controles)
          if (c.tipo == tipo)
            if (definicao.parametro(c.simbolo) case final p?) (c, p),
      ];

  Widget _controle(ControleBanda c, DefinicaoParametro p, double tamanho) => ControleNoPainel(
        parametro: p,
        rotulo: c.rotulo,
        bloco: bloco,
        definicao: definicao,
        cena: cena,
        tamanho: tamanho,
        seletor: c.tipo == TipoControleBanda.seletor,
        forma: c.tipo == TipoControleBanda.fader ? FormaControle.fader : FormaControle.knob,
      );
}
