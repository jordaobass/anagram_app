import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/transporte_anagram.dart';
import 'package:anagram_app/plataforma/saida_midi_nativa.dart';
import 'package:anagram_app/plataforma/transporte_canal_nativo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lado nativo simulado: cada método responde o que o teste mandar.
void _ladoNativo(String canal, Map<String, Object> erroPorMetodo) {
  final mensageiro = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  // o EventChannel dos relatórios só precisa aceitar o listen/cancel
  mensageiro.setMockMethodCallHandler(const MethodChannel('anagram_app/hid/eventos'), (_) async => null);
  mensageiro.setMockMethodCallHandler(
    MethodChannel(canal),
    (chamada) async {
      final erro = erroPorMetodo[chamada.method];
      if (erro != null) throw erro;
      return null;
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('should_not_throw_when_the_native_side_fails_to_close_the_usb', () async {
    _ladoNativo('anagram_app/hid', {'fechar': PlatformException(code: 'falhou')});
    final transporte = TransporteCanalNativo('USB', pausaSugerida: Duration.zero);
    final estados = <EstadoTransporte>[];
    transporte.estados.listen(estados.add);
    await transporte.abrir();

    await transporte.fechar();
    await Future<void>.delayed(Duration.zero);

    expect(transporte.aberto, isFalse);
    expect(estados.last, EstadoTransporte.fechado);
  });

  test('should_announce_closed_and_explain_permission_when_opening_is_denied', () async {
    _ladoNativo('anagram_app/hid', {'abrir': PlatformException(code: 'sem_permissao', message: 'negado')});
    final transporte = TransporteCanalNativo('USB', pausaSugerida: Duration.zero);
    final estados = <EstadoTransporte>[];
    transporte.estados.listen(estados.add);

    await expectLater(transporte.abrir(), throwsA(isA<ErroPermissaoNegada>()));
    await Future<void>.delayed(Duration.zero);

    expect(estados, [EstadoTransporte.abrindo, EstadoTransporte.fechado]);
  });

  test('should_not_throw_when_the_native_midi_port_fails_to_close', () async {
    _ladoNativo('anagram_app/midi', {'fechar': MissingPluginException()});
    final midi = SaidaMidiNativa();
    await midi.abrir();

    await midi.fechar();

    expect(midi.aberta, isFalse);
  });
}
