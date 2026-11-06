// Resultado de operação com o aparelho: sucesso ou falha conhecida.
// Fluxo normal não usa exceção; o repositório converte.
import 'protocolo/erros_anagram.dart';

sealed class Resultado<T> {
  const Resultado();
}

final class Sucesso<T> extends Resultado<T> {
  const Sucesso(this.valor);
  final T valor;
}

final class Falha<T> extends Resultado<T> {
  const Falha(this.erro);
  final ErroAnagram erro;
}
