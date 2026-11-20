// Estados da conexão mostrados o tempo todo na barra superior.
sealed class EstadoConexao {
  const EstadoConexao();
}

final class SemConexao extends EstadoConexao {
  const SemConexao({this.aviso});

  /// Por que caiu, quando caiu (ex.: cabo desconectado).
  final String? aviso;
}

final class Conectando extends EstadoConexao {
  const Conectando(this.meio);
  final String meio;
}

final class Conectada extends EstadoConexao {
  const Conectada({required this.meio, required this.firmware, required this.demonstracao});
  final String meio;
  final String firmware;
  final bool demonstracao;
}

final class FalhaDeConexao extends EstadoConexao {
  const FalhaDeConexao(this.mensagem);
  final String mensagem;
}
