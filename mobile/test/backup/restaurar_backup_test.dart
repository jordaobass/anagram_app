// Restaurar um backup (DECISOES BK6): o preset guardado abre no editor sem
// slot, como o importado; o "Salvar" cai no "Salvar como" e nada volta para a
// pedaleira sem a pessoa escolher o destino.
import 'package:anagram_app/aplicacao/casos_de_uso/transferir_preset.dart';
import 'package:anagram_app/aplicacao/copias/restaurar_copia.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/copias_apoio.dart';

final _slot01a = SlotPreset.doRotulo('01A');

void main() {
  test('should_open_the_backup_in_the_editor_without_a_slot_and_save_only_through_save_as', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final editor = container.read(editorProvider.notifier);
    final anterior = DocumentoPreset.doJson(pedaleira.conteudoDoSlot(1)!);
    await editor.abrirSlot(_slot01a);
    await editor.renomear('Timbre novo');
    await editor.salvar();
    final copia = (await container.read(copiasGuardadasProvider.future)).single;

    final resultado = await container.read(restaurarCopiaProvider).abrir(copia);

    expect(resultado, isA<PresetImportado>());
    final estado = container.read(editorProvider);
    expect(estado.slot, isNull, reason: 'abre sem slot: o Salvar não pode devolvê-lo ao 01A por conta própria');
    expect(estado.atual!.assinaturaSemCena, anterior.assinaturaSemCena);
    expect(estado.naoSalvo, isTrue);
    final gravacoes = pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.salvar).length;
    expect(await editor.salvar(), isNull, reason: 'sem slot, vira Salvar como');
    expect(container.read(editorProvider).escolhendoDestino, isTrue);
    expect(pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.salvar).length, gravacoes);
    expect(pedaleira.conteudoDoSlot(1)!['preset']['name'], 'Timbre novo');
  });
}
