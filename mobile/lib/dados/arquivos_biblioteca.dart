// Escolher o arquivo de biblioteca a importar, com o nome dele: a coleção
// importada leva o nome do arquivo (DECISOES BB3). Gravar o exportado é o
// mesmo de [ArquivosPreset] (no celular e na web, copia o JSON).
import 'package:file_selector/file_selector.dart';

import 'arquivos_preset.dart';

class ArquivoEscolhido {
  const ArquivoEscolhido(this.nome, this.texto);

  /// Sem a extensão (`.json`).
  final String nome;
  final String texto;
}

class ArquivosBiblioteca {
  const ArquivosBiblioteca([this._arquivos = const ArquivosPreset()]);

  final ArquivosPreset _arquivos;

  static const _tipo = XTypeGroup(
    label: 'Biblioteca de presets',
    extensions: ['json'],
    mimeTypes: ['application/json'],
  );

  /// `null` se a pessoa cancelou.
  Future<ArquivoEscolhido?> lerEscolhido() async {
    final arquivo = await openFile(acceptedTypeGroups: const [_tipo]);
    if (arquivo == null) return null;
    return ArquivoEscolhido(
      arquivo.name.replaceFirst(RegExp(r'\.json$', caseSensitive: false), ''),
      await arquivo.readAsString(),
    );
  }

  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) => _arquivos.gravar(nomeSugerido, texto);
}
