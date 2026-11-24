// As cores dos painéis com o tema da tela da pedaleira (tema_painel.dart).
// Decisão do dono (DECISOES PT9): a aparência é FIXA, a mesma com o app no
// tema claro ou no escuro, como a tela de um aparelho, que não muda com a
// luz da sala. Cada jogo deriva de Paleta.escura e troca só superfícies,
// tintas e destaques; âmbar de ação, fitas, alerta e LEDs são os do case.
// Os pares passam no AA medido em test/tema/contraste_tema_painel_test.dart.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import 'paleta.dart';

/// O destaque de cada bloco temático: a cor da chave, do arco do knob e da
/// opção marcada dentro do painel.
enum DestaquePainel { ignissor, entropia, axioma }

abstract final class PaletasPainel {
  /// A tela do Ignissor e do Entropia: alumínio anodizado escuro dentro do
  /// chassi de alumínio escovado.
  static Paleta metal(DestaquePainel destaque) => _derivar(_metal, _destaques[destaque]!, _bandasMetal);

  /// A tela do Axioma: synthwave, roxo profundo com neon.
  static Paleta neon() => _derivar(_neon, _destaques[DestaquePainel.axioma]!, const {});

  /// O fundo da tela, de cima para baixo, e o reflexo/grade por cima (com a
  /// opacidade já aplicada). O teste mede o texto sobre cada degrau.
  static const telaMetal = [Color(0xFF30353B), Color(0xFF262A2F), Color(0xFF1C1F23)];
  static const reflexoMetal = Color(0x14FFFFFF);
  static const telaNeon = [Color(0xFF2B1D55), Color(0xFF1D1437), Color(0xFF130C27)];
  static const gradeNeon = Color(0x2EFF4FD0);

  static const _destaques = {
    DestaquePainel.ignissor: Color(0xFFC4EC3A),
    DestaquePainel.entropia: Color(0xFFF2A33C),
    DestaquePainel.axioma: Color(0xFF43E8F2),
  };

  static const _metal = _Superficies(
    fundoCase: Color(0xFF25292E),
    painel: Color(0xFF33383E),
    painelElevado: Color(0xFF41474F),
    filete: Color(0xFF5A626B),
    aluminio: Color(0xFF9CA3AB),
    aluminioClaro: Color(0xFFD5D9DE),
    texto: Color(0xFFF2F4F6),
    textoSecundario: Color(0xFFBEC4CB),
    corpoKnob: Color(0xFF16181B),
    erro: Color(0xFFFF9C8C),
    linhaThreshold: Color(0xFFC4EC3A),
    linhaLevel: Color(0xFFF55FCB),
  );
  static const _neon = _Superficies(
    fundoCase: Color(0xFF4A3290),
    painel: Color(0xFF2A1D50),
    painelElevado: Color(0xFF3A2A6C),
    filete: Color(0xFF7A5FD0),
    aluminio: Color(0xFFA794DE),
    aluminioClaro: Color(0xFFDED5F8),
    texto: Color(0xFFF5F1FF),
    textoSecundario: Color(0xFFCABFF0),
    corpoKnob: Color(0xFF140C29),
    erro: Color(0xFFFFA99C),
  );

  static const _bandasMetal = {
    (PaletaBandas.ignissor, BandaMultibanda.graves): Color(0xFF6F98F2),
    (PaletaBandas.ignissor, BandaMultibanda.medios): Color(0xFF3CCBA6),
    (PaletaBandas.ignissor, BandaMultibanda.agudos): Color(0xFFE070BE),
    (PaletaBandas.entropia, BandaMultibanda.graves): Color(0xFF46D3C2),
    (PaletaBandas.entropia, BandaMultibanda.medios): Color(0xFFA989F0),
    (PaletaBandas.entropia, BandaMultibanda.agudos): Color(0xFFF2A33C),
  };

  /// Dentro do painel temático só existe um bloco: toda família vira o
  /// destaque dele (a chave Comp, o arco, a opção marcada).
  static Paleta _derivar(_Superficies s, Color destaque, Map<(PaletaBandas, BandaMultibanda), Color> bandas) =>
      Paleta.escura.copyWith(
        fundoCase: s.fundoCase,
        painel: s.painel,
        painelElevado: s.painelElevado,
        filete: s.filete,
        aluminio: s.aluminio,
        aluminioClaro: s.aluminioClaro,
        texto: s.texto,
        textoSecundario: s.textoSecundario,
        erro: s.erro,
        corpoKnob: s.corpoKnob,
        linhaThreshold: s.linhaThreshold,
        linhaLevel: s.linhaLevel,
        familias: {for (final f in FamiliaBloco.values) f: destaque},
        bandas: {...Paleta.escura.bandas, ...bandas},
      );
}

/// O chassi de alumínio escovado em volta da tela (os três painéis).
abstract final class CoresChassi {
  static const gradiente = [Color(0xFFD3D8DC), Color(0xFFAEB5BC), Color(0xFF8C949C)];
  static const riscoClaro = Color(0x40FFFFFF);
  static const riscoEscuro = Color(0x1F000000);
  static const biselLuz = Color(0xFFF7F9FA);
  static const biselSombra = Color(0xFF4A5057);
  static const especular = Color(0x59FFFFFF);

  /// Letra "gravada" no alumínio: tinta escura com a borda de luz embaixo.
  static const tintaGravada = Color(0xFF1B1E22);
  static const luzGravada = Color(0x99FFFFFF);
  static const parafuso = Color(0xFFDCE0E4);

  /// A barra de cima da tela do metal: alumínio claro com letra gravada.
  static const barra = [Color(0xFFE6EAED), Color(0xFFC6CCD1)];
  static const tintaSecundariaGravada = Color(0xFF30353B);
  static const placaBotao = Color(0xFFF1F3F5);
  static const fendaParafuso = Color(0xFF3A3F45);
  static const sombraRelevo = Color(0x8C000000);

  /// A placa anodizada escura (colunas e cartões do metal).
  static const escovadoPlacaClaro = Color(0x1AFFFFFF);
  static const escovadoPlacaEscuro = Color(0x33000000);
  static const especularPlaca = Color(0x12FFFFFF);
  static const luzBiselPlaca = Color(0x40FFFFFF);
  static const luzRanhura = Color(0x1FFFFFFF);
  static const luzGravacaoPlaca = Color(0x26FFFFFF);
}

/// O neon do Axioma: as cores que não são papel do case.
abstract final class CoresNeon {
  static const ciano = Color(0xFF43E8F2);
  static const rosa = Color(0xFFFF5CD4);
  static const azul = Color(0xFF3D8BFF);
  static const nucleo = Color(0xFFF2FFFF);

  /// A faixa do título dos módulos ("Osc 1 Vol"): magenta fundo, texto branco.
  static const faixaTitulo = Color(0xFF8A1E78);
  static const sobreFaixa = Color(0xFFFFFFFF);

  /// O visor de LCD (o slot) e o campo "Controlar".
  static const lcdFundo = Color(0xFF062B33);
  static const lcdTinta = Color(0xFF6CF6FF);
  static const campoFundo = Color(0xFF1C3AA6);
  static const campoTinta = Color(0xFFE3F7FF);
  static const barra = [Color(0xFF3B2C7E), Color(0xFF241848)];
  static const furo = Color(0xFF0E0820);

  /// A barra azul da janela "Select Block Template".
  static const barraJanela = Color(0xFF2347B8);

  /// Linhas de varredura e grão por cima da tela.
  static const varredura = Color(0x0A000000);
  static const grao = Color(0x08FFFFFF);

  /// Quanto o brilho espalha (sigma do desfoque), no pico do pulso.
  static const espalhamento = 7.0;
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
    this.erro,
    this.corpoKnob,
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
  final Color? erro;
  final Color? corpoKnob;
  final Color? linhaThreshold;
  final Color? linhaLevel;
}
