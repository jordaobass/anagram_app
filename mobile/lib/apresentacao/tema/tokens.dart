// Tokens do mundo "case de estrada": ABS preto, arestas de alumínio,
// fita gaffer creme com marcador, estêncil nos números e fitas de cor de
// roadie codificando a família do bloco. Nenhuma cor ou medida fora daqui.
// As cores ficam em paleta.dart, um jogo por tema.
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

export 'paleta.dart';

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

  /// Pílula do modo dos footswitches: o desenho é baixo, o alvo continua de
  /// [alvoMinimo]. Abaixo de [larguraCenasComModo] na linha das cenas, as
  /// pílulas descem para uma linha fina sob elas.
  static const double alturaPilulaModo = 26;
  static const double larguraCenasComModo = 560;

  /// Chave "Controlar" numa linha (rótulo e as duas opções lado a lado); com
  /// menos largura, o rótulo sobe e as opções dividem a linha inteira.
  static const double larguraChaveControlarEmLinha = 480;
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

  /// Alvo de toque do traço de Threshold/Level na faixa: o traço tem 2 px,
  /// o alvo tem a altura mínima de toque, centrado nele (DECISOES K5).
  static const double alvoTracoGanho = alvoMinimo;
  static const double larguraDialogoTemplates = 440;
  static const double alturaReguaFrequencias = 18;

  /// Números da régua de frequência e da escala de dB da faixa.
  static const double fonteReguaFrequencias = 11;
  /// Alvo de toque da alça do corte: o traço e o puxador ficam no meio dele.
  static const double larguraAlcaFrequencia = alvoMinimo;
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

  /// Ícone do aviso de versão nova ao lado do texto da barra.
  static const double iconeAvisoVersao = 18;
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

  /// Global EQ nas Configurações: altura da curva, raio do ponto arrastável
  /// e a distância em que o dedo ainda pega o ponto. O alcance é um raio:
  /// o alvo de cada ponto já é um círculo de 64 px, acima dos 48 mínimos.
  static const double alturaCurvaGlobalEq = 160;
  static const double raioPontoEq = 7;
  static const double alcancePontoEq = 32;

  /// Global EQ: eixo de ±15 dB como a tela da pedaleira; abaixo desta
  /// largura as 6 bandas viram duas linhas de 3.
  static const double dbVisivelGlobalEq = 15;
  static const double larguraEqEmLinha = 560;
  static const double fonteEixoEq = 10;

  /// De quantos em quantos pixels a resposta do EQ é calculada para a curva.
  static const double passoAmostraCurvaEq = 2;
  static const double larguraChipEq = 72;

  /// Um item da placa de som (nome: valor), duas colunas no notebook.
  static const double larguraItemPlaca = 240;

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

  /// Painéis da bateria e do metrônomo, um cartão por controle como no
  /// visor: seis cabem numa fileira do computador e dois no celular (encolhendo
  /// até a mínima, em que o rolo e a lista ainda cabem); a altura
  /// mínima iguala a fileira (o Tempo com o BATER, a mais alta); o
  /// rolo do compasso tem a altura de dois algarismos grandes.
  static const double larguraCartaoUtilitario = 168;
  static const double larguraMinimaCartaoUtilitario = 144;
  static const double alturaCartaoUtilitario = 232;
  static const double alturaRoloUtilitario = 104;
  static const double larguraBotaoBater = 64;

  /// Ícone à esquerda de cada item de menu: um passo acima da letra de 15px,
  /// como o ícone de 16px ao lado do texto de 14px no menu do Windows 11.
  static const double iconeMenu = 18;

  /// Giro de "conectando" no lugar do ícone do botão: o tamanho do ícone de
  /// botão, independente do ícone de menu.
  static const double giroNoBotao = 20;

  /// Altura do item de menu com mouse (computador): o padrão dos menus de
  /// contexto de desktop fica entre 32 e 40px; no toque vale [alvoMinimo]
  /// (DECISOES UI12).
  static const double alturaItemMenuComMouse = 40;

  /// Check da opção marcada em cor neutra (ver [Paleta.pareceDesabilitada]).
  static const double iconeMarcaOpcao = 18;

  /// Cartão de um controle da pedaleira (FOOT, POT, EXP) e os knobs de
  /// mínimo e máximo de cada alvo no diálogo do controle.
  static const double larguraCartaoControle = 136;
  static const double larguraMinimaCartaoControle = 96;
  static const double knobFaixaControle = 72;

  /// Menor janela do computador (Windows: WM_GETMINMAXINFO em
  /// `win32_window.cpp`; macOS: `contentMinSize` em `MainFlutterWindow.swift`).
  /// Medido: a 440 px tudo cabe nos três idiomas, a 400 px a fita do preset
  /// em espanhol estoura; 480 deixa folga (DECISOES K6).
  static const double larguraMinimaJanela = 480;
  static const double alturaMinimaJanela = 480;
}

/// A parte de cima do editor (barra de conexão, fita do preset, SALVAR/
/// DESCARTAR, cenas e o modo dos footswitches) em dois tamanhos. Com mouse
/// (Windows, macOS, Linux) ela é compacta: o ponteiro é preciso, e os 64 + 56
/// + 56 px do toque empurravam a cadeia para baixo (relato no Reddit, DECISOES
/// BC1); os alvos ficam entre 32 e 40 px. No toque, o mínimo de 48 dp.
class MedidasDoTopo {
  const MedidasDoTopo._({
    required this.barraConexao,
    required this.controle,
    required this.fita,
    required this.folgaFita,
    required this.cena,
    required this.alvoPilula,
    required this.slot,
    required this.nomePreset,
    required this.entreFaixas,
  });

  /// Altura mínima da barra de conexão.
  final double barraConexao;

  /// Altura dos botões da faixa do preset (SALVAR, SALVAR COMO, DESCARTAR, menu).
  final double controle;

  /// Altura mínima da fita gaffer com o nome, e o respiro dentro dela.
  final double fita;
  final double folgaFita;

  /// Altura mínima do botão de cena.
  final double cena;

  /// Alvo de cada pílula do modo dos footswitches (o desenho tem [Medidas.alturaPilulaModo]).
  final double alvoPilula;

  /// Corpo do estêncil do slot ("02A") e da letra do nome do preset.
  final double slot;
  final double nomePreset;

  /// Espaço entre a fita, as cenas e a moldura da cadeia.
  final double entreFaixas;

  static const toque = MedidasDoTopo._(
    barraConexao: 64,
    controle: Medidas.alvoMinimo,
    fita: Medidas.alvoMinimo + Espacos.s,
    folgaFita: Espacos.s,
    cena: Medidas.alvoMinimo + Espacos.s,
    alvoPilula: Medidas.alvoMinimo,
    slot: 40,
    nomePreset: 24,
    entreFaixas: Espacos.l,
  );

  static const mouse = MedidasDoTopo._(
    barraConexao: Medidas.alvoMinimo,
    controle: 40,
    fita: 40,
    folgaFita: Espacos.xs,
    cena: 40,
    alvoPilula: 32,
    slot: 32,
    nomePreset: 22,
    entreFaixas: Espacos.s,
  );

  bool get comMouse => identical(this, mouse);

  static MedidasDoTopo get daPlataforma => switch (defaultTargetPlatform) {
        TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => toque,
        TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux => mouse,
      };
}

abstract final class Quebras {
  /// Abaixo disto a versão do app sai da barra de conexão larga (fica no
  /// Sobre): em espanhol, entre 780 e 840 px, ela empurrava a barra para fora.
  static const double barraComVersao = 880;

  /// Abaixo disto o aviso de versão nova vira só um ícone com menu: por
  /// extenso (texto, BAIXAR e fechar) ele estourava a barra em 159 px a
  /// 780 px, conectada e em espanhol.
  static const double barraComAvisoVersao = 1200;

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

  /// Tempo para ler as dicas do "?" depois de um clique ou toque.
  static const dicas = Duration(seconds: 8);
}

abstract final class Fontes {
  static const ui = 'Barlow';
  static const rotulo = 'BarlowCondensed';
  static const estencil = 'SairaStencil';
  static const marcador = 'PermanentMarker';
}

/// Estilos de texto fora da escala do Material, cada um com um papel só.
abstract final class Tipos {
  /// O nome do preset na fita gaffer: dado do usuário, lido a um metro. A
  /// condensada de rótulo do case em semibold, na caixa em que a pessoa
  /// escreveu; o marcador ficou só no nome fixo do app (DECISOES BC2). O
  /// corpo vem de [MedidasDoTopo.nomePreset].
  static const nomePreset =
      TextStyle(fontFamily: Fontes.rotulo, fontWeight: FontWeight.w600, letterSpacing: 0.3, height: 1.15);

  /// O nome do preset na lista: o corpo do texto, um passo mais firme que a
  /// frase comum, para a coluna de nomes se ler de relance.
  static const nomeNaLista = FontWeight.w500;

  /// Item de menu (botão direito, ⋮, menus suspensos): lido como menu do
  /// sistema, não como botão. Barlow média, sem a condensada em negrito e o
  /// espaçamento largo do rótulo de botão (DECISOES UI12).
  static const itemMenu =
      TextStyle(fontFamily: Fontes.ui, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.1, height: 1.25);

  /// O que fica à direita do item (o que o controle já move), como um atalho
  /// de teclado: menor e em `textoSecundario` (a cor vem do tema, onde se usa).
  static const detalheMenu = TextStyle(fontFamily: Fontes.ui, fontSize: 13, fontWeight: FontWeight.w400);
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

  /// Linhas da escala de dB que não são a do 0 dB: guia, não divisão.
  static const gradeSecundaria = 0.5;

  /// Sombra do corpo do pedal desenhado pelo app (sem a arte da pedaleira).
  static const sombraArteFamilia = 0.18;
}
