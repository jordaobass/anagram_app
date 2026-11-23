// As cores do case por PAPEL, em dois jogos: o escuro (o case de ABS preto,
// palco e bancada mal iluminados) e o claro (o case de alumínio à luz do dia).
// Cada papel tem o par nos dois temas; quem pinta pede a cor pelo papel
// (`context.cores.texto`), nunca pelo valor. Os pares do claro passam no
// contraste AA medido (test/interface/contraste_tema_test.dart).
import 'package:flutter/material.dart';

import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/catalogo/linha_paralela.dart';

@immutable
class Paleta extends ThemeExtension<Paleta> {
  const Paleta({
    required this.brilho,
    required this.fundoCase,
    required this.painel,
    required this.painelElevado,
    required this.filete,
    required this.aluminio,
    required this.aluminioClaro,
    required this.texto,
    required this.textoSecundario,
    required this.fitaGaffer,
    required this.fitaGafferSombra,
    required this.tintaMarcador,
    required this.tally,
    required this.sobreTally,
    required this.tallyTinta,
    required this.fitaAlerta,
    required this.sobreAlerta,
    required this.ledLigado,
    required this.ledDemonstracao,
    required this.ledDesligado,
    required this.erro,
    required this.modoStomp,
    required this.modoPreset,
    required this.modoScene,
    required this.sobreModo,
    required this.sinalSplit,
    required this.sinalMerge,
    required this.linhaThreshold,
    required this.linhaLevel,
    required this.mixerGlobal,
    required this.textoSobreModoEq,
    required this.corpoKnob,
    required this.alcaGrafico,
    required this.mioloAlca,
    required this.familias,
    required this.bandas,
    required this.modosEq,
    required this.textosModoEq,
  });

  final Brightness brilho;
  final Color fundoCase;
  final Color painel;
  final Color painelElevado;
  final Color filete;
  final Color aluminio;
  final Color aluminioClaro;
  final Color texto;
  final Color textoSecundario;
  final Color fitaGaffer;
  final Color fitaGafferSombra;
  final Color tintaMarcador;

  /// Âmbar de PREENCHIMENTO (botão primário, cena ativa, interruptor), sempre
  /// com [sobreTally] por cima.
  final Color tally;
  final Color sobreTally;

  /// Âmbar como TINTA sobre o case (texto, contorno de seleção, anel de foco,
  /// filete do slot aberto). No escuro é o próprio [tally]; no claro o âmbar
  /// de preenchimento dá 1,6:1 sobre o alumínio, e a tinta escurece até o AA.
  final Color tallyTinta;
  final Color fitaAlerta;
  final Color sobreAlerta;
  final Color ledLigado;
  final Color ledDemonstracao;
  final Color ledDesligado;
  final Color erro;

  /// O modo dos footswitches aceso nas cores dos LEDs da própria Anagram
  /// (pedido do dono, DECISOES FM8): roxo no Stomp, branco no Preset e
  /// azul-claro no Scene. EXCEÇÃO intencional à regra do âmbar só para ação e
  /// seleção. O texto [sobreModo] passa de 4,5:1 sobre as três (teste). No
  /// claro, o LED branco sobre o alumínio pareceria apagado: o Preset aceso
  /// vira grafite, e os três levam texto branco (DECISOES TC4).
  final Color modoStomp;
  final Color modoPreset;
  final Color modoScene;
  final Color sobreModo;

  /// O caminho da linha paralela: amarelo do Split até o fim da linha 2 e
  /// verde-água claro na volta ao Merge (pedido do usuário). O amarelo é mais
  /// claro e frio que o âmbar de ação ([tally]) para não parecer seleção.
  final Color sinalSplit;
  final Color sinalMerge;

  /// As linhas da tela principal da pedaleira: Threshold em rosa, Level em verde.
  final Color linhaThreshold;
  final Color linhaLevel;

  /// Faders do mixer global: azul de painel, fora das cores de família (um
  /// ajuste da pedaleira não é bloco) e longe do âmbar de ação.
  final Color mixerGlobal;

  /// Texto sobre o chip colorido do modo do Global EQ.
  final Color textoSobreModoEq;

  /// Corpo do knob e do cursor do fader; o ponteiro por cima é a fita gaffer.
  /// No claro o knob é preto, como o de verdade num case de alumínio: um
  /// corpo claro com ponteiro creme sumia.
  final Color corpoKnob;

  /// Ponto arrastável sobre os gráficos (bandas do EQ): creme no escuro,
  /// grafite no claro.
  final Color alcaGrafico;

  /// O miolo do puxador da alça de frequência, que é da cor do texto.
  final Color mioloAlca;
  final Map<FamiliaBloco, Color> familias;
  final Map<(PaletaBandas, BandaMultibanda), Color> bandas;
  final Map<ModoEq, Color> modosEq;
  final Map<ModoEq, Color> textosModoEq;

  bool get ehEscura => brilho == Brightness.dark;

  /// A fita da casa: Split e Merge levam a cor do trecho que abrem e fecham,
  /// para ligar o bloco ao fio; os demais, a da família.
  Color daFita(String uri, FamiliaBloco familia) {
    if (uri == uriSplit) return sinalSplit;
    if (uri == uriMerge) return sinalMerge;
    return daFamilia(familia);
  }

  Color daFamilia(FamiliaBloco familia) => familias[familia]!;

  /// As três bandas do Ignissor e do Entropia, na faixa de frequência e no
  /// topo da coluna: matizes distantes entre si e do âmbar de ação.
  Color daBanda(BandaMultibanda banda, [PaletaBandas paleta = PaletaBandas.ignissor]) => bandas[(paleta, banda)]!;

  /// O modo do Global EQ, com as cores da tela da Anagram: ganho em verde,
  /// frequência em roxo, largura em laranja.
  Color doModoEq(ModoEq modo) => modosEq[modo]!;

  /// O nome do modo escrito na cor dele sobre o painel, no AA: o roxo da
  /// pedaleira dá 4,47:1 como texto no escuro, e no claro os três escurecem.
  Color textoDoModoEq(ModoEq modo) => textosModoEq[modo]!;

  /// Cor de família quase sem matiz (utilitário, gabinete): preenchida num
  /// botão, parece o cinza de desabilitado. Quem pinta seleção com a cor da
  /// família troca, nesse caso, para o contorno âmbar (DECISOES UI1).
  static bool pareceDesabilitada(Color cor) => HSLColor.fromColor(cor).saturation < _saturacaoMinimaDeSelecao;
  static const _saturacaoMinimaDeSelecao = 0.4;

  static const escura = Paleta(
    brilho: Brightness.dark,
    fundoCase: Color(0xFF131416),
    painel: Color(0xFF1B1C1F),
    painelElevado: Color(0xFF24262A),
    filete: Color(0xFF34373C),
    aluminio: Color(0xFF8E949B),
    aluminioClaro: Color(0xFFC9CDD2),
    texto: Color(0xFFEDEDEB),
    textoSecundario: Color(0xFFA7ACB2),
    fitaGaffer: Color(0xFFE8E1CD),
    fitaGafferSombra: Color(0xFFCFC6AE),
    tintaMarcador: Color(0xFF17171A),
    tally: Color(0xFFF0B429),
    sobreTally: Color(0xFF1A1405),
    tallyTinta: Color(0xFFF0B429),
    fitaAlerta: Color(0xFFC2361F),
    sobreAlerta: Color(0xFFFFFFFF),
    ledLigado: Color(0xFF41D68A),
    ledDemonstracao: Color(0xFF5AA9F0),
    ledDesligado: Color(0xFF6B7077),
    erro: Color(0xFFFF7A66),
    modoStomp: Color(0xFF9B6CF0),
    modoPreset: Color(0xFFFFFFFF),
    modoScene: Color(0xFF6EC6F5),
    sobreModo: Color(0xFF121014),
    sinalSplit: Color(0xFFF5E05A),
    sinalMerge: Color(0xFF8FEADB),
    linhaThreshold: Color(0xFFF26FA8),
    linhaLevel: Color(0xFF7BD86A),
    mixerGlobal: Color(0xFF7FB2E5),
    textoSobreModoEq: Color(0xFF101114),
    corpoKnob: Color(0xFF24262A),
    alcaGrafico: Color(0xFFE8E1CD),
    mioloAlca: Color(0xFF17171A),
    familias: {
      FamiliaBloco.drive: Color(0xFFE8772E),
      // verde-limão: o amarelo antigo (E2C23A) se confundia com o âmbar de ação
      FamiliaBloco.compressor: Color(0xFFB5D334),
      FamiliaBloco.equalizador: Color(0xFF3BB7D6),
      FamiliaBloco.filtro: Color(0xFF9B78E3),
      FamiliaBloco.modulacao: Color(0xFF34C3A0),
      FamiliaBloco.delay: Color(0xFF5585EE),
      FamiliaBloco.reverb: Color(0xFFD46BB3),
      FamiliaBloco.amplificador: Color(0xFFE0563F),
      FamiliaBloco.gabinete: Color(0xFFB9A37C),
      FamiliaBloco.utilitario: Color(0xFF8D949C),
    },
    bandas: {
      (PaletaBandas.ignissor, BandaMultibanda.graves): Color(0xFF5585EE),
      (PaletaBandas.ignissor, BandaMultibanda.medios): Color(0xFF34C3A0),
      (PaletaBandas.ignissor, BandaMultibanda.agudos): Color(0xFFD46BB3),
      (PaletaBandas.entropia, BandaMultibanda.graves): Color(0xFF3FC9C0),
      (PaletaBandas.entropia, BandaMultibanda.medios): Color(0xFF9B7BEA),
      (PaletaBandas.entropia, BandaMultibanda.agudos): Color(0xFFF0A23C),
    },
    modosEq: {
      ModoEq.gain: Color(0xFF5FCF7E),
      ModoEq.freq: Color(0xFF8A6CF2),
      ModoEq.width: Color(0xFFF2A531),
    },
    textosModoEq: {
      ModoEq.gain: Color(0xFF5FCF7E),
      ModoEq.freq: Color(0xFF9B84F5),
      ModoEq.width: Color(0xFFF2A531),
    },
  );

  /// O case de alumínio: degraus claros (o elevado é o mais claro, como no
  /// escuro), filetes e tintas escuros. As cores de destaque (família, banda,
  /// fio, linhas do EQ) mantêm matiz e saturação e baixam a luminância até a
  /// faixa em que passam de 3:1 sobre o painel e ainda levam a tinta de
  /// marcador por cima no AA (DECISOES TC3).
  static const clara = Paleta(
    brilho: Brightness.light,
    fundoCase: Color(0xFFDFE1E3),
    painel: Color(0xFFECEEF0),
    painelElevado: Color(0xFFF8F9FA),
    filete: Color(0xFFC5C9CE),
    aluminio: Color(0xFF6B7178),
    aluminioClaro: Color(0xFF454B52),
    texto: Color(0xFF16181B),
    textoSecundario: Color(0xFF50565D),
    fitaGaffer: Color(0xFFE8E1CD),
    fitaGafferSombra: Color(0xFFB9AE8E),
    tintaMarcador: Color(0xFF17171A),
    tally: Color(0xFFF0B429),
    sobreTally: Color(0xFF1A1405),
    tallyTinta: Color(0xFF865600),
    fitaAlerta: Color(0xFFC2361F),
    sobreAlerta: Color(0xFFFFFFFF),
    ledLigado: Color(0xFF15703F),
    ledDemonstracao: Color(0xFF1F69AE),
    ledDesligado: Color(0xFF868B92),
    erro: Color(0xFFB3261E),
    modoStomp: Color(0xFF6B46D6),
    modoPreset: Color(0xFF2B2E33),
    modoScene: Color(0xFF16679F),
    sobreModo: Color(0xFFFFFFFF),
    sinalSplit: Color(0xFF958209),
    sinalMerge: Color(0xFF1C937F),
    linhaThreshold: Color(0xFFED3786),
    linhaLevel: Color(0xFF389527),
    mixerGlobal: Color(0xFF3585D6),
    textoSobreModoEq: Color(0xFF101114),
    corpoKnob: Color(0xFF2B2E33),
    alcaGrafico: Color(0xFF2B2E33),
    mioloAlca: Color(0xFFF8F9FA),
    familias: {
      FamiliaBloco.drive: Color(0xFFD36117),
      FamiliaBloco.compressor: Color(0xFF778B1E),
      FamiliaBloco.equalizador: Color(0xFF238EA8),
      FamiliaBloco.filtro: Color(0xFF936DE1),
      FamiliaBloco.modulacao: Color(0xFF279278),
      FamiliaBloco.delay: Color(0xFF4B7EED),
      FamiliaBloco.reverb: Color(0xFFCE55A8),
      FamiliaBloco.amplificador: Color(0xFFE0543C),
      FamiliaBloco.gabinete: Color(0xFF987F51),
      FamiliaBloco.utilitario: Color(0xFF7B838D),
    },
    bandas: {
      (PaletaBandas.ignissor, BandaMultibanda.graves): Color(0xFF4B7EED),
      (PaletaBandas.ignissor, BandaMultibanda.medios): Color(0xFF279278),
      (PaletaBandas.ignissor, BandaMultibanda.agudos): Color(0xFFCE55A8),
      (PaletaBandas.entropia, BandaMultibanda.graves): Color(0xFF29918A),
      (PaletaBandas.entropia, BandaMultibanda.medios): Color(0xFF906CE8),
      (PaletaBandas.entropia, BandaMultibanda.agudos): Color(0xFFBC710E),
    },
    modosEq: {
      ModoEq.gain: Color(0xFF2D9549),
      ModoEq.freq: Color(0xFF8A6CF2),
      ModoEq.width: Color(0xFFB8730C),
    },
    textosModoEq: {
      ModoEq.gain: Color(0xFF237339),
      ModoEq.freq: Color(0xFF6842EE),
      ModoEq.width: Color(0xFF8E5909),
    },
  );

  @override
  Paleta copyWith() => this;

  /// A troca de tema é rara e de propósito: o jogo muda inteiro no meio da
  /// transição, sem misturar papéis de dois temas.
  @override
  Paleta lerp(Paleta? outra, double t) => outra == null || t < 0.5 ? this : outra;
}

/// As cores do tema em uso: `context.cores.texto`.
extension CoresDoTema on BuildContext {
  Paleta get cores => Theme.of(this).extension<Paleta>() ?? Paleta.escura;
}
