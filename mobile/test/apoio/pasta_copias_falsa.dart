// Pasta de backups em memória para os testes de tela: caminho fixo (as
// capturas não mudam de uma máquina para outra) e nada de disco no relógio
// falso. O disco de verdade é provado nos testes sem widgets (copias_apoio).
import 'dart:io';

import 'package:anagram_app/nucleo/modelo/copia_preset.dart';
import 'package:anagram_app/plataforma/copias_de_seguranca.dart';

const caminhoNasCapturas = r'C:\Users\voce\AppData\Local\Anagram App\backups';

class PastaDeCopiasFalsa implements PastaDeCopias {
  PastaDeCopiasFalsa({this.caminho = caminhoNasCapturas, this.falhar = false, List<CopiaGuardada>? iniciais})
      : copias = [...?iniciais];

  @override
  final String caminho;

  /// Toda gravação falha, como um disco cheio.
  bool falhar;
  final List<CopiaGuardada> copias;
  final textos = <String, String>{};

  @override
  Future<String> guardar(OrigemDaCopia origem, String texto) async {
    if (falhar) throw const FileSystemException('No space left on device');
    final quando = DateTime(2026, 11, 22, 14, 30, 5);
    final arquivo = '$caminho\\${pastaDoDia(quando)}\\${horaDaCopia(quando)}_${origem.sufixo}.json';
    textos[arquivo] = texto;
    copias.insert(0, CopiaGuardada(caminho: arquivo, quando: quando, origem: origem));
    return arquivo;
  }

  @override
  Future<LoteDeCopias> novoLote() async {
    if (falhar) throw const FileSystemException('No space left on device');
    return _LoteFalso(this);
  }

  @override
  Future<List<CopiaGuardada>> listar() async => List.of(copias);

  @override
  Future<String> ler(CopiaGuardada copia) async => textos[copia.caminho] ?? (throw FileSystemException('sumiu', copia.caminho));
}

class _LoteFalso implements LoteDeCopias {
  _LoteFalso(this._pasta);

  final PastaDeCopiasFalsa _pasta;
  static final _quando = DateTime(2026, 11, 22, 14, 31, 0);

  @override
  String get caminho => '${_pasta.caminho}\\${pastaDoDia(_quando)}\\$prefixoCopiaCompleta${horaDaCopia(_quando)}';

  @override
  Future<String> guardar(OrigemDaCopia origem, String texto) async {
    final arquivo = '$caminho\\${origem.sufixo}.json';
    _pasta.textos[arquivo] = texto;
    _pasta.copias.add(CopiaGuardada(
        caminho: arquivo, quando: _quando, origem: origem, completa: '$prefixoCopiaCompleta${horaDaCopia(_quando)}'));
    return arquivo;
  }
}
