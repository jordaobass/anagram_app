// O menu do preset na lista (botão direito ou o ⋮) também limpa o slot e
// exporta o JSON do preset GRAVADO. Limpar pergunta antes e não tem volta;
// exportar grava o que a pedaleira guarda, não a edição aberta.
import 'dart:async';
import 'dart:convert';

import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/dados/arquivos_preset.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/presets_fabrica.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/demonstracao_na_tela.dart';
import '../apoio/fixtures.dart';

/// "Salvar como" falso: guarda o nome e o texto em vez de abrir o diálogo do sistema.
class _ArquivosFalsos implements ArquivosPreset {
  String? nomeGravado;
  String? textoGravado;

  @override
  Future<String?> lerEscolhido() async => null;

  @override
  Future<DestinoExportacao> gravar(String nomeSugerido, String texto) async {
    nomeGravado = nomeSugerido;
    textoGravado = texto;
    return DestinoExportacao.arquivo;
  }
}

final _slot01A = SlotPreset.doRotulo('01A');

Future<void> _abrirMenu(WidgetTester tester, String rotulo) async {
  await tester.tap(find.byKey(ValueKey('slot-$rotulo')), buttons: kSecondaryButton);
  await tester.pumpAndSettle();
}

Future<void> _escolher(WidgetTester tester, String chave) async {
  await tester.tap(find.byKey(ValueKey(chave)));
  await tester.pumpAndSettle();
}

TransporteDemonstracao _pedaleira(ProviderContainer container) =>
    container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;

Map<String, dynamic>? _gravadoNoSlot(ProviderContainer container, SlotPreset slot) =>
    _pedaleira(container).conteudoDoSlot(slot.numero, area: container.read(bibliotecaProvider).areaSelecionada ?? 'user');

void main() {
  testWidgets('should_clear_the_slot_on_the_pedal_and_show_it_empty_when_clearing_is_confirmed', (tester) async {
    final container = await abrirDemonstracao(tester);
    expect(_gravadoNoSlot(container, _slot01A), isNotNull, reason: 'o 01A começa com preset');

    await _abrirMenu(tester, '01A');
    await _escolher(tester, 'op-limpar');
    expect(find.byKey(const ValueKey('dialogo-limpar-preset')), findsOneWidget, reason: 'pergunta antes de apagar');
    await _escolher(tester, 'confirmar-limpar-preset');

    expect(_gravadoNoSlot(container, _slot01A), isNull, reason: 'o slot foi apagado na pedaleira');
    expect(container.read(bibliotecaProvider).resumo(_slot01A), isNull, reason: 'a lista mostra o slot vazio');
  });

  testWidgets('should_keep_the_preset_when_clearing_is_cancelled', (tester) async {
    final container = await abrirDemonstracao(tester);

    await _abrirMenu(tester, '01A');
    await _escolher(tester, 'op-limpar');
    await _escolher(tester, 'cancelar-limpar-preset');

    expect(_gravadoNoSlot(container, _slot01A), isNotNull);
    expect(container.read(bibliotecaProvider).resumo(_slot01A), isNotNull);
  });

  testWidgets('should_leave_the_editor_on_the_empty_slot_without_unsaved_mark_when_the_open_preset_is_cleared',
      (tester) async {
    final container = await abrirDemonstracao(tester);
    await tocarNoSlot(tester, '01A');
    expect(container.read(editorProvider).atual, isNotNull);

    await _abrirMenu(tester, '01A');
    await _escolher(tester, 'op-limpar');
    await _escolher(tester, 'confirmar-limpar-preset');

    final editor = container.read(editorProvider);
    expect(editor.slot, _slot01A, reason: 'o editor continua no slot, agora vazio');
    expect(editor.atual, isNull);
    expect(editor.naoSalvo, isFalse, reason: 'sem preset não há o que salvar');
  });

  testWidgets('should_not_offer_to_clear_a_factory_preset_since_the_factory_is_read_only', (tester) async {
    await abrirDemonstracao(tester, fabrica: PresetsDeFabrica.doTexto(textoFabricaDeTeste()));
    await tester.tap(find.byKey(const ValueKey('seletor-area')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('area-${PresetsDeFabrica.idArea}')).last);
    await tester.pumpAndSettle();

    await _abrirMenu(tester, '01A');

    final limpar = tester.widget<PopupMenuItem<Object?>>(find.byKey(const ValueKey('op-limpar')));
    expect(limpar.enabled, isFalse);
    expect(find.byKey(const ValueKey('op-exportar')), findsOneWidget, reason: 'exportar vale também na fábrica');
  });

  testWidgets('should_export_the_saved_preset_and_say_unsaved_edits_were_left_out', (tester) async {
    final arquivos = _ArquivosFalsos();
    final container =
        await abrirDemonstracao(tester, overrides: [arquivosPresetProvider.overrideWithValue(arquivos)]);
    final gravado = _gravadoNoSlot(container, _slot01A)!;
    await tocarNoSlot(tester, '01A');
    final editor = container.read(editorProvider.notifier);
    // o envio ao vivo espera a pedaleira de demonstração: o relógio do teste avança no pump
    unawaited(editor.aplicarDocumento(container.read(editorProvider).atual!.comNome('Editado sem salvar')));
    await tester.pumpAndSettle();
    expect(container.read(editorProvider).naoSalvo, isTrue);

    await _abrirMenu(tester, '01A');
    await _escolher(tester, 'op-exportar');

    expect(jsonDecode(arquivos.textoGravado!), gravado, reason: 'o arquivo leva o preset gravado, como a pedaleira entrega');
    expect(arquivos.nomeGravado, startsWith('01A '), reason: 'o nome diz de que slot veio');
    expect(find.textContaining('edições não salvas ficaram de fora'), findsOneWidget);
  });
}
