// A foto de um tom do TONE3000 que a PESSOA baixou pelo Darkglass Suite: o
// Suite a guarda na pasta de dados dele, fora do app. Só existe no computador
// com o Suite instalado; no celular e no navegador não há onde procurar.
import 'package:flutter/widgets.dart';

import 'fotos_suite_io.dart' if (dart.library.js_interop) 'fotos_suite_web.dart' as plataforma;

abstract interface class FotosDoSuite {
  /// Caminho da foto do tom [id], se o Suite a baixou; senão null.
  String? fotoDoTom(int id, {required bool ehIr});
}

/// A pasta do Suite instalado nesta máquina, ou null (sem Suite, celular, web).
FotosDoSuite? fotosDoSuiteInstalado() => plataforma.fotosDoSuiteInstalado();

/// A imagem de um arquivo local; null onde não há sistema de arquivos.
ImageProvider? imagemDeArquivo(String caminho) => plataforma.imagemDeArquivo(caminho);
