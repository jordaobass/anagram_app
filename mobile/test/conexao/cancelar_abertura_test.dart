// CANCELAR enquanto o USB abre (DECISOES CA5): o lado nativo é um só para o
// app, então o fechar tem de sair na hora, antes de uma tentativa nova abrir.
// Fechar só quando a abertura cancelada terminasse, tarde, fecharia o
// aparelho da tentativa seguinte.
import 'dart:async';
import 'dart:typed_data';

import 'package:anagram_app/aplicacao/conectar_ao_abrir.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/midi/saida_midi.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/fabrica_transporte.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// O USB do Mac abrindo devagar; [fechamentos] conta o fechar nativo.
class _AbreDevagar implements TransporteAnagram {
  final abertura = Completer<void>();
  int fechamentos = 0;
  bool _aberto = false;

  @override
  String get descricao => 'USB (IOKit)';
  @override
  Duration get pausaSugerida => Duration.zero;
  @override
  bool get aberto => _aberto;
  @override
  Stream<EstadoTransporte> get estados => const Stream.empty();
  @override
  Stream<Uint8List> get relatoriosRecebidos => const Stream.empty();
  @override
  Future<void> abrir() async {
    await abertura.future;
    _aberto = true;
  }

  @override
  Future<void> enviarRelatorio(Uint8List relatorio) async {}
  @override
  Future<void> fechar() async {
    fechamentos++;
    _aberto = false;
  }
}

class _Fabrica implements FabricaTransporte {
  final criados = <_AbreDevagar>[];

  @override
  SuporteAparelho get suporte => const AparelhoDisponivel('USB (IOKit)');
  @override
  TransporteAnagram criarAparelho() {
    final transporte = _AbreDevagar();
    criados.add(transporte);
    return transporte;
  }
  @override
  SaidaMidiAnagram? criarMidi() => null;
}

void main() {
  test('should_close_the_native_usb_at_once_when_cancelling_and_not_again_when_the_open_ends_late', () async {
    final fabrica = _Fabrica();
    final container = ProviderContainer(overrides: [
      fabricaTransporteProvider.overrideWithValue(fabrica),
      plataformaDeAberturaProvider.overrideWithValue(PlataformaDeAbertura.computador),
    ]);
    addTearDown(container.dispose);
    final conexao = container.read(conexaoProvider.notifier);
    final tentativa = conexao.conectarAparelho();
    await pumpEventQueue();
    final abrindo = fabrica.criados.single;

    await conexao.cancelarConexao();
    expect(abrindo.fechamentos, 1, reason: 'o Cancelar fecha o lado nativo na hora');

    abrindo.abertura.complete();
    await tentativa;
    expect(abrindo.fechamentos, 1,
        reason: 'um segundo fechar, tarde, fecharia o aparelho de uma tentativa nova');
    expect(container.read(conexaoProvider), isA<SemConexao>());
  });
}
