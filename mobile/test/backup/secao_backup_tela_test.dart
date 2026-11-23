// A seção "Backup dos presets" das Configurações e o que a pessoa vê quando
// o backup falha (DECISOES BK1, BK4–BK6). A pasta é a falsa, em memória: o
// disco de verdade é provado nos testes sem widgets desta pasta.
import 'dart:async';
import 'dart:convert';

import 'package:anagram_app/aplicacao/copias/copia_automatica.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/nucleo/modelo/copia_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';
import '../apoio/pasta_copias_falsa.dart';

Future<void> _abrirConfiguracoes(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('botao-configuracoes')));
  await tester.pumpAndSettle();
  // conectado, a seção da pedaleira vem antes e a lista só monta o que está à vista
  await tester.scrollUntilVisible(find.byKey(const ValueKey('backup-restaurar')), 300,
      scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// Um backup automático do 01A, como o app grava.
CopiaGuardada _copiaDo01a(PastaDeCopiasFalsa pasta) {
  final caminho = '$caminhoNasCapturas\\2026-11-21\\093000_user_01A_Clean de ensaio.json';
  final preset = lerPresetsDemonstracao()[1]!;
  (preset['preset'] as Map<String, dynamic>)['name'] = 'Clean de ensaio';
  pasta.textos[caminho] = jsonEncode(preset);
  return CopiaGuardada(
      caminho: caminho,
      quando: DateTime(2026, 11, 21, 9, 30),
      origem: OrigemDaCopia(slot: SlotPreset.doRotulo('01A'), area: 'user', nome: 'Clean de ensaio'));
}

void main() {
  testWidgets('should_show_the_folder_open_it_and_turn_off_the_automatic_backup_in_settings', (tester) async {
    final abertas = <String>[];
    await montarApp(tester, overrides: [
      pastaDeCopiasProvider.overrideWithValue(PastaDeCopiasFalsa()),
      abridorDePastaProvider.overrideWithValue((caminho) async {
        abertas.add(caminho);
        return true;
      }),
    ]);
    await _abrirConfiguracoes(tester);

    expect(find.text(caminhoNasCapturas), findsOneWidget, reason: 'a pessoa vê onde ficam os backups');
    expect(tester.widget<OutlinedButton>(find.ancestor(
        of: find.text('Fazer backup de todos os presets agora'), matching: find.byType(OutlinedButton))).onPressed,
        isNull, reason: 'sem pedaleira não há o que ler');
    await _tocar(tester, find.byKey(const ValueKey('backup-abrir-pasta')));
    expect(abertas, [caminhoNasCapturas]);

    await _tocar(tester, find.byKey(const ValueKey('backup-automatico')));
    expect(containerDaTela(tester).read(copiaAutomaticaProvider), isFalse);
    expect(containerDaTela(tester).read(guardaDeCopiaProvider), isNull, reason: 'desligado, gravar não passa pelo backup');
  });

  testWidgets('should_say_nothing_was_written_and_where_the_backup_failed_when_saving', (tester) async {
    final container = await abrirDemonstracao(tester, overrides: [
      pastaDeCopiasProvider.overrideWithValue(PastaDeCopiasFalsa(falhar: true)),
    ]);
    await tocarNoSlot(tester, '01A');
    // o envio ao vivo anda no relógio falso: não se espera por ele fora do pump
    unawaited(container.read(editorProvider.notifier).renomear('Timbre novo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('botao-salvar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Não salvou: o backup do preset que está no slot não foi gravado em $caminhoNasCapturas'),
        findsOneWidget);
    expect(container.read(editorProvider).naoSalvo, isTrue);
  });

  testWidgets('should_open_a_backup_from_the_list_in_the_editor_without_a_slot', (tester) async {
    final pasta = PastaDeCopiasFalsa();
    final copia = _copiaDo01a(pasta);
    pasta.copias.add(copia);
    final container = await abrirDemonstracao(tester, overrides: [pastaDeCopiasProvider.overrideWithValue(pasta)]);
    await tocarNoSlot(tester, '01B');
    await _abrirConfiguracoes(tester);

    await _tocar(tester, find.byKey(const ValueKey('backup-restaurar')));
    expect(find.text('01A · Clean de ensaio'), findsOneWidget);
    await _tocar(tester, find.byKey(ValueKey('abrir-backup-${copia.caminho}')));

    expect(find.byKey(const ValueKey('botao-configuracoes')), findsOneWidget, reason: 'voltou ao editor');
    final estado = container.read(editorProvider);
    expect((estado.slot, estado.atual?.nome, estado.naoSalvo), (null, 'Clean de ensaio', true));
  });

  testWidgets('should_back_up_all_presets_from_settings_and_say_how_many_and_where', (tester) async {
    final pasta = PastaDeCopiasFalsa();
    await abrirDemonstracao(tester, overrides: [pastaDeCopiasProvider.overrideWithValue(pasta)]);
    await _abrirConfiguracoes(tester);

    await _tocar(tester, find.byKey(const ValueKey('backup-completo')));

    expect(find.byKey(const ValueKey('backup-completo-progresso')), findsNothing, reason: 'terminou e fechou');
    final quantos = pasta.copias.length;
    expect(quantos, greaterThan(3), reason: 'as três áreas da demonstração');
    expect(find.textContaining('Backup completo: $quantos presets guardados em $caminhoNasCapturas'), findsOneWidget);
  });
}
