// Porta para o sistema de arquivos: escolher o JSON a importar e gravar o
// exportado. Onde não existe "salvar como" (web, celular), a exportação copia
// o JSON para a área de transferência. Interpretar o conteúdo é do caso de
// uso TransferirPreset, não daqui.
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../nucleo/registro.dart';

enum DestinoExportacao { arquivo, areaDeTransferencia, cancelado }

class ArquivosPreset {
  const ArquivosPreset();

  static const _tipo = XTypeGroup(label: 'Preset da Anagram', extensions: ['json'], mimeTypes: ['application/json']);

  /// Texto do arquivo escolhido; `null` se a pessoa cancelou.
  Future<String?> lerEscolhido() async {
    final arquivo = await openFile(acceptedTypeGroups: const [_tipo]);
    return arquivo?.readAsString();
  }

  /// Grava [texto] onde a pessoa escolher, com [nomeSugerido] (sem extensão).
  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) async {
    if (!_temSalvarComo) {
      await Clipboard.setData(ClipboardData(text: texto));
      return DestinoExportacao.areaDeTransferencia;
    }
    final local = await getSaveLocation(suggestedName: '$nomeSugerido.json');
    if (local == null) return DestinoExportacao.cancelado;
    await XFile.fromData(utf8.encode(texto), mimeType: 'application/json').saveTo(local.path);
    registro.i('preset exportado para ${local.path}');
    return DestinoExportacao.arquivo;
  }

  static bool get _temSalvarComo =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);
}
