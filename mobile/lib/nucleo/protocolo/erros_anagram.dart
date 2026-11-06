// Falhas que o cliente do protocolo pode relatar. Cada uma vira uma frase
// diferente para o usuário, e o log guarda a ação e o detalhe técnico.
sealed class ErroAnagram implements Exception {
  const ErroAnagram(this.mensagem);
  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

/// Nenhuma pedaleira encontrada, ou o cabo saiu no meio da conversa.
final class ErroDesconectado extends ErroAnagram {
  const ErroDesconectado(super.mensagem);
}

/// A pedaleira está plugada, mas outro programa segura a interface.
base class ErroInterfaceOcupada extends ErroAnagram {
  const ErroInterfaceOcupada(super.mensagem);
}

/// A pedaleira está plugada, mas o sistema negou o acesso ao USB (pedido de
/// permissão recusado no Android). É uma interface que não abriu, como a
/// ocupada, mas a frase para o usuário é outra: não adianta fechar o Suite.
final class ErroPermissaoNegada extends ErroInterfaceOcupada {
  const ErroPermissaoNegada(super.mensagem);
}

/// A pedaleira não respondeu no prazo. Carga com formato errado também
/// termina assim: o aparelho simplesmente não responde.
final class ErroSemResposta extends ErroAnagram {
  ErroSemResposta(this.acao, this.prazo)
      : super('Sem resposta para "$acao" em ${prazo.inSeconds}s.');
  final String acao;
  final Duration prazo;
}

/// Chegou resposta, mas não deu para entender ou ela recusou o pedido.
final class ErroRespostaInvalida extends ErroAnagram {
  const ErroRespostaInvalida(super.mensagem);
}

/// Pedido recusado pelo próprio app porque outra operação ainda está em curso.
final class ErroOperacaoEmCurso extends ErroAnagram {
  const ErroOperacaoEmCurso(super.mensagem);
}

/// A plataforma não tem como falar HID de fornecedor (iPhone/iPad).
final class ErroPlataformaSemSuporte extends ErroAnagram {
  const ErroPlataformaSemSuporte(super.mensagem);
}
