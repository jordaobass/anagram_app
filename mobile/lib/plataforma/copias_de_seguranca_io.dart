// Backups dos presets em disco, no computador (DECISOES BK1–BK4):
//   Windows  %LOCALAPPDATA%\Anagram App\backups
//   macOS    a pasta de suporte do app (path_provider; dentro do sandbox)
//   Linux    $XDG_DATA_HOME/anagram-app/backups (~/.local/share)
// As operações de arquivo são síncronas de propósito: cada preset tem poucos
// KB, e o backup vem sempre antes de uma conversa USB que leva centenas de ms.
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../nucleo/modelo/copia_preset.dart';
import '../nucleo/registro.dart';
import 'copias_de_seguranca.dart';

const _nomeDoApp = 'Anagram App';

Future<PastaDeCopias?> ligarPastaDeCopias() async {
  final sistema = Platform.operatingSystem;
  if (!const ['windows', 'macos', 'linux'].contains(sistema)) return null;
  final raiz = await _raizDoSistema(sistema);
  if (raiz == null) {
    registro.w('backup: pasta de backups desconhecida neste $sistema; gravar na pedaleira vai pedir para desligar o backup');
    return const PastaIndisponivel();
  }
  registro.i('backup: pasta ${raiz.path}');
  return PastaDeCopiasEmDisco(raiz);
}

Future<Directory?> _raizDoSistema(String sistema) async {
  if (sistema != 'macos') return pastaDeCopias(sistema, Platform.environment);
  try {
    final suporte = await getApplicationSupportDirectory();
    return Directory(_juntar([suporte.path, 'backups']));
  } on Object catch (erro) {
    registro.e('backup: o sistema não deu a pasta de suporte do app', error: erro);
    return null;
  }
}

/// A pasta de backups no Windows e no Linux; variável vazia vale como ausente.
Directory? pastaDeCopias(String sistema, Map<String, String> ambiente) {
  String? variavel(String nome) {
    final valor = ambiente[nome]?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }

  final casa = variavel('HOME');
  final partes = switch (sistema) {
    'windows' => [variavel('LOCALAPPDATA'), _nomeDoApp, 'backups'],
    'linux' => [variavel('XDG_DATA_HOME') ?? (casa == null ? null : _juntar([casa, '.local', 'share'])), 'anagram-app', 'backups'],
    _ => [null],
  };
  return partes.contains(null) ? null : Directory(_juntar(partes.cast<String>()));
}

String _juntar(List<String> partes) => partes.join(Platform.pathSeparator);

/// Sem pasta: todo backup falha com o motivo, e a gravação não acontece.
class PastaIndisponivel implements PastaDeCopias {
  const PastaIndisponivel();

  static const _motivo = 'o sistema não informou onde fica a pasta de dados do app';

  @override
  String get caminho => '';

  @override
  Future<String> guardar(OrigemDaCopia origem, String texto) async => throw const FileSystemException(_motivo);

  @override
  Future<LoteDeCopias> novoLote() async => throw const FileSystemException(_motivo);

  @override
  Future<List<CopiaGuardada>> listar() async => const [];

  @override
  Future<String> ler(CopiaGuardada copia) async => throw const FileSystemException(_motivo);
}

class PastaDeCopiasEmDisco implements PastaDeCopias {
  PastaDeCopiasEmDisco(this.raiz, {DateTime Function()? agora, this.dias = 30, this.maximo = 500})
      : agora = agora ?? DateTime.now;

  final Directory raiz;
  final DateTime Function() agora;

  /// Retenção dos automáticos (BK3): o que vier primeiro.
  final int dias;
  final int maximo;

  @override
  String get caminho => raiz.path;

  @override
  Future<String> guardar(OrigemDaCopia origem, String texto) async {
    final quando = agora();
    final dia = Directory(_juntar([raiz.path, pastaDoDia(quando)]));
    final arquivo = _gravarSemSobrepor(dia, '${horaDaCopia(quando)}_${origem.sufixo}', texto);
    // só depois de o novo estar no disco: se ele falhou, os velhos são tudo o que resta
    _aplicarRetencao(quando, manter: arquivo.path);
    return arquivo.path;
  }

  @override
  Future<LoteDeCopias> novoLote() async {
    final quando = agora();
    final pasta = Directory(_juntar([raiz.path, pastaDoDia(quando), '$prefixoCopiaCompleta${horaDaCopia(quando)}']));
    pasta.createSync(recursive: true);
    return _LoteEmDisco(pasta);
  }

  @override
  Future<List<CopiaGuardada>> listar() async {
    if (!raiz.existsSync()) return const [];
    final copias = <CopiaGuardada>[];
    for (final item in raiz.listSync(recursive: true).whereType<File>()) {
      final relativo = item.path.substring(raiz.path.length + 1);
      final copia = CopiaGuardada.doCaminho(item.path, relativo.split(Platform.pathSeparator));
      if (copia != null) copias.add(copia);
    }
    return copias..sort(_maisNovaPrimeiro);
  }

  @override
  Future<String> ler(CopiaGuardada copia) async => File(copia.caminho).readAsStringSync();

  /// Apaga os automáticos com mais de [dias] e, passando de [maximo], os mais
  /// velhos. Os completos ficam (a pessoa pediu cada um). Falhar aqui não
  /// desfaz o backup: só fica registrado.
  void _aplicarRetencao(DateTime quando, {required String manter}) {
    try {
      final automaticos = _automaticos();
      final limite = quando.subtract(Duration(days: dias));
      final velhos = [
        for (final (i, copia) in automaticos.indexed)
          if (copia.caminho != manter && (i >= maximo || copia.quando.isBefore(limite))) copia,
      ];
      for (final copia in velhos) {
        File(copia.caminho).deleteSync();
      }
      if (velhos.isNotEmpty) registro.i('backup: retenção apagou ${velhos.length} arquivo(s) antigo(s)');
      _apagarDiasVazios();
    } on FileSystemException catch (erro) {
      registro.w('backup: retenção não terminou em ${raiz.path}', error: erro);
    }
  }

  List<CopiaGuardada> _automaticos() {
    if (!raiz.existsSync()) return const [];
    final copias = <CopiaGuardada>[];
    for (final dia in raiz.listSync().whereType<Directory>()) {
      for (final item in dia.listSync().whereType<File>()) {
        final partes = [_nome(dia.path), _nome(item.path)];
        if (CopiaGuardada.doCaminho(item.path, partes) case final copia?) copias.add(copia);
      }
    }
    return copias..sort(_maisNovaPrimeiro);
  }

  void _apagarDiasVazios() {
    for (final dia in raiz.listSync().whereType<Directory>()) {
      if (dia.listSync().isEmpty) dia.deleteSync();
    }
  }

  static int _maisNovaPrimeiro(CopiaGuardada a, CopiaGuardada b) {
    final porData = b.quando.compareTo(a.quando);
    return porData != 0 ? porData : b.caminho.compareTo(a.caminho);
  }
}

class _LoteEmDisco implements LoteDeCopias {
  _LoteEmDisco(this.pasta);

  final Directory pasta;

  @override
  String get caminho => pasta.path;

  @override
  Future<String> guardar(OrigemDaCopia origem, String texto) async => _gravarSemSobrepor(pasta, origem.sufixo, texto).path;
}

String _nome(String caminho) => caminho.substring(caminho.lastIndexOf(Platform.pathSeparator) + 1);

/// Grava num temporário e renomeia: um disco cheio no meio não deixa um JSON
/// pela metade com cara de backup. Mesmo nome no mesmo segundo ganha " (2)".
File _gravarSemSobrepor(Directory pasta, String base, String texto) {
  pasta.createSync(recursive: true);
  var arquivo = File(_juntar([pasta.path, '$base.json']));
  for (var n = 2; arquivo.existsSync(); n++) {
    arquivo = File(_juntar([pasta.path, '$base ($n).json']));
  }
  final temporario = File('${arquivo.path}.tmp');
  temporario.writeAsStringSync(texto, flush: true);
  temporario.renameSync(arquivo.path);
  return arquivo;
}
