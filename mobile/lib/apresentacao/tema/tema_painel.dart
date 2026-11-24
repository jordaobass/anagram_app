// O tema visual da ÁREA DE CONFIGURAÇÃO de alguns blocos, como a tela que
// cada um tem na própria Anagram (DECISOES PT): o painel vira um aparelho,
// um chassi de alumínio escovado com a tela dentro. Ignissor e Entropia têm
// a tela de alumínio anodizado; o Axioma, a tela synthwave em neon. A
// aparência é fixa: não muda com o tema claro ou escuro do app (PT9). A
// moldura (moldura_tema_painel.dart) aplica um ThemeData derivado deste tema,
// e os controles de sempre se repintam pelo papel. Comportamento nenhum muda.
import 'package:flutter/material.dart';

import 'decoracao_placa_metal.dart';
import 'paletas_painel.dart';
import 'tokens.dart';

enum EstiloPainel { metal, neon }

@immutable
class TemaPainel extends ThemeExtension<TemaPainel> {
  const TemaPainel({required this.estilo, required this.paleta, required this.tela, required this.reflexo});

  /// O tema do bloco, ou nulo para quem usa o case de sempre.
  static TemaPainel? doBloco(String uri) => switch (uri) {
        'urn:darkglass:ignissor' => TemaPainel.metal(DestaquePainel.ignissor),
        'urn:darkglass:entropia' => TemaPainel.metal(DestaquePainel.entropia),
        'urn:darkglass:axioma_synth' => TemaPainel.neon(),
        _ => null,
      };

  factory TemaPainel.metal(DestaquePainel destaque) => TemaPainel(
        estilo: EstiloPainel.metal,
        paleta: PaletasPainel.metal(destaque),
        tela: PaletasPainel.telaMetal,
        reflexo: PaletasPainel.reflexoMetal,
      );

  factory TemaPainel.neon() => TemaPainel(
        estilo: EstiloPainel.neon,
        paleta: PaletasPainel.neon(),
        tela: PaletasPainel.telaNeon,
        reflexo: PaletasPainel.gradeNeon,
      );

  final EstiloPainel estilo;
  final Paleta paleta;

  /// Gradiente da tela dentro do chassi, de cima para baixo.
  final List<Color> tela;

  /// O que se pinta sobre a tela, já com a opacidade: as ondas de reflexo do
  /// alumínio ou a grade synthwave do neon.
  final Color reflexo;

  bool get ehNeon => estilo == EstiloPainel.neon;

  /// O mesmo tema com outra paleta (a placa clara da barra do metal).
  TemaPainel comPaleta(Paleta outra) => TemaPainel(estilo: estilo, paleta: outra, tela: tela, reflexo: reflexo);

  /// A cor do bloco dentro do painel (toda família vira ela, paletas_painel.dart).
  Color get destaque => paleta.familias.values.first;

  /// Quanto o canto do módulo neon é chanfrado.
  static const chanfro = 10.0;

  /// A forma de cartão, caixa de desenho e botão dentro do painel.
  OutlinedBorder forma(BorderSide lado, {double raio = Raios.painel}) => ehNeon
      ? BeveledRectangleBorder(side: lado, borderRadius: BorderRadius.circular(raio <= Raios.controle ? chanfro / 2 : chanfro))
      : RoundedRectangleBorder(side: lado, borderRadius: BorderRadius.circular(raio));

  /// A tipografia do painel sobre a do app. Metal: títulos finos e espaçados,
  /// rótulos gravados (luz embaixo, sombra em cima). Neon: títulos e valores
  /// na monoespaçada de display (largura fixa, o valor não dança); nome do
  /// parâmetro e seletor ficam na condensada, que cabe no knob de 64 px.
  TextTheme ajustarTexto(TextTheme t) {
    if (ehNeon) {
      TextStyle? tecno(TextStyle? s) => s?.copyWith(fontFamily: Fontes.tecno, fontWeight: FontWeight.w400, letterSpacing: 0.4);
      return t.copyWith(titleSmall: tecno(t.titleSmall), titleMedium: tecno(t.titleMedium));
    }
    TextStyle? gravado(TextStyle? s) => s?.copyWith(shadows: _gravacao);
    return t.copyWith(
      titleSmall: gravado(t.titleSmall?.copyWith(fontFamily: Fontes.ui, fontWeight: FontWeight.w500, letterSpacing: _espacoTitulo)),
      labelSmall: gravado(t.labelSmall),
      labelMedium: gravado(t.labelMedium),
    );
  }

  static const _espacoTitulo = 2.4;

  /// Letra estampada na placa escura: sombra de 1 px em cima, luz embaixo.
  static const _gravacao = [
    Shadow(color: CoresChassi.sombraRelevo, offset: Offset(0, -1)),
    Shadow(color: CoresChassi.luzGravacaoPlaca, offset: Offset(0, 1)),
  ];

  @override
  TemaPainel copyWith() => this;

  @override
  TemaPainel lerp(TemaPainel? outro, double t) => outro == null || t < 0.5 ? this : outro;
}

extension TemaDoPainel on BuildContext {
  /// O tema do painel em volta, se houver.
  TemaPainel? get temaPainel => Theme.of(this).extension<TemaPainel>();
}

/// A moldura de um cartão (coluna de banda, seção, caixa de desenho): sem
/// tema de painel, exatamente a de sempre; no metal, uma placa anodizada
/// com bisel e parafusos; no neon, a forma chanfrada. [cor] força um fundo
/// chapado (a tela de um desenho), sem placa.
Decoration decoracaoCartao(BuildContext context, {Color? cor, double raio = Raios.painel}) {
  final lado = BorderSide(color: context.cores.filete);
  final tema = context.temaPainel;
  if (tema == null) {
    return BoxDecoration(color: cor, borderRadius: BorderRadius.circular(raio), border: Border.fromBorderSide(lado));
  }
  if (!tema.ehNeon && cor == null) return DecoracaoPlacaMetal(paleta: tema.paleta);
  return ShapeDecoration(shape: tema.forma(lado, raio: raio), color: cor ?? tema.paleta.painel);
}
