// Os cartões do painel do synth, um por seção. Todo controle passa pelo
// ControleNoPainel (ao vivo, cena ativa, segurar para voltar ao padrão com
// desfazer), igual ao painel comum; os desenhos só leem os valores da cena.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/desenho_sintetizador.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cartao_secao_synth.dart';
import 'controle_no_painel.dart';
import 'controle_parametro.dart';
import 'desenhos_sintetizador.dart';

class SecoesSintetizador {
  const SecoesSintetizador(
      {required this.arranjo, required this.bloco, required this.definicao, required this.cena, required this.cores});

  final ArranjoSintetizador arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final Paleta cores;

  Color get _cor => cores.daFamilia(definicao.familia);

  num _valor(String simbolo) {
    final p = definicao.parametro(simbolo);
    return p == null ? 0 : ControleNoPainel.valorNaCena(bloco, p, cena);
  }

  ArranjoSecao _arranjoDa(SecaoSintetizador secao) => arranjo.secoes.firstWhere((s) => s.secao == secao);

  Widget cartao(BuildContext context, SecaoSintetizador secao, double largura) {
    final arranjoSecao = _arranjoDa(secao);
    final ligada = arranjoSecao.chave == null || DefinicaoParametro.estaLigado(_valor(arranjoSecao.chave!));
    return CartaoSecaoSynth(
      key: ValueKey('ax-${secao.name}'),
      titulo: tituloDaSecao(AppLocalizations.of(context), secao),
      largura: largura,
      chave: arranjoSecao.chave == null ? null : _chave(arranjoSecao.chave!, ligada),
      apagada: !ligada,
      alinharTopo: secao == SecaoSintetizador.osciladores,
      desenho: _desenho(secao),
      filhos: secao == SecaoSintetizador.osciladores
          ? [for (final o in arranjoSecao.osciladores) _oscilador(context, o)]
          : [for (final c in arranjoSecao.controles) ?_controle(c)],
    );
  }

  /// O filtro e o envelope ganham a curva; a onda vai dentro de cada oscilador.
  Widget? _desenho(SecaoSintetizador secao) => switch (secao) {
        SecaoSintetizador.filtro => CaixaDesenho(
            key: const ValueKey('ax-desenho-filtro'),
            pintor: PintorFiltro(cores: cores, corte: _valor(arranjo.corte), ressonancia: _valor(arranjo.ressonancia), cor: _cor)),
        SecaoSintetizador.envelope => CaixaDesenho(
            key: const ValueKey('ax-desenho-envelope'),
            pintor: PintorEnvelope(
                cores: cores,
                ataque: _valor(arranjo.ataque),
                decaimento: _valor(arranjo.decaimento),
                liberacao: _valor(arranjo.liberacao),
                cor: _cor)),
        _ => null,
      };

  /// Um oscilador numa coluna: título, a onda escolhida desenhada, o seletor
  /// dela e os controles do oscilador.
  Widget _oscilador(BuildContext context, OsciladorSynth o) {
    final onda = o.onda == null ? null : definicao.parametro(o.onda!);
    final forma = onda == null || onda.opcoes.isEmpty
        ? null
        : formaDaOpcao(onda.opcoes[onda.indiceOpcao(_valor(onda.simbolo))]);
    return SizedBox(
      width: Medidas.larguraOsciladorSynth,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text(o.titulo.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Espacos.xs),
        if (forma != null) ...[
          CaixaDesenho(key: ValueKey('ax-onda-${o.onda}'), pintor: PintorOnda(cores: cores, forma: forma, cor: _cor)),
          const SizedBox(height: Espacos.s),
        ],
        if (onda != null) _noPainel(onda, 'Wave', Medidas.larguraOsciladorSynth, seletor: true),
        Wrap(alignment: WrapAlignment.spaceEvenly, crossAxisAlignment: WrapCrossAlignment.end, children: [
          for (final c in o.controles) ?_controle(c),
        ]),
      ]),
    );
  }

  Widget? _controle(ControleSynth c) {
    final p = definicao.parametro(c.simbolo);
    if (p == null) return null;
    final seletor = c.tipo == TipoControleSynth.seletor;
    return _noPainel(p, c.rotulo, seletor ? Medidas.larguraSeletorSynth : Medidas.knobSynth,
        seletor: seletor, fader: c.tipo == TipoControleSynth.fader);
  }

  Widget controleSolto(DefinicaoParametro p) => _noPainel(p, null, Medidas.knobSynth);

  Widget _noPainel(DefinicaoParametro p, String? rotulo, double tamanho, {bool seletor = false, bool fader = false}) =>
      ControleNoPainel(
        parametro: p,
        rotulo: rotulo,
        bloco: bloco,
        definicao: definicao,
        cena: cena,
        tamanho: tamanho,
        seletor: seletor,
        forma: fader ? FormaControle.fader : FormaControle.knob,
      );

  /// A chave da seção no título (o arpejador), pelo mesmo caminho do editor.
  Widget _chave(String simbolo, bool ligada) => Consumer(builder: (context, ref, _) {
        final p = definicao.parametro(simbolo);
        if (p == null) return const SizedBox.shrink();
        final l = AppLocalizations.of(context);
        return ChaveParametro(
          chave: ValueKey('chave-$simbolo'),
          nome: p.nome,
          parametro: p,
          ligado: ligada,
          cor: _cor,
          texto: ligada ? l.valorLigado : l.valorDesligado,
          aoMudar: (novo) => ControleNoPainel.alterar(ref, p, bloco)(novo ? 1 : 0, arrastando: false),
        );
      });
}

String tituloDaSecao(AppLocalizations l, SecaoSintetizador secao) => switch (secao) {
      SecaoSintetizador.entrada => l.axEntrada,
      SecaoSintetizador.osciladores => l.axOsciladores,
      SecaoSintetizador.filtro => l.axFiltro,
      SecaoSintetizador.envelope => l.axEnvelope,
      SecaoSintetizador.arpejador => l.axArpejador,
      SecaoSintetizador.saida => l.axSaida,
    };
