// O que esta plataforma consegue fazer com a pedaleira. Fica no núcleo
// porque a tela precisa do motivo sem depender da camada de plataforma.
sealed class SuporteAparelho {
  const SuporteAparelho();
}

final class AparelhoDisponivel extends SuporteAparelho {
  const AparelhoDisponivel(this.meio);

  /// Ex.: "USB (IOKit)", "WebHID".
  final String meio;
}

final class AparelhoIndisponivel extends SuporteAparelho {
  const AparelhoIndisponivel(this.motivo);
  final String motivo;
}
