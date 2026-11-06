// Enquadramento dos relatórios HID da Anagram.
//
// Portado do `tools/anagram.py` do projeto anagram-tone-maker (MIT, basster6):
//   relatório = [0x01] + 63 bytes de carga, completados com zero
//   quadro    = "DSTART" + JSON {"action", "payload"} + "DEND"
// Depois do último pedaço vai um relatório só de preenchimento (flush).
// A resposta chega igual e é remontada tirando os bytes 0x00 e 0x01.
import 'dart:convert';
import 'dart:typed_data';

/// Constantes do protocolo, conferidas no código de referência.
abstract final class ProtocoloAnagram {
  static const int idFornecedor = 0x2FA6;
  static const int idProduto = 0x2500;
  static const List<int> paginasDeUsoFornecedor = [0xFF00, 0xFF];
  static const int tamanhoRelatorio = 64;
  static const int idRelatorio = 0x01;
  static const int tamanhoCarga = tamanhoRelatorio - 1;
  static const String marcadorInicio = 'DSTART';
  static const String marcadorFim = 'DEND';
}

/// Uma mensagem do protocolo: ação + carga JSON.
class MensagemAnagram {
  const MensagemAnagram(this.acao, this.carga);

  final String acao;
  final Map<String, dynamic> carga;

  Map<String, dynamic> paraJson() => {'action': acao, 'payload': carga};
}

/// Converte uma mensagem nos relatórios de 64 bytes que vão para o fio.
class CodificadorQuadros {
  const CodificadorQuadros();

  List<Uint8List> codificar(MensagemAnagram mensagem) {
    final texto = ProtocoloAnagram.marcadorInicio +
        jsonEncode(mensagem.paraJson()) +
        ProtocoloAnagram.marcadorFim;
    return fatiar(utf8.encode(texto));
  }

  /// Fatia bytes em relatórios, mais o relatório de preenchimento final.
  List<Uint8List> fatiar(List<int> bytes) {
    const carga = ProtocoloAnagram.tamanhoCarga;
    final quantidade = (bytes.length + carga - 1) ~/ carga + 1;
    return List.generate(quantidade, (indice) {
      final relatorio = Uint8List(ProtocoloAnagram.tamanhoRelatorio);
      relatorio[0] = ProtocoloAnagram.idRelatorio;
      final inicio = indice * carga;
      if (inicio < bytes.length) {
        final fim = (inicio + carga).clamp(0, bytes.length);
        relatorio.setRange(1, 1 + fim - inicio, bytes, inicio);
      }
      return relatorio;
    });
  }
}

/// Erro de quadro: chegou algo entre os marcadores que não é JSON.
class QuadroMalformado implements Exception {
  const QuadroMalformado(this.detalhe);
  final String detalhe;

  @override
  String toString() => 'Quadro malformado: $detalhe';
}

/// Junta relatórios recebidos até formar uma mensagem completa.
///
/// Os bytes 0x00 e 0x01 são descartados (preenchimento e id do relatório),
/// exatamente como no código de referência.
class MontadorQuadros {
  final List<int> _acumulado = [];

  void descartar() => _acumulado.clear();

  /// Acrescenta um relatório. Devolve o JSON decodificado quando o quadro
  /// fecha, ou `null` enquanto faltar pedaço.
  Map<String, dynamic>? acrescentar(List<int> relatorio) {
    for (final byte in relatorio) {
      if (byte != 0x00 && byte != ProtocoloAnagram.idRelatorio) {
        _acumulado.add(byte);
      }
    }
    return _tentarFechar();
  }

  Map<String, dynamic>? _tentarFechar() {
    final texto = latin1.decode(_acumulado);
    final inicio = texto.indexOf(ProtocoloAnagram.marcadorInicio);
    final fim = texto.lastIndexOf(ProtocoloAnagram.marcadorFim);
    if (inicio == -1 || fim <= inicio) return null;
    final corpo = _acumulado.sublist(
      inicio + ProtocoloAnagram.marcadorInicio.length,
      fim,
    );
    _acumulado.clear();
    try {
      final valor = jsonDecode(utf8.decode(corpo, allowMalformed: true));
      if (valor is Map<String, dynamic>) return valor;
      throw const QuadroMalformado('o corpo não é um objeto JSON');
    } on FormatException catch (erro) {
      throw QuadroMalformado(erro.message);
    }
  }
}
