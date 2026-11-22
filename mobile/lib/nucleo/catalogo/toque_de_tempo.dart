// Tap tempo calculado no app: cada toque marca um instante e o BPM sai da
// média dos últimos intervalos. Pausa longa recomeça a contagem, como no
// tap de um pedal. O app grava o resultado no knob Tempo (DECISOES MT2).

class ToqueDeTempo {
  ToqueDeTempo({this.pausaQueRecomeca = const Duration(seconds: 2), this.intervalosNaMedia = 4});

  /// Mais que isto entre dois toques: o novo toque é o primeiro de outra conta.
  final Duration pausaQueRecomeca;
  final int intervalosNaMedia;

  Duration? _ultimo;
  final List<int> _intervalos = [];

  /// Registra um toque no instante [agora]; devolve o BPM (inteiro) quando
  /// já há pelo menos um intervalo, ou nulo no primeiro toque da conta.
  int? tocar(Duration agora) {
    final ultimo = _ultimo;
    _ultimo = agora;
    final intervalo = ultimo == null ? null : (agora - ultimo).inMicroseconds;
    if (intervalo == null || intervalo <= 0 || intervalo > pausaQueRecomeca.inMicroseconds) {
      _intervalos.clear();
      return null;
    }
    _intervalos.add(intervalo);
    if (_intervalos.length > intervalosNaMedia) _intervalos.removeAt(0);
    final media = _intervalos.reduce((a, b) => a + b) / _intervalos.length;
    return (Duration.microsecondsPerMinute / media).round();
  }
}
