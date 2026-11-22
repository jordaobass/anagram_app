// Ícone próprio dos utilitários internos (afinador, mixer, medidores, MIDI,
// gerador, pedal de expressão, looper): o mesmo gabinete da arte própria, na
// cor da família utilitário, com o glifo da função em traço no lugar do plugue
// genérico. Medidas em fração da área do glifo, como em PintorArteFamilia.
import 'dart:math';

import 'package:flutter/rendering.dart';

import '../../nucleo/catalogo/familia_bloco.dart';
import '../../nucleo/catalogo/utilitario_bloco.dart';
import 'pintor_arte_familia.dart';

class PintorArteUtilitario extends CustomPainter {
  const PintorArteUtilitario(this.tipo);

  final TipoUtilitario tipo;

  @override
  void paint(Canvas canvas, Size size) {
    final (area, traco) = PintorArteFamilia.pintarGabinete(canvas, size, FamiliaBloco.utilitario);
    // os glifos daqui têm mais detalhe que os da família: ocupam mais do gabinete
    canvas.drawPath(_glifo(area.inflate(size.width * 0.06)), traco);
  }

  Path _glifo(Rect a) => switch (tipo) {
        TipoUtilitario.afinador => _afinador(a),
        TipoUtilitario.mixer => _mixer(a),
        TipoUtilitario.medidor => _medidor(a),
        TipoUtilitario.vu => _vu(a),
        TipoUtilitario.espectro => _espectro(a),
        TipoUtilitario.midiCc => _conectorMidi(a)..addPath(_knob(a), Offset.zero),
        TipoUtilitario.midiPc => _conectorMidi(a)..addPath(_lista(a), Offset.zero),
        TipoUtilitario.senoide => _senoide(a),
        TipoUtilitario.pedalExpressao => _pedal(a),
        TipoUtilitario.looper => _looper(a),
      };

  /// Escala em arco com marcas e a agulha no centro (afinado).
  Path _afinador(Rect a) {
    final centro = Offset(a.center.dx, a.top + a.height * 0.6);
    final raio = a.width * 0.5;
    final caminho = Path()..addArc(Rect.fromCircle(center: centro, radius: raio), pi, pi);
    for (var i = 0; i <= 4; i++) {
      final angulo = pi + pi * i / 4;
      final direcao = Offset(cos(angulo), sin(angulo));
      caminho
        ..moveTo(centro.dx + direcao.dx * raio * 0.75, centro.dy + direcao.dy * raio * 0.75)
        ..lineTo(centro.dx + direcao.dx * raio, centro.dy + direcao.dy * raio);
    }
    return caminho
      ..moveTo(centro.dx, centro.dy)
      ..lineTo(centro.dx, centro.dy - raio * 0.9)
      ..addOval(Rect.fromCircle(center: centro, radius: a.width * 0.08));
  }

  /// Três canais: botão em cima e fader com capa em alturas diferentes.
  Path _mixer(Rect a) {
    final caminho = Path();
    const capas = [0.55, 0.8, 0.65];
    for (var i = 0; i < capas.length; i++) {
      final x = a.left + a.width * (i + 0.5) / capas.length;
      final capa = a.top + a.height * capas[i];
      caminho
        ..addOval(Rect.fromCircle(center: Offset(x, a.top + a.height * 0.1), radius: a.width * 0.1))
        ..moveTo(x, a.top + a.height * 0.3)
        ..lineTo(x, a.bottom)
        ..addRect(Rect.fromCenter(center: Offset(x, capa), width: a.width * 0.2, height: a.height * 0.06));
    }
    return caminho;
  }

  /// Duas colunas de segmentos acesos até alturas diferentes (nível L/R).
  Path _medidor(Rect a) {
    final caminho = Path();
    const acesos = [7, 5];
    for (var coluna = 0; coluna < acesos.length; coluna++) {
      final x = a.left + a.width * (coluna == 0 ? 0.28 : 0.72);
      for (var i = 0; i < acesos[coluna]; i++) {
        final y = a.bottom - a.height * (0.05 + i * 0.13);
        caminho
          ..moveTo(x - a.width * 0.14, y)
          ..lineTo(x + a.width * 0.14, y);
      }
    }
    return caminho;
  }

  /// Janela do VU com a escala em arco e a agulha inclinada.
  Path _vu(Rect a) {
    final janela = Rect.fromLTWH(a.left, a.top + a.height * 0.15, a.width, a.height * 0.55);
    final pivo = Offset(janela.center.dx, janela.bottom - janela.height * 0.1);
    final raio = janela.width * 0.42;
    final ponta = pivo + Offset(cos(-pi * 0.7), sin(-pi * 0.7)) * raio * 1.1;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(janela, Radius.circular(a.width * 0.08)))
      ..addArc(Rect.fromCircle(center: pivo, radius: raio), -pi * 0.85, pi * 0.7)
      ..moveTo(pivo.dx, pivo.dy)
      ..lineTo(ponta.dx, ponta.dy)
      ..moveTo(a.left + a.width * 0.2, a.bottom - a.height * 0.1)
      ..lineTo(a.right - a.width * 0.2, a.bottom - a.height * 0.1);
  }

  /// Envelope do espectro sobre a linha de base, com os eixos.
  Path _espectro(Rect a) {
    const alturas = [0.35, 0.7, 0.55, 0.85, 0.5, 0.6, 0.25];
    final caminho = Path()
      ..moveTo(a.left, a.top)
      ..lineTo(a.left, a.bottom)
      ..lineTo(a.right, a.bottom);
    for (var i = 0; i < alturas.length; i++) {
      final ponto = Offset(a.left + a.width * i / (alturas.length - 1), a.bottom - a.height * alturas[i]);
      i == 0 ? caminho.moveTo(ponto.dx, ponto.dy) : caminho.lineTo(ponto.dx, ponto.dy);
    }
    return caminho;
  }

  /// Conector DIN de 5 pinos, na metade de cima.
  Path _conectorMidi(Rect a) {
    final centro = Offset(a.center.dx, a.top + a.width * 0.4);
    final raio = a.width * 0.4;
    final caminho = Path()
      ..addOval(Rect.fromCircle(center: centro, radius: raio))
      ..moveTo(centro.dx - raio * 0.15, centro.dy - raio)
      ..lineTo(centro.dx + raio * 0.15, centro.dy - raio);
    for (var i = 0; i < 5; i++) {
      final angulo = pi * (i / 4) - pi;
      final pino = centro + Offset(cos(angulo), -sin(angulo)) * raio * 0.6;
      caminho.addOval(Rect.fromCircle(center: pino, radius: a.width * 0.04));
    }
    return caminho;
  }

  /// CC: um botão com o ponteiro (valor contínuo), embaixo do conector.
  Path _knob(Rect a) {
    final centro = Offset(a.center.dx, a.bottom - a.width * 0.26);
    return Path()
      ..addOval(Rect.fromCircle(center: centro, radius: a.width * 0.22))
      ..moveTo(centro.dx, centro.dy)
      ..lineTo(centro.dx + a.width * 0.14, centro.dy - a.width * 0.14);
  }

  /// PC: a lista de programas, embaixo do conector.
  Path _lista(Rect a) {
    final caminho = Path();
    for (var i = 0; i < 3; i++) {
      final y = a.bottom - a.height * (0.05 + i * 0.11);
      caminho
        ..addOval(Rect.fromCircle(center: Offset(a.left + a.width * 0.1, y), radius: a.width * 0.04))
        ..moveTo(a.left + a.width * 0.3, y)
        ..lineTo(a.right, y);
    }
    return caminho;
  }

  /// Um período inteiro de senoide sobre o eixo.
  Path _senoide(Rect a) {
    final caminho = Path()
      ..moveTo(a.left, a.center.dy)
      ..lineTo(a.right, a.center.dy);
    for (var i = 0; i <= 40; i++) {
      final ponto = Offset(a.left + a.width * i / 40, a.center.dy - sin(i / 40 * 2 * pi) * a.height * 0.3);
      i == 0 ? caminho.moveTo(ponto.dx, ponto.dy) : caminho.lineTo(ponto.dx, ponto.dy);
    }
    return caminho;
  }

  /// Pedal visto de cima: a plataforma com a borracha e a dobradiça embaixo.
  Path _pedal(Rect a) {
    final plataforma = Rect.fromLTRB(a.left, a.top, a.right, a.bottom - a.height * 0.12);
    final caminho = Path()..addRRect(RRect.fromRectAndRadius(plataforma, Radius.circular(a.width * 0.15)));
    for (var i = 1; i <= 4; i++) {
      final y = plataforma.top + plataforma.height * i / 5;
      caminho
        ..moveTo(plataforma.left + a.width * 0.25, y)
        ..lineTo(plataforma.right - a.width * 0.25, y);
    }
    return caminho
      ..moveTo(a.left + a.width * 0.15, a.bottom)
      ..lineTo(a.right - a.width * 0.15, a.bottom);
  }

  /// Seta circular (a volta do loop) com o ponto de gravação no meio.
  Path _looper(Rect a) {
    final raio = a.width * 0.48;
    final arco = Rect.fromCircle(center: a.center, radius: raio);
    const fim = -pi / 2 + pi * 5 / 3;
    final normal = Offset(cos(fim), sin(fim));
    final ponta = a.center + normal * raio;
    // o arco corre no sentido horário: a seta aponta pela tangente
    final recuo = ponta - Offset(-sin(fim), cos(fim)) * a.width * 0.22;
    final abertura = normal * a.width * 0.14;
    return Path()
      ..addArc(arco, -pi / 2, pi * 5 / 3)
      ..moveTo(recuo.dx + abertura.dx, recuo.dy + abertura.dy)
      ..lineTo(ponta.dx, ponta.dy)
      ..lineTo(recuo.dx - abertura.dx, recuo.dy - abertura.dy)
      ..addOval(Rect.fromCircle(center: a.center, radius: a.width * 0.1));
  }

  @override
  bool shouldRepaint(PintorArteUtilitario antigo) => antigo.tipo != tipo;
}
