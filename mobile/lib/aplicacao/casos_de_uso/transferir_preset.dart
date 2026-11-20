// Importar e exportar o preset como JSON. O arquivo vem de fora do app: tudo
// o que pode dar errado nele (não é JSON, é JSON mas não é preset, o disco
// recusou) vira um resultado com frase para a pessoa, e a causa real vai
// para o log.
import 'dart:convert';

import '../../dados/arquivos_preset.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/registro.dart';

sealed class ResultadoImportacao {
  const ResultadoImportacao();
}

final class PresetImportado extends ResultadoImportacao {
  const PresetImportado(this.documento);
  final DocumentoPreset documento;
}

final class ImportacaoCancelada extends ResultadoImportacao {
  const ImportacaoCancelada();
}

final class ImportacaoRecusada extends ResultadoImportacao {
  const ImportacaoRecusada(this.motivo);
  final String motivo;
}

sealed class ResultadoExportacao {
  const ResultadoExportacao();
}

final class PresetExportado extends ResultadoExportacao {
  const PresetExportado(this.destino);
  final DestinoExportacao destino;
}

final class ExportacaoFalhou extends ResultadoExportacao {
  const ExportacaoFalhou(this.motivo);
  final String motivo;
}

class TransferirPreset {
  const TransferirPreset(this._arquivos);

  final ArquivosPreset _arquivos;

  /// Nome de arquivo quando o do preset não tem nenhum caractere aproveitável.
  static const nomePadrao = 'preset';

  Future<ResultadoImportacao> importar() async {
    final String? texto;
    try {
      texto = await _arquivos.lerEscolhido();
    } on Exception catch (erro, pilha) {
      registro.e('importação: arquivo não foi lido', error: erro, stackTrace: pilha);
      return const ImportacaoRecusada('Não foi possível ler o arquivo.');
    }
    if (texto == null) return const ImportacaoCancelada();
    return interpretar(texto);
  }

  /// O texto de um arquivo importado, já validado como preset da Anagram.
  static ResultadoImportacao interpretar(String texto) {
    try {
      final json = jsonDecode(texto);
      if (json is! Map<String, dynamic>) throw const FormatException('o conteúdo não é um objeto JSON.');
      return PresetImportado(DocumentoPreset.doJson(json));
    } on FormatException catch (erro) {
      registro.w('importação recusada', error: erro);
      return ImportacaoRecusada('Arquivo não é um preset da Anagram: ${erro.message}');
    }
  }

  Future<ResultadoExportacao> exportar(DocumentoPreset documento) async {
    final texto = const JsonEncoder.withIndent(' ').convert(documento.paraJson());
    try {
      return PresetExportado(await _arquivos.gravar(nomeDeArquivo(documento.nome), texto));
    } on Exception catch (erro, pilha) {
      registro.e('exportação: arquivo não foi gravado', error: erro, stackTrace: pilha);
      return const ExportacaoFalhou('Não foi possível gravar o arquivo.');
    }
  }

  /// Só letras, dígitos, espaço, hífen e sublinhado: o nome do preset é livre
  /// e pode ter barra ou dois-pontos, que o sistema de arquivos recusa.
  static String nomeDeArquivo(String nome) {
    final limpo = nome.replaceAll(RegExp(r'[^\w\- ]'), '').trim();
    return limpo.isEmpty ? nomePadrao : limpo;
  }
}
