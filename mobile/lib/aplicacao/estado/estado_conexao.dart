// Estados da conexão mostrados o tempo todo na barra superior.
import '../avisos.dart';

sealed class EstadoConexao {
  const EstadoConexao();
}

final class SemConexao extends EstadoConexao {
  const SemConexao({this.aviso});

  /// Por que caiu, quando caiu (ex.: cabo desconectado).
  final Aviso? aviso;
}

final class Conectando extends EstadoConexao {
  const Conectando(this.meio, {this.demonstracao = false});
  final String meio;

  /// Abrindo a pedaleira simulada: a tela diz "abrindo a demonstração", não
  /// "conectando" a um USB que não existe.
  final bool demonstracao;
}

final class Conectada extends EstadoConexao {
  const Conectada({required this.meio, required this.firmware, required this.demonstracao});
  final String meio;
  final String firmware;
  final bool demonstracao;
}

final class FalhaDeConexao extends EstadoConexao {
  const FalhaDeConexao(this.aviso);
  final Aviso aviso;
}
