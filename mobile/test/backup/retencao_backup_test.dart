// Retenção dos backups automáticos (DECISOES BK3): ficam 30 dias ou 500
// arquivos, o que vier primeiro, e os velhos só saem DEPOIS de o novo estar
// no disco. Os backups completos não entram na conta.
import 'dart:io';

import 'package:anagram_app/nucleo/modelo/copia_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/copias_apoio.dart';

final _sep = Platform.pathSeparator;

OrigemDaCopia _origem(int slot) => OrigemDaCopia(slot: SlotPreset(slot), area: 'user', nome: 'Preset $slot');

/// Um backup automático "antigo", com a data no nome como o app grava.
File _antigo(Directory raiz, DateTime quando, int slot) =>
    File('${raiz.path}$_sep${pastaDoDia(quando)}$_sep${horaDaCopia(quando)}_${_origem(slot).sufixo}.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{}');

void main() {
  test('should_delete_backups_past_30_days_or_500_files_only_after_writing_the_new_one', () async {
    final pasta = pastaDeBackups(maximo: 3);
    final agora = agoraFixo();
    final velho = _antigo(pasta.raiz, agora.subtract(const Duration(days: 31)), 1);
    final recentes = [for (var i = 1; i <= 3; i++) _antigo(pasta.raiz, agora.subtract(Duration(hours: i)), 10 + i)];
    final diaVelho = pastaDoDia(agora.subtract(const Duration(days: 40)));
    final completo = File('${pasta.raiz.path}$_sep$diaVelho${_sep}completo_090000${_sep}user_01A_Antigo.json')
      ..createSync(recursive: true);

    final novo = await pasta.guardar(_origem(5), '{"novo": true}');

    expect(File(novo).existsSync(), isTrue);
    expect(velho.existsSync(), isFalse, reason: 'mais de 30 dias');
    expect([for (final f in recentes) f.existsSync()], [true, true, false],
        reason: 'com o novo, passam de 3: sai o mais velho dos recentes');
    expect(completo.existsSync(), isTrue, reason: 'backup completo foi pedido pela pessoa e não entra na retenção');
  });

  test('should_keep_every_old_backup_when_the_new_one_cannot_be_written', () async {
    final pasta = pastaDeBackups(maximo: 1);
    final agora = agoraFixo();
    final velho = _antigo(pasta.raiz, agora.subtract(const Duration(days: 40)), 1);
    // a pasta do dia ocupada por um arquivo: o novo não tem onde entrar
    File('${pasta.raiz.path}$_sep${pastaDoDia(agora)}').writeAsStringSync('ocupado');

    await expectLater(pasta.guardar(_origem(5), '{}'), throwsA(isA<FileSystemException>()));

    expect(velho.existsSync(), isTrue, reason: 'se o novo falhou, os velhos são tudo o que resta');
  });

  test('should_list_backups_newest_first_and_ignore_files_out_of_the_format', () async {
    final pasta = pastaDeBackups();
    final agora = agoraFixo();
    _antigo(pasta.raiz, agora.subtract(const Duration(days: 2)), 7);
    File('${pasta.raiz.path}${_sep}anotacao.txt').writeAsStringSync('da pessoa');
    await pasta.guardar(OrigemDaCopia(slot: SlotPreset.doRotulo('02B'), area: null, nome: 'Sem / Área'), '{}');

    final lista = await pasta.listar();

    expect([for (final c in lista) (c.origem.slot.rotulo, c.origem.area, c.origem.nome)],
        [('02B', null, 'Sem  Área'), ('03A', 'user', 'Preset 7')]);
    expect(lista.first.quando, agora);
  });
}
