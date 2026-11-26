// A biblioteca de presets por banda em uso (DECISOES BB1–BB4): a coleção do
// build primeiro e, depois dela, as coleções dos arquivos da pasta da
// biblioteca, na ordem em que entraram. Importar grava um arquivo novo na
// pasta (uma coleção, com o nome do arquivo escolhido) e nunca mistura com as
// que já estão; cada coleção importada pode ser exportada ou apagada (o
// arquivo sai da pasta), e exportar tudo grava a biblioteca inteira num
// arquivo que o importar lê. Arquivo posto na pasta por fora entra quando a
// biblioteca é relida (ao ligar o modo Biblioteca). O arquivo vem de fora do
// app: o que pode dar errado nele vira um resultado com frase para a pessoa,
// e a causa vai para o log.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/arquivos_biblioteca.dart';
import '../../dados/arquivos_preset.dart';
import '../../dados/preferencias_biblioteca.dart';
import '../../nucleo/modelo/biblioteca_bandas.dart';
import '../../nucleo/registro.dart';
import '../../plataforma/pasta_biblioteca.dart';
import '../provedores.dart';

/// A pasta de verdade vem do `main` (path_provider); sem ela, só em memória.
final pastaBibliotecaProvider = Provider<PastaBiblioteca>((ref) => PastaBibliotecaEmMemoria());

final preferenciasBibliotecaProvider = Provider<PreferenciasBiblioteca>((ref) => PreferenciasBibliotecaLocais());

final arquivosBibliotecaProvider = Provider<ArquivosBiblioteca>((ref) => const ArquivosBiblioteca());

final fonteBibliotecaProvider = AsyncNotifierProvider<ControladorFonteBiblioteca, FonteBiblioteca>(
  ControladorFonteBiblioteca.new,
);

/// Os presets prontos, montados com o catálogo de blocos e a tabela de
/// gabinetes (sem ela, os gabinetes ficam com o IR padrão).
final bibliotecaBandasProvider = FutureProvider<BibliotecaBandas>((ref) async {
  final fonte = await ref.watch(fonteBibliotecaProvider.future);
  final catalogo = await ref.watch(catalogoProvider.future);
  final indice = await ref.watch(indiceMiniaturasProvider.future);
  return BibliotecaBandas.daFonte(fonte, catalogo, gabinetes: indice.escolhasDeGabinete);
});

/// Nome da coleção do build dentro do arquivo exportado (na tela ela aparece
/// com o nome no idioma em uso).
const nomeColecaoEmbutida = 'Built-in';

sealed class ResultadoImportacaoBiblioteca {
  const ResultadoImportacaoBiblioteca();
}

final class BibliotecaImportada extends ResultadoImportacaoBiblioteca {
  const BibliotecaImportada({required this.colecoes, required this.adicionados, required this.ignorados});

  /// Os nomes com que as coleções entraram (já sem repetir os existentes).
  final List<String> colecoes;
  final int adicionados;

  /// Presets do arquivo que não montam (bloco que o app não conhece).
  final int ignorados;
}

final class ImportacaoBibliotecaCancelada extends ResultadoImportacaoBiblioteca {
  const ImportacaoBibliotecaCancelada();
}

final class ImportacaoBibliotecaRecusada extends ResultadoImportacaoBiblioteca {
  const ImportacaoBibliotecaRecusada();
}

/// De onde veio uma coleção: o arquivo da pasta e a posição dela nele (um
/// arquivo exportado inteiro, posto na pasta, traz várias).
typedef _Origem = ({String arquivo, int indice});

class ControladorFonteBiblioteca extends AsyncNotifier<FonteBiblioteca> {
  PastaBiblioteca get _pasta => ref.read(pastaBibliotecaProvider);

  /// Nome na tela → arquivo da pasta (a coleção do build não tem).
  final _origens = <String, _Origem>{};

  @override
  Future<FonteBiblioteca> build() async {
    final embutida = await _doBuild();
    await _migrarDasPreferencias(embutida);
    _origens.clear();
    var fonte = FonteBiblioteca([?embutida]);
    for (final arquivo in await _pasta.listar()) {
      try {
        fonte = _acrescentar(fonte, FonteBiblioteca.doTexto(arquivo.texto, nomeDoArquivo: arquivo.nome), arquivo.nome);
      } on FormatException catch (erro) {
        registro.w('biblioteca: ${arquivo.nome}.json não é uma coleção; fica de fora', error: erro);
      }
    }
    return fonte;
  }

  FonteBiblioteca _acrescentar(FonteBiblioteca fonte, FonteBiblioteca doArquivo, String arquivo) {
    final juntas = fonte.comImportada(doArquivo);
    final novas = juntas.colecoes.skip(fonte.colecoes.length).toList();
    for (var i = 0; i < novas.length; i++) {
      _origens[novas[i].nome] = (arquivo: arquivo, indice: i);
    }
    return juntas;
  }

  Future<ColecaoDaFonte?> _doBuild() async {
    final texto = await ref.read(textoBibliotecaBandasProvider.future);
    if (texto == null) return null;
    try {
      return FonteBiblioteca.doTexto(texto, nomeDoArquivo: nomeColecaoEmbutida).colecoes.first.comoEmbutida();
    } on FormatException catch (erro) {
      registro.w('biblioteca do build malformada', error: erro);
      return null;
    }
  }

  /// O que estava nas preferências (BB2, BB3) vira arquivos da pasta, uma vez.
  /// A biblioteca do BB2 juntava as bandas do build com as importadas: só as
  /// que não são do build viram a coleção "Import". As preferências só são
  /// apagadas depois que a pasta gravou.
  Future<void> _migrarDasPreferencias(ColecaoDaFonte? embutida) async {
    final preferencias = ref.read(preferenciasBibliotecaProvider);
    final colecoes = await preferencias.lerColecoes();
    final antiga = await preferencias.lerAntiga();
    if (colecoes == null && antiga == null) return;
    try {
      for (final colecao in _colecoesAntigas(colecoes, antiga, embutida)) {
        await _pasta.criar(colecao.nome, FonteBiblioteca([colecao]).paraTexto());
      }
      await preferencias.apagarTudo();
      registro.i('biblioteca: coleções das preferências levadas para a pasta');
    } on Exception catch (erro) {
      registro.w('biblioteca: as coleções das preferências não foram para a pasta; tenta de novo depois', error: erro);
    }
  }

  static List<ColecaoDaFonte> _colecoesAntigas(String? colecoes, String? antiga, ColecaoDaFonte? embutida) {
    try {
      if (colecoes != null) return FonteBiblioteca.doTexto(colecoes).colecoes;
      final doBuild = {for (final banda in embutida?.bandas ?? const <BandaDaFonte>[]) banda.nome};
      final bandas = [
        for (final banda in FonteBiblioteca.doTexto(antiga!).colecoes.expand((c) => c.bandas))
          if (!doBuild.contains(banda.nome)) banda,
      ];
      return [if (bandas.isNotEmpty) ColecaoDaFonte('Import', bandas)];
    } on FormatException catch (erro) {
      registro.w('biblioteca: a guardada nas preferências não abre', error: erro);
      return const [];
    }
  }

  /// Escolhe o arquivo e o acrescenta como coleção nova.
  Future<ResultadoImportacaoBiblioteca> importar() async {
    final ArquivoEscolhido? arquivo;
    try {
      arquivo = await ref.read(arquivosBibliotecaProvider).lerEscolhido();
    } on Exception catch (erro, pilha) {
      registro.e('biblioteca: arquivo não foi lido', error: erro, stackTrace: pilha);
      return const ImportacaoBibliotecaRecusada();
    }
    if (arquivo == null) return const ImportacaoBibliotecaCancelada();
    return importarTexto(arquivo.texto, nomeDoArquivo: arquivo.nome);
  }

  /// Só entra o arquivo que tenha ao menos um preset que o app monte: senão a
  /// biblioteca ganharia uma coleção que nunca aparece na lista. Cada coleção
  /// do arquivo vira um arquivo da pasta, no formato do exportar.
  Future<ResultadoImportacaoBiblioteca> importarTexto(String texto, {String? nomeDoArquivo}) async {
    final FonteBiblioteca importada;
    try {
      importada = FonteBiblioteca.doTexto(texto, nomeDoArquivo: nomeDoArquivo);
    } on FormatException catch (erro) {
      registro.w('biblioteca: importação recusada', error: erro);
      return const ImportacaoBibliotecaRecusada();
    }
    final catalogo = await ref.read(catalogoProvider.future);
    final montados = BibliotecaBandas.daFonte(importada, catalogo).quantidadePresets;
    if (montados == 0) return const ImportacaoBibliotecaRecusada();
    final atual = await future;
    var fonte = atual;
    try {
      for (final colecao in importada.colecoes) {
        final doArquivo = FonteBiblioteca([colecao]);
        final arquivo = await _pasta.criar(colecao.nome, doArquivo.paraTexto());
        fonte = _acrescentar(fonte, doArquivo, arquivo);
      }
    } on Exception catch (erro, pilha) {
      registro.e('biblioteca: a coleção não foi gravada na pasta', error: erro, stackTrace: pilha);
      if (!identical(fonte, atual)) state = AsyncData(fonte);
      return const ImportacaoBibliotecaRecusada();
    }
    state = AsyncData(fonte);
    return BibliotecaImportada(
      colecoes: [for (final c in fonte.colecoes.skip(atual.colecoes.length)) c.nome],
      adicionados: montados,
      ignorados: importada.quantidadePresets - montados,
    );
  }

  /// Grava a biblioteca inteira, ou só a [colecao], onde a pessoa escolher
  /// (no celular, copia). Nulo: o disco recusou.
  Future<DestinoExportacao?> exportar({String? colecao}) async {
    final fonte = await future;
    final escolhida = colecao == null ? null : fonte.colecao(colecao);
    final exportada = escolhida == null ? fonte : FonteBiblioteca([escolhida]);
    try {
      return await ref
          .read(arquivosBibliotecaProvider)
          .gravar(escolhida?.nome ?? 'biblioteca-presets', exportada.paraTexto());
    } on Exception catch (erro, pilha) {
      registro.e('biblioteca: exportação não foi gravada', error: erro, stackTrace: pilha);
      return null;
    }
  }

  /// Tira uma coleção importada: o arquivo dela sai da pasta (ou, se o
  /// arquivo trouxer outras, é regravado sem ela). A do build não sai, e o
  /// que já foi gravado na pedaleira fica. Devolve se tirou.
  Future<bool> removerColecao(String nome) async {
    final atual = await future;
    final origem = _origens[nome];
    if (origem == null || (atual.colecao(nome)?.embutida ?? true)) return false;
    final irmas = [
      for (final MapEntry(:key, :value) in _origens.entries)
        if (value.arquivo == origem.arquivo) key,
    ];
    try {
      if (irmas.length == 1) {
        await _pasta.apagar(origem.arquivo);
      } else {
        await _pasta.regravar(
          origem.arquivo,
          FonteBiblioteca([
            for (final irma in irmas)
              if (irma != nome) atual.colecao(irma)!,
          ]).paraTexto(),
        );
      }
    } on Exception catch (erro, pilha) {
      registro.e('biblioteca: o arquivo da coleção não saiu da pasta', error: erro, stackTrace: pilha);
      return false;
    }
    _origens.remove(nome);
    state = AsyncData(atual.semColecao(nome));
    return true;
  }
}
