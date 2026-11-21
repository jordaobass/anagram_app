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
        // verde-limão: o amarelo antigo (E2C23A) se confundia com o âmbar de ação
        FamiliaBloco.compressor => const Color(0xFFB5D334),
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

  /// A caixa do pedal ocupa a casa inteira: a foto é o que identifica o bloco.
  static const double arteNaCasa = 1.0;

  /// Folga entre a borda da caixa do pedal e a foto.
  static const double folgaArteNaCaixa = 2;

  /// Vão entre as casas da cadeia (o fio do sinal passa por ele).
  static const double vaoEntreCasas = 4;

  /// Foto do pedal no painel do bloco e na biblioteca de efeitos.
  static const double artePainelBloco = 64;
  static const double arteBiblioteca = 56;

  /// O "+" do encaixe vazio, em fração da caixa do pedal: grande o bastante
  /// para se ler a um metro da tela.
  static const double marcaCasaVazia = 0.32;

  /// Comprimento de cada traço do contorno do encaixe vazio.
  static const double tracoEncaixe = 5;

  /// Espaço antes da casa 1 e depois da 12 para os jaques IN e OUT da cadeia.
  static const double margemJaque = 28;
  static const double raioJaque = 5;
  static const double rotuloJaque = 11;
  static const double knobAmplo = 104;
  static const double knobCompacto = 84;
  static const double espessuraArco = 6;

  /// Fader do GEQ: mais alto que o knob (o curso é o que se lê) e estreito,
  /// para as bandas ficarem juntas e desenharem a curva.
  static const double alturaFaderPorKnob = 1.5;
  static const double larguraFader = 56;
  static const double larguraCursorFader = 34;
  static const double alturaCursorFader = 14;
  static const double marcaZeroFader = 12;

  /// Banda desligada do paramétrico: ainda editável, mas apagada.
  static const double opacidadeBandaDesligada = 0.45;

  /// Knob em proporções do próprio desenho: o corpo fica a 1,6 arco para
  /// dentro do anel, e o ponteiro vai de 25% a 82% do raio do corpo.
  static const double folgaCorpoKnob = 1.6;
  static const double pontaPonteiroKnob = 0.82;
  static const double basePonteiroKnob = 0.25;
  static const double espessuraPonteiroKnob = 0.7;
  static const double cantoneira = 14;

  /// Selo "OFF" sobre a arte do bloco desligado: um sinal só, com ou sem a
  /// imagem de bypass da pedaleira.
  static const double seloDesligadoAltura = 16;

  /// Lápis na ponta da fita do preset: discreto, em alumínio sobre o creme.
  static const double iconeLapis = 18;
  static const double linhaSinal = 2;
  /// Duas linhas do nome do bloco (14 px) embaixo da arte da casa.
  static const double alturaRotuloCasa = 34;
  static const double entrelinhaRotuloCasa = 1.15;

  /// Foto do modelo no menu de escolha do gabinete.
  static const double fotoNaEscolhaDeGabinete = 32;
  /// Foto do gabinete escolhido no painel do bloco, como a pedaleira mostra.
  static const double fotoGabineteGrande = 144;
  /// A partir desta largura a foto fica ao lado dos controles do gabinete.
  static const double larguraGabineteLadoALado = 560;
  static const double larguraCampoGabinete = 320;
  static const double iconeMicrofone = 20;
  /// Traço do ícone de microfone, em fração do lado do ícone.
  static const double tracoMicrofone = 0.08;
  /// Passos da letra do nome do bloco na casa antes de cair na abreviação.
  static const reducoesRotuloCasa = [1.0, 0.86, 0.74];
  static const double fonteRotuloCasaPadrao = 14;
  static const double arrasteFaixaInteira = 200;
  static const double barraConexaoAltura = 64;
  static const double larguraDialogo = 440;

  /// Biblioteca de efeitos: cabe uma lista confortável no notebook, e no
  /// celular o diálogo encolhe até a tela.
  static const double larguraBiblioteca = 560;
  static const double alturaBiblioteca = 640;
  static const double larguraConteudoVazio = 520;
  static const double larguraCabecalhoEmLinha = 480;

  /// Abaixo disto os botões de salvar descem para baixo da fita do preset.
  static const double larguraFaixaEmLinha = 880;

  /// Balão da explicação do parâmetro: uma frase curta por linha legível.
  static const double larguraExplicacao = 320;
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

  /// O mouse passa pelo rótulo a caminho do knob: só explica se parar nele.
  static const esperaExplicacao = Duration(milliseconds: 500);
}

abstract final class Fontes {
  static const ui = 'Barlow';
  static const rotulo = 'BarlowCondensed';
  static const estencil = 'SairaStencil';
  static const marcador = 'PermanentMarker';
}

abstract final class Opacidades {
  static const blocoDesligado = 0.38;

  /// A casa de onde o bloco saiu fica em sombra enquanto ele é arrastado.
  static const origemDoArrasto = 0.3;

  /// O bloco "na mão" deixa ver a grade embaixo, para mirar a casa.
  static const blocoArrastado = 0.85;

  /// Realce de foco do teclado sobre o tally: visível sem competir com a seleção.
  static const foco = 0.24;
}
