// O arquivo importado vem de fora do app: o que não for preset vira recusa
// com frase, e falha de disco não derruba nada.
import 'dart:io';

import 'package:anagram_app/aplicacao/casos_de_uso/transferir_preset.dart';
import 'package:anagram_app/dados/arquivos_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sistema de arquivos falso: devolve o texto dado ou lança o erro dado.
class _ArquivosFalsos implements ArquivosPreset {
  _ArquivosFalsos({this.texto, this.erro});

  final String? texto;
  final Exception? erro;
  String? nomeGravado;

  @override
  Future<String?> lerEscolhido() async {
    if (erro case final falha?) throw falha;
    return texto;
  }

  @override
  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) async {
    if (erro case final falha?) throw falha;
    nomeGravado = nomeSugerido;
    return DestinoExportacao.arquivo;
  }
}

void main() {
  test('should_refuse_the_import_when_the_file_is_json_but_not_an_object', () async {
    final resultado = await TransferirPreset(_ArquivosFalsos(texto: '[1, 2, 3]')).importar();

    expect(resultado, isA<ImportacaoRecusada>());
    expect((resultado as ImportacaoRecusada).motivo, contains('não é um preset'));
  });

  test('should_refuse_the_import_when_the_file_cannot_be_read', () async {
    final arquivos = _ArquivosFalsos(erro: const FileSystemException('sem permissão'));

    final resultado = await TransferirPreset(arquivos).importar();

    expect(resultado, isA<ImportacaoRecusada>());
  });

  test('should_report_the_export_failure_when_the_disk_refuses_the_file', () async {
    final arquivos = _ArquivosFalsos(erro: const FileSystemException('disco cheio'));

    final resultado = await TransferirPreset(arquivos).exportar(DocumentoPreset.vazio('Grave'));

    expect(resultado, isA<ExportacaoFalhou>());
  });

  test('should_use_a_default_file_name_when_the_preset_name_has_no_usable_character', () async {
    final arquivos = _ArquivosFalsos();

    await TransferirPreset(arquivos).exportar(DocumentoPreset.vazio('///'));

    expect(arquivos.nomeGravado, TransferirPreset.nomePadrao);
  });
}
