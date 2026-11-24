// Os módulos da tela do Axioma, um por seção, no desenho da pedaleira. Todo
// controle passa pelo ControleNoPainel (ao vivo, cena ativa, segurar para
// voltar ao padrão com desfazer), igual ao painel comum; os desenhos só leem
// os valores da cena e acendem em neon.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/desenho_sintetizador.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'controle_no_painel.dart';
import 'controle_parametro.dart';
import 'desenhos_sintetizador.dart';
import 'tela_pedaleira/modulo_neon.dart';
import 'tela_pedaleira/neon.dart';

class SecoesSintetizador {
  const SecoesSintetizador(
      {required this.arranjo, required this.bloco, required this.definicao, required this.cena, required this.cores});

  final ArranjoSintetizador arranjo;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final Paleta cores;

  Color get _cor => cores.daFamilia(definicao.familia);

  static const _alturaTela = 96.0;

  num valor(String simbolo) {
    final p = definicao.parametro(simbolo);
    return p == null ? 0 : ControleNoPainel.valorNaCena(bloco, p, cena);
  }

  /// O parâmetro e o valor dele na cena (para os medidores).
  (DefinicaoParametro, num)? comValor(String simbolo) {
    final p = definicao.parametro(simbolo);
    return p == null ? null : (p, valor(simbolo));
  }

  ArranjoSecao _arranjoDa(SecaoSintetizador secao) => arranjo.secoes.firstWhere((s) => s.secao == secao);

  /// O módulo de uma seção (os osciladores têm o próprio: [osciladores]).
  Widget modulo(BuildContext context, SecaoSintetizador secao, {double? largura}) {
    final arranjoSecao = _arranjoDa(secao);
    final ligada = arranjoSecao.chave == null || DefinicaoParametro.estaLigado(valor(arranjoSecao.chave!));
    final controles = [for (final c in arranjoSecao.controles) ?_controle(c)];
    return ModuloNeon(
      key: ValueKey('ax-${secao.name}'),
      titulo: _tituloDoModulo(AppLocalizations.of(context), arranjoSecao),
      largura: largura,
      chave: arranjoSecao.chave == null ? null : _chave(arranjoSecao.chave!, ligada),
      apagada: !ligada,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (_desenho(context, secao) case final desenho?) ...[desenho, const SizedBox(height: Espacos.m)],
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: Espacos.s,
          runSpacing: Espacos.m,
          children: controles,
        ),
      ]),
    );
  }

  /// O filtro leva os nomes dos três controles, como a faixa da pedaleira.
  String _tituloDoModulo(AppLocalizations l, ArranjoSecao secao) => secao.secao == SecaoSintetizador.filtro
      ? secao.controles.map((c) => c.rotulo).join('  ·  ')
      : tituloDaSecao(l, secao.secao);

  /// O filtro e o envelope ganham a curva em neon.
  Widget? _desenho(BuildContext context, SecaoSintetizador secao) {
    final brilho = BrilhoNeon.of(context);
    return switch (secao) {
      SecaoSintetizador.filtro => CaixaDesenho(
          key: const ValueKey('ax-desenho-filtro'),
          altura: _alturaTela,
          pintor: PintorFiltro(
              cores: cores, corte: valor(arranjo.corte), ressonancia: valor(arranjo.ressonancia), cor: _cor, brilho: brilho)),
      SecaoSintetizador.envelope => CaixaDesenho(
          key: const ValueKey('ax-desenho-envelope'),
          altura: _alturaTela,
          pintor: PintorEnvelope(
              cores: cores,
              ataque: valor(arranjo.ataque),
              decaimento: valor(arranjo.decaimento),
              liberacao: valor(arranjo.liberacao),
              cor: _cor,
              brilho: brilho)),
      _ => null,
    };
  }

  /// Um módulo por oscilador ("Osc 1 Vol", "Osc 2 Vol", "Sub Osc Vol"): a
  /// onda escolhida grande, em neon, o seletor dela e os controles.
  Widget moduloOscilador(BuildContext context, OsciladorSynth o, double largura) {
    final onda = o.onda == null ? null : definicao.parametro(o.onda!);
    final forma = onda == null || onda.opcoes.isEmpty ? null : formaDaOpcao(onda.opcoes[onda.indiceOpcao(valor(onda.simbolo))]);
    final interno = largura - ModuloNeon.recuoInterno * 2;
    return ModuloNeon(
      key: ValueKey('ax-modulo-${o.titulo}'),
      titulo: o.rotuloModulo,
      largura: largura,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        CaixaDesenho(
          key: ValueKey('ax-onda-${o.onda}'),
          altura: _alturaTela,
          pintor: forma == null
              ? PintorTelaVazia(cores: cores)
              : PintorOnda(cores: cores, forma: forma, cor: _cor, brilho: BrilhoNeon.of(context)),
        ),
        const SizedBox(height: Espacos.s),
        if (onda != null) _noPainel(onda, 'Wave', interno, seletor: true),
        Wrap(alignment: WrapAlignment.spaceEvenly, crossAxisAlignment: WrapCrossAlignment.end, spacing: Espacos.s, children: [
          for (final c in o.controles) ?_controle(c),
        ]),
      ]),
    );
  }

  List<OsciladorSynth> get osciladores => _arranjoDa(SecaoSintetizador.osciladores).osciladores;

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

  /// A chave da seção na faixa do título (o arpejador), pelo mesmo caminho do editor.
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
