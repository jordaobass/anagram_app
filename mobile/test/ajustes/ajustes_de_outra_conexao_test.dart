// A leitura dos ajustes globais leva tempo: se a pedaleira for trocada (ou
// desconectar e reconectar) antes de ela voltar, o que ela trouxer é da
// conexão anterior e não pode aparecer como valor da pedaleira nova.
import 'dart:async';

import 'package:anagram_app/aplicacao/estado/controlador_ajustes.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/dados/repositorio_pedaleira.dart';
import 'package:anagram_app/nucleo/ajustes/ajustes_pedaleira.dart';
import 'package:anagram_app/nucleo/resultado.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pedaleira cujas leituras de ajustes só voltam quando o teste manda.
class _PedaleiraSegurada implements RepositorioPedaleira {
  final leituras = <Completer<Resultado<AjustesPedaleira>>>[];

  @override
  Future<Resultado<AjustesPedaleira>> lerAjustesGlobais() {
    final leitura = Completer<Resultado<AjustesPedaleira>>();
    leituras.add(leitura);
    return leitura.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Conexão que o teste liga a uma pedaleira de cada vez.
class _ConexaoDeTeste extends ControladorConexao {
  RepositorioPedaleira? _pedaleira;

  @override
  RepositorioPedaleira? get repositorio => _pedaleira;

  @override
  EstadoConexao build() => const SemConexao();

  void ligar(RepositorioPedaleira pedaleira) {
    _pedaleira = pedaleira;
    state = Conectada(meio: 'teste ${pedaleira.hashCode}', firmware: '1.19', demonstracao: true);
  }
}

const _lidoDaAnterior = Sucesso(AjustesPedaleira(ajustes: {'mixer.headphones.vol': 5.0}));

(ProviderContainer, _ConexaoDeTeste) _app() {
  final container = ProviderContainer(overrides: [conexaoProvider.overrideWith(_ConexaoDeTeste.new)]);
  addTearDown(container.dispose);
  container.read(controladorAjustesProvider);
  return (container, container.read(conexaoProvider.notifier) as _ConexaoDeTeste);
}

void main() {
  test('should_ignore_a_settings_read_that_returns_after_the_pedal_was_replaced', () async {
    final (container, conexao) = _app();
    final anterior = _PedaleiraSegurada();
    conexao.ligar(anterior);

    final leitura = container.read(controladorAjustesProvider.notifier).carregar();
    conexao.ligar(_PedaleiraSegurada());
    anterior.leituras.single.complete(_lidoDaAnterior);
    await leitura;

    final estado = container.read(controladorAjustesProvider);
    expect(estado.lidos, isNull, reason: 'o valor é da pedaleira anterior');
    expect(estado.carregando, isFalse);
  });
}
