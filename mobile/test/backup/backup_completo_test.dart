// Backup completo (DECISOES BK4): todas as áreas, todos os slots ocupados,
// um pedido por vez, numa pasta datada; cancelar para entre um preset e outro.
import 'package:anagram_app/aplicacao/casos_de_uso/transferir_preset.dart';
import 'package:anagram_app/aplicacao/copias/copia_completa.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/protocolo/api_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/copias_apoio.dart';

void main() {
  test('should_save_every_used_slot_of_every_area_with_its_content', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final esperado = [
      for (final area in ['user', 'user-2', 'user-3'])
        for (var n = 1; n <= 126; n++)
          if (pedaleira.conteudoDoSlot(n, area: area) case final conteudo?)
            '$area $n ${DocumentoPreset.doJson(conteudo).assinaturaSemCena}',
    ]..sort();

    final resultado = await container.read(copiaCompletaProvider.notifier).executar();

    expect(resultado, isA<CopiaCompletaConcluida>());
    expect(resultado.feitos, esperado.length);
    final copias = await pasta.listar();
    expect(copias.every((c) => c.completa == 'completo_143005'), isTrue, reason: 'tudo na pasta datada do lote');
    final guardado = [
      for (final c in copias)
        '${c.origem.area} ${c.origem.slot.numero} '
            '${(TransferirPreset.interpretar(await pasta.ler(c)) as PresetImportado).documento.assinaturaSemCena}',
    ]..sort();
    expect(guardado, esperado, reason: 'as três áreas, cada preset com o conteúdo da pedaleira');
    expect(container.read(copiaCompletaProvider), isNull, reason: 'terminou: a tela volta ao normal');
  });

  test('should_stop_between_presets_and_keep_what_was_saved_when_cancelled', () async {
    final pasta = pastaDeBackups();
    final (container, pedaleira) = await conectarComBackups(pasta);
    final controlador = container.read(copiaCompletaProvider.notifier);
    int leituras() => pedaleira.comandosRecebidos.where((m) => m.acao == AcoesAnagram.lerPreset).length;
    final antes = leituras();
    container.listen(copiaCompletaProvider, (_, progresso) {
      if ((progresso?.feitos ?? 0) == 2) controlador.cancelar();
    });

    final resultado = await controlador.executar();

    expect(resultado, isA<CopiaCompletaCancelada>());
    expect(resultado.feitos, 2);
    expect(arquivosDeBackup(pasta), hasLength(2), reason: 'o que já foi gravado fica');
    expect(leituras() - antes, 2, reason: 'depois de cancelar, nenhum pedido a mais vai para a pedaleira');
  });
}
