// O undo da IA volta só o que a IA fez: se a pessoa abriu outro preset ou
// mexeu num knob entre duas mudanças da IA, o histórico anterior não pode
// mais ser aplicado (IA4) — nem dentro de outro slot, nem por cima da
// edição da pessoa.
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/mcp/ferramentas_ajuste.dart';
import 'package:anagram_app/aplicacao/mcp/sessao_mcp.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/nucleo/mcp/ferramenta_mcp.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

final _sessaoProvider = Provider<SessaoMcp>(SessaoMcp.new);

Future<ProviderContainer> _appConectado() async {
  final container = ProviderContainer(overrides: [
    presetsDemonstracaoProvider.overrideWith((ref) async => lerPresetsDemonstracao()),
    catalogoProvider.overrideWith((ref) async => lerCatalogo()),
    indiceMiniaturasProvider.overrideWith((ref) async => lerIndiceMiniaturas()),
  ]);
  addTearDown(container.dispose);
  await container.read(catalogoProvider.future);
  await container.read(conexaoProvider.notifier).conectarDemonstracao();
  return container;
}

DocumentoPreset _aberto(ProviderContainer container) => container.read(editorProvider).atual!;

PosicaoBloco _primeiroBloco(ProviderContainer container) => container.read(editorProvider).selecionado!;

/// A IA liga ou desliga o primeiro bloco do preset aberto.
Future<void> _iaAlternaPrimeiroBloco(ProviderContainer container) async {
  final posicao = _primeiroBloco(container);
  final ligado = _aberto(container).bloco(posicao)!.habilitadoNaCena(_aberto(container).cenaAtiva);
  final resultado = await LigarDesligarBloco(container.read(_sessaoProvider))
      .executar({'row': posicao.linha, 'column': posicao.casa, 'enabled': !ligado});
  expect(resultado.erro, isFalse, reason: resultado.texto);
}

Future<void> _iaDesfaz(ProviderContainer container) => Desfazer(container.read(_sessaoProvider)).executar(const {});

void main() {
  test('should_refuse_to_undo_into_another_slot_when_the_player_opened_a_different_preset_between_ai_changes',
      () async {
    final container = await _appConectado();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    await _iaAlternaPrimeiroBloco(container);
    await editor.abrirSlot(SlotPreset.doRotulo('02A'));
    final originalB = _aberto(container);
    await _iaAlternaPrimeiroBloco(container);

    await _iaDesfaz(container);
    await expectLater(_iaDesfaz(container), throwsA(isA<RecusaFerramenta>()));

    final estado = container.read(editorProvider);
    expect(estado.slot, SlotPreset.doRotulo('02A'));
    expect(estado.atual!.nome, originalB.nome, reason: 'o preset do 01C não pode aparecer dentro do 02A');
    expect(estado.naoSalvo, isFalse, reason: 'o primeiro undo já devolveu o 02A ao que estava gravado');
  });

  test('should_keep_the_player_knob_when_the_ai_undoes_twice_after_the_player_edited_between_ai_changes', () async {
    final container = await _appConectado();
    final editor = container.read(editorProvider.notifier);
    await editor.abrirSlot(SlotPreset.doRotulo('01C'));
    const limiar = PosicaoBloco(1, 1);
    await _iaAlternaPrimeiroBloco(container);
    editor.alterarParametro('Threshold', -7, arrastando: false, posicao: limiar);
    await _iaAlternaPrimeiroBloco(container);

    await _iaDesfaz(container);
    await expectLater(_iaDesfaz(container), throwsA(isA<RecusaFerramenta>()));

    expect(_aberto(container).bloco(limiar)!.valorBase('Threshold'), -7, reason: 'o knob da pessoa fica');
  });
}
