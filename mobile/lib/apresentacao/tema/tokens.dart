// Tokens do mundo "case de estrada": ABS preto, arestas de alumínio,
// fita gaffer creme com marcador, estêncil nos números e fitas de cor de
// roadie codificando a família do bloco. Nenhuma cor ou medida fora daqui.
import 'package:flutter/painting.dart';

import '../../nucleo/catalogo/familia_bloco.dart';

abstract final class Cores {
  static const fundoCase = Color(0xFF131416);
  static const painel = Color(0xFF1B1C1F);
  static const painelElevado = Color(0xFF24262A);
  static const filete = Color(0xFF34373C);
  static const aluminio = Color(0xFF8E949B);
  static const aluminioClaro = Color(0xFFC9CDD2);
  static const texto = Color(0xFFEDEDEB);
  static const textoSecundario = Color(0xFFA7ACB2);
  static const fitaGaffer = Color(0xFFE8E1CD);
  static const fitaGafferSombra = Color(0xFFCFC6AE);
  static const tintaMarcador = Color(0xFF17171A);
  static const tally = Color(0xFFF0B429);
  static const sobreTally = Color(0xFF1A1405);
  static const fitaAlerta = Color(0xFFC2361F);
  static const sobreAlerta = Color(0xFFFFFFFF);
  static const ledLigado = Color(0xFF41D68A);
  static const ledDemonstracao = Color(0xFF5AA9F0);
  static const ledDesligado = Color(0xFF6B7077);
  static const erro = Color(0xFFFF7A66);

  static Color daFamilia(FamiliaBloco familia) => switch (familia) {
        FamiliaBloco.drive => const Color(0xFFE8772E),
        FamiliaBloco.compressor => const Color(0xFFE2C23A),
        FamiliaBloco.equalizador => const Color(0xFF3BB7D6),
        FamiliaBloco.filtro => const Color(0xFF9B78E3),
        FamiliaBloco.modulacao => const Color(0xFF34C3A0),
        FamiliaBloco.delay => const Color(0xFF5585EE),
        FamiliaBloco.reverb => const Color(0xFFD46BB3),
        FamiliaBloco.amplificador => const Color(0xFFE0563F),
        FamiliaBloco.gabinete => const Color(0xFFB9A37C),
        FamiliaBloco.utilitario => const Color(0xFF8D949C),
      };
}

abstract final class Espacos {
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class Raios {
  static const double canto = 3;
  static const double controle = 6;
  static const double painel = 8;
}

abstract final class Medidas {
  static const double alvoMinimo = 48;
  static const double filete = 1;
  static const double contornoSelecao = 2;
  static const double fitaCategoria = 4;
  static const double led = 10;
  static const double listaPresetsLargura = 304;

  /// Lista mais estreita quando a tela não passa de [Quebras.listaLarga].
  static const double listaPresetsLarguraEstreita = 256;
  /// Menor casa da grade ampla: no iPad 11" em paisagem as 12 casas cabem
  /// sem rolagem lateral e ainda passam do alvo mínimo de toque.
  static const double casaMinima = 56;
  static const double casaMaxima = 112;

  /// Abaixo disto a casa mostra a abreviação do bloco em vez do nome.
  static const double casaRotuloCompleto = 76;
  static const double arteNaCasa = 0.86;

  /// Diâmetro do furo da casa vazia, em fração da largura da casa.
  static const double marcaCasaVazia = 0.22;
  static const double knobAmplo = 104;
  static const double knobCompacto = 84;
  static const double espessuraArco = 6;

  /// Knob em proporções do próprio desenho: o corpo fica a 1,6 arco para
  /// dentro do anel, e o ponteiro vai de 25% a 82% do raio do corpo.
  static const double folgaCorpoKnob = 1.6;
  static const double pontaPonteiroKnob = 0.82;
  static const double basePonteiroKnob = 0.25;
  static const double espessuraPonteiroKnob = 0.7;
  static const double cantoneira = 14;
  static const double linhaSinal = 2;
  static const double alturaRotuloCasa = 20;
  static const double arrasteFaixaInteira = 200;
  static const double barraConexaoAltura = 64;
  static const double larguraDialogo = 440;
  static const double larguraConteudoVazio = 520;
  static const double larguraCabecalhoEmLinha = 480;

  /// Abaixo disto os botões de salvar descem para baixo da fita do preset.
  static const double larguraFaixaEmLinha = 880;
}

abstract final class Quebras {
  /// A partir daqui a lista de presets fica ao lado (iPad em retrato já entra).
  static const double amplo = 780;

  /// Abaixo disto o editor ao lado da lista usa a grade e os parâmetros do celular.
  static const double editorAmplo = 700;
  static const double alturaAmpla = 600;

  /// A partir daqui a lista de presets volta à largura cheia (iPad 13" em paisagem).
  static const double listaLarga = 1300;
}

abstract final class Duracoes {
  static const curta = Duration(milliseconds: 150);
}

abstract final class Fontes {
  static const ui = 'Barlow';
  static const rotulo = 'BarlowCondensed';
  static const estencil = 'SairaStencil';
  static const marcador = 'PermanentMarker';
}

abstract final class Opacidades {
  static const blocoDesligado = 0.38;

  /// Realce de foco do teclado sobre o tally: visível sem competir com a seleção.
  static const foco = 0.24;
}
