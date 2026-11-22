// O registro do app também vai para um arquivo, para quem relata um defeito
// ter o que mandar: o exe com janela não tem console. O arquivo gira ao passar
// do limite, e "copiar" junta as linhas mais novas mesmo depois de girar.
import 'dart:io';

import 'package:anagram_app/nucleo/registro.dart';
import 'package:anagram_app/plataforma/registro_em_arquivo_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory pasta;

  setUp(() => pasta = Directory.systemTemp.createTempSync('registro-'));
  tearDown(() => pasta.deleteSync(recursive: true));

  test('should_write_what_the_app_logs_to_the_file', () async {
    final arquivo = ArquivoDeRegistro(pasta);
    saidasDoRegistro.acrescentar(arquivo);
    addTearDown(() => saidasDoRegistro.remover(arquivo));

    registro.i('pedaleira: conectou pelo USB (hidapi)');
    arquivo.descarregar();

    expect(File(arquivo.caminho).readAsStringSync(), contains('pedaleira: conectou pelo USB (hidapi)'));
  });

  test('should_rotate_past_the_limit_keeping_only_the_newest_copies', () async {
    final arquivo = ArquivoDeRegistro(pasta, limiteBytes: 200, copias: 2);
    for (var linha = 0; linha < 40; linha++) {
      arquivo.gravar('linha $linha ${'x' * 20}');
    }
    arquivo.descarregar();

    final nomes = pasta.listSync().map((item) => item.uri.pathSegments.last).toSet();
    expect(nomes, {'anagram-app.log', 'anagram-app.1.log', 'anagram-app.2.log'});
    expect(File(arquivo.caminho).lengthSync(), lessThanOrEqualTo(200 + 40));
  });

  test('should_return_the_newest_lines_across_a_rotation', () async {
    final arquivo = ArquivoDeRegistro(pasta, limiteBytes: 60, copias: 2);
    for (var linha = 0; linha < 12; linha++) {
      arquivo.gravar('linha $linha');
    }

    final ultimas = await arquivo.ultimasLinhas(5);

    expect(ultimas.split('\n'), ['linha 7', 'linha 8', 'linha 9', 'linha 10', 'linha 11']);
  });

  test('should_batch_lines_on_disk_within_the_flush_interval_and_write_warnings_at_once', () async {
    final arquivo = ArquivoDeRegistro(pasta);
    saidasDoRegistro.acrescentar(arquivo);
    addTearDown(() => saidasDoRegistro.remover(arquivo));
    String noDisco() => File(arquivo.caminho).existsSync() ? File(arquivo.caminho).readAsStringSync() : '';

    for (var envio = 0; envio < 30; envio++) {
      registro.i('anagram try_anagram_preset: ida e volta $envio ms');
    }
    expect(noDisco(), isNot(contains('ida e volta 29 ms')), reason: 'cada linha não abre e fecha o arquivo');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(noDisco(), contains('ida e volta 29 ms'), reason: 'o lote chega ao disco em pouco tempo');

    registro.w('hidapi: falha de escrita no USB');
    expect(noDisco(), contains('falha de escrita no USB'), reason: 'aviso e erro não esperam o lote: o app pode cair');
  });

  test('should_pick_the_log_folder_of_each_system_and_none_without_its_variable', () {
    final separador = Platform.pathSeparator;
    expect(pastaDeRegistro('windows', {'LOCALAPPDATA': r'C:\Users\jon\AppData\Local'})?.path,
        'C:\\Users\\jon\\AppData\\Local${separador}Anagram App${separador}logs');
    expect(pastaDeRegistro('macos', {'HOME': '/Users/jon'})?.path,
        '/Users/jon${separador}Library${separador}Logs${separador}Anagram App');
    expect(pastaDeRegistro('windows', {'LOCALAPPDATA': '  '}), isNull, reason: 'variável em branco vale como ausente');
    expect(pastaDeRegistro('android', {'HOME': '/data'}), isNull);
  });
}
