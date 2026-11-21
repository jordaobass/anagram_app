// O arquivo de registro do app, onde a plataforma tem sistema de arquivos.
// No web não existe: a seção some das Configurações.
import 'registro_em_arquivo_io.dart' if (dart.library.js_interop) 'registro_em_arquivo_web.dart' as plataforma;

abstract interface class RegistroEmArquivo {
  /// Caminho completo do arquivo atual, para a pessoa achar ou citar.
  String get caminho;

  /// As linhas mais novas (do arquivo atual e da cópia anterior), para colar numa issue.
  Future<String> ultimasLinhas(int quantas);
}

/// Liga o registro em arquivo na pasta de logs do sistema; `null` onde não há onde gravar.
RegistroEmArquivo? ligarRegistroEmArquivo() => plataforma.ligarRegistroEmArquivo();
