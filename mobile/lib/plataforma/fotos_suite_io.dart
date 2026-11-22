// A pasta de dados do Darkglass Suite é a "appData" do Electron mais
// "Darkglass Suite" (main.js do Suite 6.11.4); os tons baixados do TONE3000
// ficam em t3k/<neural-models-t3k|irs-t3k>/<id>/tone.jpg (função rQe).
// No macOS com sandbox, o HOME aponta para o contêiner do app e a pasta não é
// achada: o bloco fica com a arte dele, sem erro.
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'fotos_suite.dart';

FotosDoSuite? fotosDoSuiteInstalado() {
  final pasta = pastaDoSuite(Platform.operatingSystem, Platform.environment);
  return pasta == null || !pasta.existsSync() ? null : FotosNaPasta(pasta.path);
}

ImageProvider? imagemDeArquivo(String caminho) => FileImage(File(caminho));

/// A pasta de dados do Suite em cada sistema de computador; variável em
/// branco vale como ausente.
Directory? pastaDoSuite(String sistema, Map<String, String> ambiente) {
  String? variavel(String nome) {
    final valor = ambiente[nome]?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  final dadosDoApp = switch (sistema) {
    'windows' => variavel('APPDATA') ?? _juntar([variavel('USERPROFILE'), 'AppData', 'Roaming']),
    'macos' => _juntar([variavel('HOME'), 'Library', 'Application Support']),
    'linux' => variavel('XDG_CONFIG_HOME') ?? _juntar([variavel('HOME'), '.config']),
    _ => null,
  };
  return dadosDoApp == null ? null : Directory(_juntar([dadosDoApp, 'Darkglass Suite'])!);
}

String? _juntar(List<String?> partes) => partes.contains(null) ? null : partes.join(Platform.pathSeparator);

class FotosNaPasta implements FotosDoSuite {
  FotosNaPasta(this.pasta);

  final String pasta;

  /// O disco é lido uma vez por tom: a arte é redesenhada a cada quadro.
  final _jaProcuradas = <String, String?>{};

  @override
  String? fotoDoTom(int id, {required bool ehIr}) {
    final subpasta = ehIr ? 'irs-t3k' : 'neural-models-t3k';
    final base = _juntar([pasta, 't3k', subpasta, '$id', 'tone'])!;
    return _jaProcuradas.putIfAbsent(base, () => _primeiraQueExiste(base));
  }

  static String? _primeiraQueExiste(String base) {
    for (final extensao in const ['jpg', 'jpeg', 'png', 'webp']) {
      if (File('$base.$extensao').existsSync()) return '$base.$extensao';
    }
    return null;
  }
}
