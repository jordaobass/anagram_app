// A pasta da biblioteca de presets (DECISOES BB4): um arquivo JSON por coleção
// importada, no formato do exportar. Nada sai do computador (D9). No
// computador e no celular é uma pasta `biblioteca` dentro da pasta de dados do
// app (no macOS, dentro do sandbox); na web, as preferências do navegador.
// Arquivo que a pessoa puser na pasta (um export do Anagram App, uma coleção
// recebida de alguém) entra na biblioteca da próxima vez que ela for lida.
import 'pasta_biblioteca_io.dart' if (dart.library.js_interop) 'pasta_biblioteca_web.dart' as plataforma;

/// Um arquivo da pasta: o nome sem `.json` e o texto.
class ArquivoDaPasta {
  const ArquivoDaPasta(this.nome, this.texto);

  final String nome;
  final String texto;
}

abstract interface class PastaBiblioteca {
  /// Caminho completo, para a tela mostrar e abrir; vazio onde não é pasta.
  String get caminho;

  /// Cria a pasta se ainda não existe (para mostrá-la vazia).
  Future<void> preparar();

  /// Os arquivos, na ordem em que entraram (o mais antigo primeiro).
  Future<List<ArquivoDaPasta>> listar();

  /// Grava um arquivo novo com o nome mais perto de [nomeSugerido] que não
  /// esteja em uso; devolve o nome usado (sem `.json`).
  Future<String> criar(String nomeSugerido, String texto);

  /// Troca o texto de um arquivo que já existe.
  Future<void> regravar(String nome, String texto);

  Future<void> apagar(String nome);
}

/// A pasta da plataforma; a de memória se o sistema não der uma.
Future<PastaBiblioteca> ligarPastaBiblioteca() => plataforma.ligarPastaBiblioteca();

/// Nome de arquivo seguro e livre: "Muse", "Muse (2)"…
String nomeLivre(String sugerido, Set<String> usados) {
  final base = sugerido.replaceAll(RegExp(r'[^\p{L}\p{N}_\- .()]', unicode: true), '').trim();
  final limpo = base.isEmpty || base.startsWith('.') ? 'colecao' : base;
  var nome = limpo;
  for (var n = 2; usados.contains(nome.toLowerCase()); n++) {
    nome = '$limpo ($n)';
  }
  return nome;
}

/// Em memória: testes, e onde o sistema não deu uma pasta (a biblioteca
/// funciona, só não sobrevive a fechar o app).
class PastaBibliotecaEmMemoria implements PastaBiblioteca {
  PastaBibliotecaEmMemoria([Map<String, String>? arquivos]) : arquivos = arquivos ?? {};

  final Map<String, String> arquivos;

  @override
  String get caminho => '';

  @override
  Future<void> preparar() async {}

  @override
  Future<List<ArquivoDaPasta>> listar() async => [
    for (final MapEntry(key: nome, value: texto) in arquivos.entries) ArquivoDaPasta(nome, texto),
  ];

  @override
  Future<String> criar(String nomeSugerido, String texto) async {
    final nome = nomeLivre(nomeSugerido, {for (final n in arquivos.keys) n.toLowerCase()});
    arquivos[nome] = texto;
    return nome;
  }

  @override
  Future<void> regravar(String nome, String texto) async => arquivos[nome] = texto;

  @override
  Future<void> apagar(String nome) async => arquivos.remove(nome);
}
