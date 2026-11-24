// As cores dos painéis temáticos (tema_painel.dart), nos dois brilhos. Cada
// jogo DERIVA da paleta do app (Paleta.escura / Paleta.clara) e troca só as
// superfícies, as tintas e os destaques: âmbar de ação, fitas, alertas e LEDs
// continuam os do case. Os pares passam no AA medido em
// test/tema/contraste_tema_painel_test.dart (texto 4,5:1; traço 3:1; tinta de
// marcador sobre o destaque 4,5:1). No claro, destaque e banda seguem a regra
// TC3: mesma matiz e saturação, luminância ~0,218. No claro o `fundoCase`
// (a tela dos desenhos: onda, filtro, envelope) é o degrau MAIS claro, e não
// o mais fundo como no app: o destaque escuro precisa de 3:1 sobre ele, e no
// cinza do alumínio dava 2,7:1.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import 'paleta.dart';

/// O destaque de cada bloco temático: a cor da chave, do arco do knob e da
/// opção marcada dentro do painel.
enum DestaquePainel { ignissor, entropia, axioma }

abstract final class PaletasPainel {
  /// Alumínio escovado (Ignissor e Entropia): cinza-chumbo no escuro, o
  /// próprio alumínio da pedaleira no claro.
  static Paleta metal(Brightness brilho, DestaquePainel destaque) => brilho == Brightness.dark
      ? _derivar(Paleta.escura, _metalEscuro, _destaquesEscuros[destaque]!, _bandasMetalEscuro)
      : _derivar(Paleta.clara, _metalClaro, _destaquesClaros[destaque]!, _bandasMetalClaro);

  /// Synthwave (Axioma): roxo profundo no escuro, lilás no claro.
  static Paleta neon(Brightness brilho) => brilho == Brightness.dark
      ? _derivar(Paleta.escura, _neonEscuro, _destaquesEscuros[DestaquePainel.axioma]!, const {})
      : _derivar(Paleta.clara, _neonClaro, _destaquesClaros[DestaquePainel.axioma]!, const {});

  /// Fundo da moldura, de cima para baixo, e o reflexo/grade pintado por cima
  /// (com a opacidade já aplicada). O teste mede o texto sobre cada degrau
  /// com e sem o reflexo.
  static List<Color> fundoMetal(Brightness b) =>
      b == Brightness.dark ? const [Color(0xFF3A4047), Color(0xFF2B2F34), Color(0xFF212428)] : const [Color(0xFFCDD2D7), Color(0xFFB9C0C6), Color(0xFFAAB2B9)];
  static Color reflexoMetal(Brightness b) =>
      b == Brightness.dark ? const Color(0x0FFFFFFF) : const Color(0x38FFFFFF);
  static List<Color> fundoNeon(Brightness b) =>
      b == Brightness.dark ? const [Color(0xFF2B1D55), Color(0xFF1D1437), Color(0xFF130C27)] : const [Color(0xFFDCD2F5), Color(0xFFCEC2EE), Color(0xFFC2B3E8)];
  static Color gradeNeon(Brightness b) => b == Brightness.dark ? const Color(0x1AFF4FD0) : const Color(0x1AC21E8F);

  /// O friso magenta dos trilhos e dos títulos do neon; no metal, o filete.
  static Color frisoNeon(Brightness b) => b == Brightness.dark ? const Color(0xFFFF5CD4) : const Color(0xFFD8009E);

  static const _destaquesEscuros = {
    DestaquePainel.ignissor: Color(0xFFC4EC3A),
    DestaquePainel.entropia: Color(0xFFF2A33C),
    DestaquePainel.axioma: Color(0xFF43E8F2),
  };
  static const _destaquesClaros = {
    DestaquePainel.ignissor: Color(0xFF758A1E),
    DestaquePainel.entropia: Color(0xFFB96F0E),
    DestaquePainel.axioma: Color(0xFF0A8F98),
  };

  static const _metalEscuro = _Superficies(
    fundoCase: Color(0xFF2A2E33),
    painel: Color(0xFF33383E),
    painelElevado: Color(0xFF3D434A),
    filete: Color(0xFF5A626B),
    aluminio: Color(0xFF9CA3AB),
    aluminioClaro: Color(0xFFD5D9DE),
    texto: Color(0xFFF2F4F6),
    textoSecundario: Color(0xFFBCC2C9),
    corpoKnob: Color(0xFF1C1F23),
    erro: Color(0xFFFF9C8C),
    linhaThreshold: Color(0xFFC4EC3A),
    linhaLevel: Color(0xFFF55FCB),
  );
  static const _metalClaro = _Superficies(
    fundoCase: Color(0xFFF4F5F7),
    painel: Color(0xFFE3E6E9),
    painelElevado: Color(0xFFEEF0F2),
    filete: Color(0xFF9CA4AC),
    aluminio: Color(0xFF555C64),
    aluminioClaro: Color(0xFF383E45),
    texto: Color(0xFF14171A),
    textoSecundario: Color(0xFF3E444B),
    tallyTinta: Color(0xFF764C00),
    linhaThreshold: Color(0xFF637B11),
    linhaLevel: Color(0xFFD50E9D),
  );
  static const _neonEscuro = _Superficies(
    fundoCase: Color(0xFF1D1437),
    painel: Color(0xFF2A1D50),
    painelElevado: Color(0xFF352862),
    filete: Color(0xFF6B52B3),
    aluminio: Color(0xFFA794DE),
    aluminioClaro: Color(0xFFDED5F8),
    texto: Color(0xFFF5F1FF),
    textoSecundario: Color(0xFFC5B9EA),
    corpoKnob: Color(0xFF140C29),
  );
  static const _neonClaro = _Superficies(
    fundoCase: Color(0xFFFBF9FF),
    painel: Color(0xFFF0EBFC),
    painelElevado: Color(0xFFF9F7FE),
    filete: Color(0xFFA592DB),
    aluminio: Color(0xFF5E48A5),
    aluminioClaro: Color(0xFF3D2E70),
    texto: Color(0xFF1A1233),
    textoSecundario: Color(0xFF463A74),
    tallyTinta: Color(0xFF764C00),
    corpoKnob: Color(0xFF2A1D50),
    alcaGrafico: Color(0xFF2A1D50),
    mioloAlca: Color(0xFFF9F7FE),
  );

  static const _bandasMetalEscuro = {
    (PaletaBandas.ignissor, BandaMultibanda.graves): Color(0xFF6F98F2),
    (PaletaBandas.ignissor, BandaMultibanda.medios): Color(0xFF3CCBA6),
    (PaletaBandas.ignissor, BandaMultibanda.agudos): Color(0xFFE070BE),
    (PaletaBandas.entropia, BandaMultibanda.graves): Color(0xFF46D3C2),
    (PaletaBandas.entropia, BandaMultibanda.medios): Color(0xFFA989F0),
    (PaletaBandas.entropia, BandaMultibanda.agudos): Color(0xFFF2A33C),
  };
  static const _bandasMetalClaro = {
    (PaletaBandas.ignissor, BandaMultibanda.graves): Color(0xFF487CED),
    (PaletaBandas.ignissor, BandaMultibanda.medios): Color(0xFF279077),
    (PaletaBandas.ignissor, BandaMultibanda.agudos): Color(0xFFCD52A6),
    (PaletaBandas.entropia, BandaMultibanda.graves): Color(0xFF288E88),
    (PaletaBandas.entropia, BandaMultibanda.medios): Color(0xFF8E6AE7),
    (PaletaBandas.entropia, BandaMultibanda.agudos): Color(0xFFB96F0E),
  };

  /// Dentro do painel temático só existe um bloco: toda família vira o
  /// destaque dele (a chave Comp, o arco, a opção marcada).
  static Paleta _derivar(Paleta base, _Superficies s, Color destaque, Map<(PaletaBandas, BandaMultibanda), Color> bandas) =>
      base.copyWith(
        fundoCase: s.fundoCase,
        painel: s.painel,
        painelElevado: s.painelElevado,
        filete: s.filete,
        aluminio: s.aluminio,
        aluminioClaro: s.aluminioClaro,
        texto: s.texto,
        textoSecundario: s.textoSecundario,
        tallyTinta: s.tallyTinta,
        erro: s.erro,
        corpoKnob: s.corpoKnob,
        alcaGrafico: s.alcaGrafico,
        mioloAlca: s.mioloAlca,
        linhaThreshold: s.linhaThreshold,
        linhaLevel: s.linhaLevel,
        familias: {for (final f in FamiliaBloco.values) f: destaque},
        bandas: {...base.bandas, ...bandas},
      );
}

/// Os papéis que o tema do painel troca; nulo herda da paleta do app.
class _Superficies {
  const _Superficies({
    required this.fundoCase,
    required this.painel,
    required this.painelElevado,
    required this.filete,
    required this.aluminio,
    required this.aluminioClaro,
    required this.texto,
    required this.textoSecundario,
    this.tallyTinta,
    this.erro,
    this.corpoKnob,
    this.alcaGrafico,
    this.mioloAlca,
    this.linhaThreshold,
    this.linhaLevel,
  });

  final Color fundoCase;
  final Color painel;
  final Color painelElevado;
  final Color filete;
  final Color aluminio;
  final Color aluminioClaro;
  final Color texto;
  final Color textoSecundario;
  final Color? tallyTinta;
  final Color? erro;
  final Color? corpoKnob;
  final Color? alcaGrafico;
  final Color? mioloAlca;
  final Color? linhaThreshold;
  final Color? linhaLevel;
}
