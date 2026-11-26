// Arquivos abertos com o app (DECISOES BB5): os .json dos argumentos e os que
// o macOS entrega pelo canal (antes e depois do "pronto") viram coleções da
// biblioteca, e o modo Biblioteca liga para mostrá-las.
import 'dart:io';

import 'package:anagram_app/aplicacao/estado/biblioteca_presets.dart';
import 'package:anagram_app/aplicacao/estado/modo_biblioteca.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/recebedor_de_arquivos.dart';
import 'package:anagram_app/plataforma/arquivos_abertos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';

const _canal = MethodChannel('anagram/arquivos_abertos_teste');

const _export =
    '{"exported": "2026-12-01", "presets": [{"slot": "20A", "name": "MEU LIMPO", "blocks": ['
    '{"row": 1, "col": 1, "type": "urn:darkglass:FETComp", "enabled": true, "params": {"Input": 6}}]}]}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mensageiro = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => mensageiro.setMockMethodCallHandler(_canal, null));

  test('should_deliver_only_json_paths_from_the_command_line', () async {
    const abertos = ArquivosAbertos(argumentos: ['--flag', '/tmp/a.JSON', '/tmp/b.txt']);

    expect(await abertos.ouvir().first, ['/tmp/a.JSON']);
  });

  test('should_deliver_files_queued_before_ready_and_files_opened_afterwards_on_macos', () async {
    mensageiro.setMockMethodCallHandler(_canal, (chamada) async {
      expect(chamada.method, 'pronto');
      return ['/fila/antes.json', '/fila/foto.png'];
    });
    final recebidos = <List<String>>[];
    final assinatura = const ArquivosAbertos(canal: _canal).ouvir().listen(recebidos.add);
    await pumpEventQueue();

    await mensageiro.handlePlatformMessage(
      _canal.name,
      _canal.codec.encodeMethodCall(const MethodCall('abrir', ['/depois.json'])),
      (_) {},
    );
    await pumpEventQueue();

    expect(recebidos, [
      ['/fila/antes.json'],
      ['/depois.json'],
    ]);
    await assinatura.cancel();
  });

  testWidgets('should_add_a_collection_and_turn_the_library_on_when_a_file_is_opened_with_the_app', (tester) async {
    final pasta = Directory.systemTemp.createTempSync('aberto_');
    addTearDown(() => pasta.deleteSync(recursive: true));
    final arquivo = File('${pasta.path}/do amigo.json')..writeAsStringSync(_export);

    final container = await abrirDemonstracao(
      tester,
      overrides: [
        textoBibliotecaBandasProvider.overrideWith(
          (ref) async => File(CaminhosAssets.bibliotecaBandas).readAsStringSync(),
        ),
        arquivosAbertosProvider.overrideWithValue(ArquivosAbertos(argumentos: [arquivo.path])),
      ],
    );
    // a leitura do arquivo é de verdade: anda fora do relógio falso
    for (var i = 0; i < 5 && !container.read(modoBibliotecaProvider); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    final fonte = container.read(fonteBibliotecaProvider).value!;
    expect(fonte.colecoes.map((c) => c.nome), contains('do amigo'));
    expect(container.read(modoBibliotecaProvider), isTrue);
    expect(find.text('Coleção “do amigo” adicionada com 1 presets.'), findsOneWidget);
  });
}
