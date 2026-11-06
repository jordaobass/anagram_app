// Importar e exportar o JSON do preset. Onde não existe "salvar como"
// (web, celular), a exportação copia o JSON para a área de transferência.
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../nucleo/modelo/documento_preset.dart';
import '../nucleo/registro.dart';

enum DestinoExportacao { arquivo, areaDeTransferencia, cancelado }

class ArquivosPreset {
  const ArquivosPreset();

  static const _tipo = XTypeGroup(label: 'Preset da Anagram', extensions: ['json'], mimeTypes: ['application/json']);

  /// `null` se a pessoa cancelou. Lança [FormatException] se não for preset.
  Future<DocumentoPreset?> importar() async {
    final arquivo = await openFile(acceptedTypeGroups: const [_tipo]);
    if (arquivo == null) return null;
    final texto = await arquivo.readAsString();
    return DocumentoPreset.doJson(jsonDecode(texto) as Map<String, dynamic>);
  }

  Future<DestinoExportacao> exportar(DocumentoPreset documento) async {
    final texto = const JsonEncoder.withIndent(' ').convert(documento.paraJson());
    if (_temSalvarComo) {
      final local = await getSaveLocation(suggestedName: '${_nomeArquivo(documento.nome)}.json');
      if (local == null) return DestinoExportacao.cancelado;
      await XFile.fromData(utf8.encode(texto), mimeType: 'application/json').saveTo(local.path);
      registro.i('preset exportado para ${local.path}');
      return DestinoExportacao.arquivo;
    }
    await Clipboard.setData(ClipboardData(text: texto));
    return DestinoExportacao.areaDeTransferencia;
  }

  static bool get _temSalvarComo =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  static String _nomeArquivo(String nome) => nome.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
}
