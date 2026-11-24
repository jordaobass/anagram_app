// A pasta de backups dos presets no computador (DECISOES BK1, BK2). Nada sai
// do computador (D9): são arquivos locais, no formato do JSON exportado. No
// celular e no web não existe: a seção some das Configurações.
import '../nucleo/modelo/copia_preset.dart';
import 'copias_de_seguranca_io.dart' if (dart.library.js_interop) 'copias_de_seguranca_web.dart' as plataforma;

abstract interface class PastaDeCopias {
  /// Caminho completo da pasta `backups`, para a tela mostrar e abrir.
  String get caminho;

  /// Grava o backup automático na pasta do dia e só depois aplica a retenção
  /// (BK3). Falhou ao gravar = exceção, e nada antigo foi apagado. Devolve o
  /// caminho do arquivo gravado.
  Future<String> guardar(OrigemDaCopia origem, String texto);

  /// Uma pasta nova para o backup completo (BK4); a retenção não a toca.
  Future<LoteDeCopias> novoLote();

  /// Todos os backups, do mais novo para o mais velho.
  Future<List<CopiaGuardada>> listar();

  Future<String> ler(CopiaGuardada copia);
}

/// A pasta de um backup completo, que recebe um preset de cada vez.
abstract interface class LoteDeCopias {
  String get caminho;

  Future<String> guardar(OrigemDaCopia origem, String texto);
}

/// A pasta de backups da plataforma; `null` onde não há disco (celular, web).
/// No computador sem como achar a pasta (variável de ambiente em branco),
/// devolve uma pasta que recusa gravar: sem backup, nada é gravado na
/// pedaleira até a pessoa desligar o backup automático (BK1).
Future<PastaDeCopias?> ligarPastaDeCopias() => plataforma.ligarPastaDeCopias();
