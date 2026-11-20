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
  final MotivoIndisponivel motivo;
}

/// Por que a plataforma não fala com a pedaleira; a frase fica na tela, no
/// idioma em uso.
enum MotivoIndisponivel {
  /// iPhone/iPad: HID de fornecedor exige DriverKit com permissão da Apple.
  ios,

  /// Navegador sem WebHID (Firefox, Safari, celular).
  navegadorSemWebHid,

  /// Qualquer outra plataforma sem acesso USB.
  semUsb,
}
