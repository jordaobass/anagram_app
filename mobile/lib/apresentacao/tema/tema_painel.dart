// O tema visual da ÁREA DE CONFIGURAÇÃO de alguns blocos, com o espírito da
// tela que cada um tem na própria Anagram (pedido do dono, DECISOES PT):
// Ignissor e Entropia em alumínio escovado; Axioma em synthwave (roxo, neon
// ciano e magenta, molduras chanfradas). Só o painel do bloco muda: a moldura
// (moldura_tema_painel.dart) aplica um ThemeData derivado deste tema, e os
// controles de sempre (knob, fader, seletor, chave) se repintam sozinhos,
// porque pedem a cor pelo papel. Comportamento nenhum muda.
import 'package:flutter/material.dart';

import 'paletas_painel.dart';
import 'tokens.dart';

enum EstiloPainel { metal, neon }

@immutable
class TemaPainel extends ThemeExtension<TemaPainel> {
  const TemaPainel({
    required this.estilo,
    required this.paleta,
    required this.fundo,
    required this.reflexo,
    required this.friso,
  });

  /// O tema do bloco, ou nulo para quem usa o case de sempre.
  static TemaPainel? doBloco(String uri, Brightness brilho) => switch (uri) {
        'urn:darkglass:ignissor' => TemaPainel.metal(brilho, DestaquePainel.ignissor),
        'urn:darkglass:entropia' => TemaPainel.metal(brilho, DestaquePainel.entropia),
        'urn:darkglass:axioma_synth' => TemaPainel.neon(brilho),
        _ => null,
      };

  factory TemaPainel.metal(Brightness brilho, DestaquePainel destaque) {
    final paleta = PaletasPainel.metal(brilho, destaque);
    return TemaPainel(
      estilo: EstiloPainel.metal,
      paleta: paleta,
      fundo: PaletasPainel.fundoMetal(brilho),
      reflexo: PaletasPainel.reflexoMetal(brilho),
      friso: paleta.filete,
    );
  }

  factory TemaPainel.neon(Brightness brilho) => TemaPainel(
        estilo: EstiloPainel.neon,
        paleta: PaletasPainel.neon(brilho),
        fundo: PaletasPainel.fundoNeon(brilho),
        reflexo: PaletasPainel.gradeNeon(brilho),
        friso: PaletasPainel.frisoNeon(brilho),
      );

  final EstiloPainel estilo;
  final Paleta paleta;

  /// Gradiente do fundo da moldura, de cima para baixo.
  final List<Color> fundo;

  /// O que se pinta sobre o fundo, já com a opacidade: as ondas claras do
  /// alumínio ou a grade synthwave do neon.
  final Color reflexo;

  /// Traço de acento: os trilhos e o sublinhado dos títulos do neon.
  final Color friso;

  bool get ehNeon => estilo == EstiloPainel.neon;

  /// A cor do bloco dentro do painel (toda família vira ela, paletas_painel.dart).
  Color get destaque => paleta.familias.values.first;

  /// Quanto o canto do cartão é chanfrado (neon) ou arredondado (metal).
  static const chanfro = 10.0;

  /// A forma de cartão, caixa de desenho e botão dentro do painel.
  OutlinedBorder forma(BorderSide lado, {double raio = Raios.painel}) => ehNeon
      ? BeveledRectangleBorder(side: lado, borderRadius: BorderRadius.circular(raio <= Raios.controle ? chanfro / 2 : chanfro))
      : RoundedRectangleBorder(side: lado, borderRadius: BorderRadius.circular(raio));

  /// O metal é uma placa escovada (gradiente suave); o neon, uma tela chapada.
  Gradient? get placa => ehNeon
      ? null
      : LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [paleta.painelElevado, paleta.painel],
        );

  /// A tipografia do painel sobre a do app: o metal ganha o título fino e
  /// espaçado da tela da pedaleira; o neon troca títulos e valores para a
  /// monoespaçada (figuras de largura fixa, então o valor não dança).
  TextTheme ajustarTexto(TextTheme t) {
    if (!ehNeon) {
      return t.copyWith(
          titleSmall: t.titleSmall?.copyWith(fontFamily: Fontes.ui, fontWeight: FontWeight.w400, letterSpacing: _espacoTitulo));
    }
    // nome do parâmetro, seletor e botão ficam na condensada do case: na mono,
    // "SENSITIVITY" virava "SENSITIVI…" e "5-String Bass", "5-String Ba…";
    // legível vem antes do estilo
    TextStyle? tecno(TextStyle? s) => s?.copyWith(fontFamily: Fontes.tecno, fontWeight: FontWeight.w400, letterSpacing: 0.4);
    return t.copyWith(
      titleSmall: tecno(t.titleSmall),
      titleMedium: tecno(t.titleMedium),
    );
  }

  static const _espacoTitulo = 2.4;

  @override
  TemaPainel copyWith() => this;

  @override
  TemaPainel lerp(TemaPainel? outro, double t) => outro == null || t < 0.5 ? this : outro;
}

extension TemaDoPainel on BuildContext {
  /// O tema do painel em volta, se houver.
  TemaPainel? get temaPainel => Theme.of(this).extension<TemaPainel>();
}

/// A moldura de um cartão (coluna de banda, seção do synth, caixa de
/// desenho): sem tema de painel, exatamente a de sempre; com ele, a forma e
/// a placa do tema. [cor] força um fundo chapado (a tela de um desenho).
Decoration decoracaoCartao(BuildContext context, {Color? cor, double raio = Raios.painel}) {
  final lado = BorderSide(color: context.cores.filete);
  final tema = context.temaPainel;
  if (tema == null) {
    return BoxDecoration(color: cor, borderRadius: BorderRadius.circular(raio), border: Border.fromBorderSide(lado));
  }
  final placa = cor == null ? tema.placa : null;
  return ShapeDecoration(
    shape: tema.forma(lado, raio: raio),
    color: placa == null ? (cor ?? tema.paleta.painel) : null,
    gradient: placa,
  );
}
