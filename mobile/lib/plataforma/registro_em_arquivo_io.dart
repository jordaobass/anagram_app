// Registro em arquivo no computador: `anagram-app.log` na pasta de logs do
// sistema, girando ao passar do limite e guardando poucas cópias, para nunca
// encher o disco de quem só toca baixo. As linhas vão ao disco em lote.
import 'dart:async';
import 'dart:convert';
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

/// As linhas entram numa fila e vão ao disco em lote (a cada
/// [intervalo] ou [loteMaximo] linhas): com o "ida e volta" de cada envio ao
/// vivo, abrir, medir e fechar o arquivo por linha custava mais que o envio.
/// Aviso e erro vão na hora, com o que estava na fila: o app pode cair logo
/// depois. O tamanho do arquivo é contado em memória (lido uma vez).
class ArquivoDeRegistro extends LogOutput implements RegistroEmArquivo {
  ArquivoDeRegistro(this.pasta,
      {this.limiteBytes = 1024 * 1024,
      this.copias = 2,
      this.intervalo = const Duration(milliseconds: 200),
      this.loteMaximo = 100});

  final Directory pasta;
  final int limiteBytes;
  final int copias;
  final Duration intervalo;
  final int loteMaximo;
  final _fila = <String>[];
  Timer? _agendado;

  /// Bytes do arquivo atual; nulo = ainda não lido (ou o disco falhou).
  int? _tamanho;

  File get _atual => _arquivo('anagram-app.log');

  File _copia(int numero) => _arquivo('anagram-app.$numero.log');

  File _arquivo(String nome) => File('${pasta.path}${Platform.pathSeparator}$nome');

  @override
  String get caminho => _atual.path;

  @override
  void output(OutputEvent event) =>
      gravar(event.lines.join('\n'), urgente: event.level.value >= Level.warning.value);

  @override
  Future<void> destroy() async => descarregar();

  /// Põe o texto na fila; [urgente] (aviso, erro) vai ao disco na hora.
  void gravar(String texto, {bool urgente = false}) {
    _fila.add('$texto\n');
    if (urgente || _fila.length >= loteMaximo) return descarregar();
    _agendado ??= Timer(intervalo, descarregar);
  }

  /// Escreve a fila no arquivo, girando quando ele passa do limite.
  void descarregar() {
    _agendado?.cancel();
    _agendado = null;
    if (_fila.isEmpty) return;
    final linhas = List.of(_fila);
    _fila.clear();
    try {
      _escreverGirando(linhas);
    } on FileSystemException {
      // sem disco ou sem permissão o app segue: o console ainda recebe a linha,
      // e registrar esta falha no próprio registro voltaria para cá
      _tamanho = null;
    }
  }

  /// Junta as linhas em blocos; antes de cada linha, se o arquivo (com o
  /// bloco) já passou do limite, escreve o bloco e gira.
  void _escreverGirando(List<String> linhas) {
    var tamanho = _tamanho ??= _atual.existsSync() ? _atual.lengthSync() : 0;
    final bloco = StringBuffer();
    for (final linha in linhas) {
      if (tamanho >= limiteBytes) {
        _acrescentar(bloco);
        _girar();
        tamanho = 0;
      }
      bloco.write(linha);
      tamanho += utf8.encode(linha).length;
    }
    _acrescentar(bloco);
    _tamanho = tamanho;
  }

  void _acrescentar(StringBuffer bloco) {
    if (bloco.isEmpty) return;
    _atual.writeAsStringSync(bloco.toString(), mode: FileMode.append, flush: false);
    bloco.clear();
  }

  void _girar() {
    final maisVelha = _copia(copias);
    if (maisVelha.existsSync()) maisVelha.deleteSync();
    for (var numero = copias - 1; numero >= 1; numero--) {
      if (_copia(numero).existsSync()) _copia(numero).renameSync(_copia(numero + 1).path);
    }
    if (_atual.existsSync()) _atual.renameSync(_copia(1).path);
  }

  @override
  Future<String> ultimasLinhas(int quantas) async {
    descarregar();
    final linhas = <String>[
      for (final arquivo in [_copia(1), _atual])
        if (await arquivo.exists()) ...(await arquivo.readAsLines()),
    ];
    final inicio = linhas.length > quantas ? linhas.length - quantas : 0;
    return linhas.sublist(inicio).join('\n');
  }
}
