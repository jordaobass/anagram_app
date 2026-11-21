// Tokens do mundo "case de estrada": ABS preto, arestas de alumínio,
// fita gaffer creme com marcador, estêncil nos números e fitas de cor de
// roadie codificando a família do bloco. Nenhuma cor ou medida fora daqui.
import 'package:flutter/painting.dart';

import '../../nucleo/catalogo/arranjo_multibanda.dart';
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

  /// O caminho da linha paralela: amarelo do Split até o fim da linha 2 e
  /// verde-água claro na volta ao Merge (pedido do usuário). O amarelo é mais
  /// claro e frio que o âmbar de ação ([tally]) para não parecer seleção; o
  /// verde-água é mais claro que a família de modulação. Os dois passam de
  /// 10:1 sobre [fundoCase].
  static const sinalSplit = Color(0xFFF5E05A);
  static const sinalMerge = Color(0xFF8FEADB);

  /// A fita da casa: Split e Merge levam a cor do trecho que abrem e fecham,
  /// para ligar o bloco ao fio; os demais, a da família.
  static Color daFita(String uri, FamiliaBloco familia) {
    if (uri.endsWith(':split')) return sinalSplit;
    if (uri.endsWith(':merge')) return sinalMerge;
    return daFamilia(familia);
  }

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

  /// As três bandas do Ignissor e do Entropia, na faixa de frequência e no
  /// topo da coluna: matizes distantes entre si e do âmbar de ação.
  static Color daBanda(BandaMultibanda banda, [PaletaBandas paleta = PaletaBandas.ignissor]) => switch ((paleta, banda)) {
        (PaletaBandas.ignissor, BandaMultibanda.graves) => const Color(0xFF5585EE),
        (PaletaBandas.ignissor, BandaMultibanda.medios) => const Color(0xFF34C3A0),
        (PaletaBandas.ignissor, BandaMultibanda.agudos) => const Color(0xFFD46BB3),
        (PaletaBandas.entropia, BandaMultibanda.graves) => const Color(0xFF3FC9C0),
        (PaletaBandas.entropia, BandaMultibanda.medios) => const Color(0xFF9B7BEA),
        (PaletaBandas.entropia, BandaMultibanda.agudos) => const Color(0xFFF0A23C),
      };

  /// As linhas da tela principal da pedaleira: Threshold em rosa, Level em verde.
  static const linhaThreshold = Color(0xFFF26FA8);
  static const linhaLevel = Color(0xFF7BD86A);
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

  /// Faixa de frequência do multibanda: uma raia por banda, a régua embaixo
  /// e a alça do corte larga o bastante para o dedo, com o traço fino no meio.
  static const double alturaRaiaBanda = 44;

  /// Alvo de toque do traço de Threshold/Level na faixa (o traço tem 2 px).
  static const double alvoTracoGanho = 16;
  static const double larguraDialogoTemplates = 440;
  static const double alturaReguaFrequencias = 18;
  static const double larguraAlcaFrequencia = 32;
  static const double tracoAlcaFrequencia = 3;
  static const double puxadorAlcaFrequencia = 10;

  /// Preenchimento da banda na faixa: tocando e mutada.
  static const double opacidadeCurvaBanda = 0.28;
  static const double tracoCurvaBanda = 2;

  /// Gráfico pequeno da banda (curva do compressor, onda do drive).
  static const double alturaGraficoBanda = 88;
  static const double tracoGraficoBanda = 2;
  static const double opacidadeRaiaMuda = 0.12;

  /// Coluna de uma banda do multibanda: abaixo de três delas lado a lado,
  /// as bandas viram abas.
  static const double larguraColunaBanda = 264;
  static const double knobBanda = 72;

  /// Acima disto as opções de um seletor ganham busca e grupos (os 37 drives).
  static const int opcoesSemBusca = 12;
  static const double alturaListaOpcoes = 480;

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

  /// Os três cartões do gabinete (modelo, microfone, posição) têm esta altura.
  static const double alturaCartaoGabinete = 208;
  /// Duas linhas do nome embaixo da foto/ícone do cartão.
  static const double alturaNomeCartaoGabinete = 40;
  static const double fotoNoCartaoGabinete = 112;
  static const double iconeNoCartaoGabinete = 56;
  /// A partir desta largura os três cartões ficam lado a lado.
  static const double larguraGabineteLadoALado = 560;
  /// Galeria dos modelos: foto e largura máxima de cada item da grade.
  static const double fotoNaGaleria = 96;
  static const double larguraItemGaleria = 150;
  static const double proporcaoItemGaleria = 0.9;
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

  /// Configurações: coluna de leitura, não a tela inteira do notebook.
  static const double larguraConfiguracoes = 640;
  static const double larguraCampoPorta = 120;

  /// Balão da explicação do parâmetro: uma frase curta por linha legível.
  static const double larguraExplicacao = 320;

  /// Painel do synth (Axioma): cartão de seção, a caixa dos desenhos (onda,
  /// filtro, envelope) e o traço deles. Abaixo de duas colunas de cartão as
  /// seções empilham na largura toda.
  static const double larguraCartaoSynth = 420;
  static const double larguraOsciladorSynth = 260;
  static const double larguraSeletorSynth = 180;
  static const double alturaDesenhoSynth = 72;
  static const double tracoDesenhoSynth = 2;
  static const double opacidadePreenchimentoSynth = 0.18;
  static const double knobSynth = 64;
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

  /// Item da biblioteca que não pode entrar na casa tocada (Split repetido,
  /// Merge sem Split): à vista, mas claramente fora de alcance.
  static const itemIndisponivel = 0.38;

  /// O bloco "na mão" deixa ver a grade embaixo, para mirar a casa.
  static const blocoArrastado = 0.85;

  /// Realce de foco do teclado sobre o tally: visível sem competir com a seleção.
  static const foco = 0.24;
}
