// Backup automático antes de gravar (DECISOES BK1): a pedaleira de
// demonstração e uma pasta temporária de verdade. Cada escrita que substitui
// um slot ocupado deixa, antes, o conteúdo ANTERIOR num JSON que o importar
// abre; se o backup falhar, nada vai para a pedaleira.
import 'dart:io';

import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/casos_de_uso/transferir_preset.dart';
import 'package:anagram_app/aplicacao/copias/copia_automatica.dart';
import 'package:anagram_app/aplicacao/estado/acoes_da_lista.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/controlador_organizar.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/nucleo/resultado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/copias_apoio.dart';

final _slot01a = SlotPreset.doRotulo('01A');
final _slot01b = SlotPreset.doRotulo('01B');

DocumentoPreset _noSlot(TransporteDemonstracao pedaleira, SlotPreset slot) =>
    DocumentoPreset.doJson(pedaleira.conteudoDoSlot(slot.numero)!);

/// O preset que o arquivo guarda, lido como o "Importar" lê.
DocumentoPreset _importado(File arquivo) =>
    (TransferirPreset.interpretar(arquivo.readAsStringSync()) as PresetImportado).documento;

int _gravacoes(TransporteDemonstracao pedaleira) =>
    pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.salvar).length;

void main() {
  test('should_keep_the_previous_preset_importable_when_saving_over_the_open_slot', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final editor = container.read(editorProvider.notifier);
    final anterior = _noSlot(pedaleira, _slot01a);
    await editor.abrirSlot(_slot01a);
    await editor.renomear('Timbre novo');

    expect(await editor.salvar(), isA<PresetSalvo>());

    final arquivos = arquivosDeBackup(pasta);
    expect(arquivos, hasLength(1));
    final esperado = '2026-11-22${Platform.pathSeparator}143005_user_01A_${TransferirPreset.nomeDeArquivo(anterior.nome)}.json';
    expect(arquivos.single.path, endsWith(esperado));
    final guardado = _importado(arquivos.single);
    expect(guardado.nome, anterior.nome, reason: 'o backup é o que estava no slot, não o que foi gravado');
    expect(guardado.assinaturaSemCena, anterior.assinaturaSemCena);
    expect(_noSlot(pedaleira, _slot01a).nome, 'Timbre novo');
  });

  test('should_back_up_the_destination_when_saving_as_over_another_occupied_slot', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final editor = container.read(editorProvider.notifier);
    final doDestino = _noSlot(pedaleira, _slot01b);
    await editor.abrirSlot(_slot01a);

    expect(await editor.salvarComo(_slot01b), isA<SlotOcupado>(), reason: 'pergunta antes, e não guarda nada ainda');
    expect(arquivosDeBackup(pasta), isEmpty);
    expect(await editor.salvarComo(_slot01b, confirmado: true), isA<PresetSalvo>());

    expect(_importado(arquivosDeBackup(pasta).single).assinaturaSemCena, doDestino.assinaturaSemCena);
  });

  test('should_not_write_to_the_pedal_and_say_where_when_the_backup_fails', () async {
    final pasta = pastaQueRecusa();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final editor = container.read(editorProvider.notifier);
    final anterior = _noSlot(pedaleira, _slot01a);
    await editor.abrirSlot(_slot01a);
    await editor.renomear('Timbre novo');

    final resultado = await editor.salvar();

    expect(resultado, isA<FalhaAoSalvar>());
    final erro = (resultado! as FalhaAoSalvar).erro;
    expect(erro, isA<ErroCopiaDeSeguranca>());
    expect((erro as ErroCopiaDeSeguranca).pasta, pasta.caminho, reason: 'a frase da tela diz onde tentou gravar');
    expect(_gravacoes(pedaleira), 0, reason: 'sem backup, nada vai para a pedaleira');
    expect(_noSlot(pedaleira, _slot01a).nome, anterior.nome);
    expect(container.read(editorProvider).naoSalvo, isTrue, reason: 'a edição continua na tela');
  });

  test('should_back_up_the_slot_before_clearing_it_and_keep_it_when_the_backup_fails', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final anterior = _noSlot(pedaleira, _slot01a);

    expect(await container.read(acoesDaListaProvider).limpar(_slot01a), isA<Sucesso<void>>());
    expect(pedaleira.conteudoDoSlot(1), isNull);
    expect(_importado(arquivosDeBackup(pasta).single).assinaturaSemCena, anterior.assinaturaSemCena);

    final (outro, pedaleiraDoOutro) = await conectarComBackups(pastaQueRecusa());
    final falha = await outro.read(acoesDaListaProvider).limpar(_slot01b);
    expect(falha, isA<Falha<void>>());
    expect(pedaleiraDoOutro.conteudoDoSlot(2), isNotNull, reason: 'sem backup o slot não é apagado');
  });

  test('should_back_up_both_presets_before_swapping_them', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final (a, b) = (_noSlot(pedaleira, _slot01a), _noSlot(pedaleira, _slot01b));
    final organizar = container.read(organizarProvider.notifier)..iniciar(OperacaoPreset.mover, _slot01a);

    expect(await organizar.concluir(_slot01b, confirmado: true), isA<Organizado>());

    final guardados = arquivosDeBackup(pasta).map(_importado).map((d) => d.assinaturaSemCena).toSet();
    expect(guardados, {a.assinaturaSemCena, b.assinaturaSemCena});
  });

  test('should_write_without_backup_when_the_switch_is_off', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta, automatico: false);
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(_slot01a);
    await editor.renomear('Timbre novo');

    expect(container.read(guardaDeCopiaProvider), isNull);
    expect(await editor.salvar(), isA<PresetSalvo>());
    expect(arquivosDeBackup(pasta), isEmpty);
    expect(_noSlot(pedaleira, _slot01a).nome, 'Timbre novo');
  });
}
