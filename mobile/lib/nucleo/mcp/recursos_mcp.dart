// Recursos (documentos que o cliente lê) e prompts (texto pronto de sessão)
// do MCP. Muitos clientes só usam ferramentas, por isso o conhecimento vai
// também por ferramenta (DECISOES IC3); estes existem para quem suporta.
class RecursoMcp {
  const RecursoMcp({required this.uri, required this.nome, required this.descricao, required this.ler});

  final String uri;
  final String nome;
  final String descricao;

  /// O texto do recurso, lido só quando pedido.
  final Future<String> Function() ler;

  static const tipoJson = 'application/json';

  Map<String, dynamic> paraLista() => {'uri': uri, 'name': nome, 'description': descricao, 'mimeType': tipoJson};

  Future<Map<String, dynamic>> paraLeitura() async => {'uri': uri, 'mimeType': tipoJson, 'text': await ler()};
}

class PromptMcp {
  const PromptMcp({required this.nome, required this.descricao, required this.texto});

  final String nome;
  final String descricao;
  final String texto;

  Map<String, dynamic> paraLista() => {'name': nome, 'description': descricao};

  Map<String, dynamic> paraLeitura() => {
        'description': descricao,
        'messages': [
          {
            'role': 'user',
            'content': {'type': 'text', 'text': texto},
          },
        ],
      };
}
