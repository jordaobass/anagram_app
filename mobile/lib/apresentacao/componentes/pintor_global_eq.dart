// Curva do Global EQ como na tela da Anagram (e do bloco Parametric EQ, o
// mesmo DSP): grade de frequência (log, 20 Hz–20 kHz), eixo de +15 a −15 dB,
// a soma das bandas preenchida na cor do modo (ganho verde, frequência roxa,
// largura laranja) e um ponto por banda, que o dedo arrasta em frequência ×
// ganho. Banda desligada tem o ponto apagado; o corte fica na linha do 0 dB
// (ou do ganho geral do bloco, que desloca a curva e os pontos juntos).
import 'package:flutter/rendering.dart';

import '../../nucleo/ajustes/curva_global_eq.dart';
import '../../nucleo/catalogo/curvas_multibanda.dart' show fracaoDaFrequencia, frequenciaDaFracao;
import '../tema/tokens.dart';
import 'escalas_grafico.dart';

class GeometriaGlobalEq {
  const GeometriaGlobalEq(this.tamanho, {this.ganhoGeral = 0});

  final Size tamanho;

  /// O "gain" do bloco Parametric EQ: desloca a curva e, junto, os pontos.
  final double ganhoGeral;

  /// O eixo da tela da pedaleira; o ganho vai a ±18, o ponto para na borda.
  static const dbVisivel = Medidas.dbVisivelGlobalEq;

  /// O eixo log de 20 Hz a 20 kHz é o mesmo da faixa do multibanda (núcleo).
  double x(double f) => tamanho.width * fracaoDaFrequencia(f);
  double y(double db) => tamanho.height / 2 * (1 - db / dbVisivel);
  double frequencia(double x) => frequenciaDaFracao(x / tamanho.width).toDouble();
  double ganho(double y) => (1 - y / (tamanho.height / 2)) * dbVisivel;

  /// O ganho da banda para um ponto na altura [y]: o da tela menos o geral.
  double ganhoDaBanda(double y) => ganho(y) - ganhoGeral;

  /// O ponto fica sobre a curva: o ganho da banda somado ao geral (o corte,
  /// na altura do geral). Fora do eixo, para na borda.
  Offset ponto(BandaGlobalEq b) =>
      Offset(x(b.frequencia), y(((b.ehCorte ? 0 : b.ganho) + ganhoGeral).clamp(-dbVisivel, dbVisivel)));
}

class PintorGlobalEq extends CustomPainter {
  const PintorGlobalEq(this.bandas, {required this.cores, required this.cor, this.ativa, this.ganhoGeral = 0});

  final Paleta cores;

  final List<BandaGlobalEq> bandas;
  final Color cor;

  /// O "gain" do bloco Parametric EQ, que sobe ou desce a curva inteira.
  final double ganhoGeral;

  /// Índice da banda sendo arrastada (desenhada em destaque).
  final int? ativa;

  @override
  void paint(Canvas canvas, Size size) {
    final g = GeometriaGlobalEq(size, ganhoGeral: ganhoGeral);
    _grade(canvas, size, g);
    final curva = Path();
    for (var px = 0.0; px <= size.width; px += Medidas.passoAmostraCurvaEq) {
      final db = respostaEmDb(bandas, g.frequencia(px), ganhoGeral: ganhoGeral);
      final ponto = Offset(px, g.y(db.clamp(-_limiteDaCurva, _limiteDaCurva)));
      px == 0 ? curva.moveTo(ponto.dx, ponto.dy) : curva.lineTo(ponto.dx, ponto.dy);
    }
    final preenchida = Path.from(curva)
      ..lineTo(size.width, g.y(0))
      ..lineTo(0, g.y(0))
      ..close();
    canvas.drawPath(preenchida, Paint()..color = cor.withValues(alpha: Medidas.opacidadeCurvaBanda));
    canvas.drawPath(curva, _traco(cor, Medidas.filete * 2));
    for (var i = 0; i < bandas.length; i++) {
      _ponto(canvas, g.ponto(bandas[i]), destaque: i == ativa, ligada: bandas[i].ligada);
    }
  }

  /// A curva pode passar um pouco da borda (o ganho vai a ±18) antes de ser cortada.
  static const _limiteDaCurva = GeometriaGlobalEq.dbVisivel * 1.2;

  /// Linhas a cada 5 dB de +15 a −15, como a tela da pedaleira.
  static const _escalaDb = EscalaGanho(topo: GeometriaGlobalEq.dbVisivel, base: -GeometriaGlobalEq.dbVisivel, passo: 5);

  void _grade(Canvas canvas, Size size, GeometriaGlobalEq g) {
    final fina = _traco(cores.filete, Medidas.filete);
    for (final hz in marcasDeFrequencia) {
      final x = g.x(hz.toDouble());
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fina);
    }
    for (final db in _escalaDb.marcas) {
      final linha = db == 0 ? _traco(cores.aluminio, Medidas.filete) : fina;
      canvas.drawLine(Offset(0, g.y(db)), Offset(size.width, g.y(db)), linha);
    }
    final (topo, base) = (_escalaDb.topo, _escalaDb.base);
    pintarRotuloDoEixo(canvas, cores, rotuloDoDb(topo), Medidas.fonteEixoEq, (_) => Offset(Espacos.xs, g.y(topo)));
    pintarRotuloDoEixo(canvas, cores, rotuloDoDb(base), Medidas.fonteEixoEq,
        (_) => Offset(Espacos.xs, g.y(base) - Medidas.fonteEixoEq - Espacos.xs));
  }

  void _ponto(Canvas canvas, Offset centro, {required bool destaque, required bool ligada}) {
    final miolo = ligada ? cores.fitaGaffer : cores.fitaGaffer.withValues(alpha: Opacidades.itemIndisponivel);
    canvas.drawCircle(centro, Medidas.raioPontoEq, Paint()..color = miolo);
    canvas.drawCircle(centro, Medidas.raioPontoEq,
        _traco(destaque ? cores.tallyTinta : cores.painel, destaque ? Medidas.contornoSelecao : Medidas.filete));
  }

  Paint _traco(Color cor, double espessura) => Paint()
    ..color = cor
    ..style = PaintingStyle.stroke
    ..strokeWidth = espessura;

  @override
  bool shouldRepaint(PintorGlobalEq antigo) {
    if (antigo.cores != cores || antigo.ativa != ativa || antigo.cor != cor || antigo.ganhoGeral != ganhoGeral) return true;
    if (antigo.bandas.length != bandas.length) return true;
    for (var i = 0; i < bandas.length; i++) {
      final (a, b) = (antigo.bandas[i], bandas[i]);
      if (a.frequencia != b.frequencia || a.ganho != b.ganho || a.largura != b.largura || a.ligada != b.ligada) {
        return true;
      }
    }
    return false;
  }
}
