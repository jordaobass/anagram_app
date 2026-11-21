// Registro em arquivo no computador: `anagram-app.log` na pasta de logs do
// sistema, girando ao passar do limite e guardando poucas cópias, para nunca
// encher o disco de quem só toca baixo.
import 'dart:io';

import 'package:logger/logger.dart';

import '../nucleo/registro.dart';
import 'registro_em_arquivo.dart';

const _nomeDoApp = 'Anagram App';

RegistroEmArquivo? ligarRegistroEmArquivo() {
  final pasta = pastaDeRegistro(Platform.operatingSystem, Platform.environment);
  if (pasta == null) return null;
  try {
    pasta.createSync(recursive: true);
  } on FileSystemException catch (erro) {
    registro.w('registro: não criou a pasta ${pasta.path}; segue só no console', error: erro);
    return null;
  }
  final arquivo = ArquivoDeRegistro(pasta);
  saidasDoRegistro.acrescentar(arquivo);
  // a primeira linha de cada sessão diz onde ela rodou: é o que se pergunta primeiro num relato
  registro.i('Anagram App iniciando em ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
  return arquivo;
}

/// A pasta de logs de cada sistema; variável vazia vale como ausente.
Directory? pastaDeRegistro(String sistema, Map<String, String> ambiente) {
  String? variavel(String nome) {
    final valor = ambiente[nome]?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  final partes = switch (sistema) {
    'windows' => [variavel('LOCALAPPDATA'), _nomeDoApp, 'logs'],
    'macos' => [variavel('HOME'), 'Library', 'Logs', _nomeDoApp],
    'linux' => [variavel('XDG_STATE_HOME') ?? _juntar([variavel('HOME'), '.local', 'state']), 'anagram-app', 'logs'],
    _ => [null],
  };
  return partes.contains(null) ? null : Directory(_juntar(partes)!);
}

String? _juntar(List<String?> partes) => partes.contains(null) ? null : partes.join(Platform.pathSeparator);

class ArquivoDeRegistro extends LogOutput implements RegistroEmArquivo {
  ArquivoDeRegistro(this.pasta, {this.limiteBytes = 1024 * 1024, this.copias = 2});

  final Directory pasta;
  final int limiteBytes;
  final int copias;

  File get _atual => _arquivo('anagram-app.log');

  File _copia(int numero) => _arquivo('anagram-app.$numero.log');

  File _arquivo(String nome) => File('${pasta.path}${Platform.pathSeparator}$nome');

  @override
  String get caminho => _atual.path;

  @override
  void output(OutputEvent event) => gravar(event.lines.join('\n'));

  /// Acrescenta o texto numa linha nova, girando antes se o arquivo passou do limite.
  void gravar(String texto) {
    try {
      _girarSePreciso();
      _atual.writeAsStringSync('$texto\n', mode: FileMode.append);
    } on FileSystemException {
      // sem disco ou sem permissão o app segue: o console ainda recebe a linha,
      // e registrar esta falha no próprio registro voltaria para cá
    }
  }

  void _girarSePreciso() {
    if (!_atual.existsSync() || _atual.lengthSync() < limiteBytes) return;
    final maisVelha = _copia(copias);
    if (maisVelha.existsSync()) maisVelha.deleteSync();
    for (var numero = copias - 1; numero >= 1; numero--) {
      if (_copia(numero).existsSync()) _copia(numero).renameSync(_copia(numero + 1).path);
    }
    _atual.renameSync(_copia(1).path);
  }

  @override
  Future<String> ultimasLinhas(int quantas) async {
    final linhas = <String>[
      for (final arquivo in [_copia(1), _atual])
        if (await arquivo.exists()) ...(await arquivo.readAsLines()),
    ];
    final inicio = linhas.length > quantas ? linhas.length - quantas : 0;
    return linhas.sublist(inicio).join('\n');
  }
}
