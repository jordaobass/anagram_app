// O save_preset da IA (DECISOES IA4) passa pelo mesmo "Salvar" da tela, e
// por isso pelo backup automático (BK1): confirmado pela pessoa, o que
// estava no slot vai para o backup antes da gravação.
import 'package:anagram_app/aplicacao/casos_de_uso/transferir_preset.dart';
import 'package:anagram_app/aplicacao/copias/copia_automatica.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/mcp/avisos_mcp.dart';
import 'package:anagram_app/nucleo/demonstracao/transporte_demonstracao.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/app_de_teste.dart' show PreferenciasCopiasEmMemoria;
import '../apoio/copias_apoio.dart';
import '../mcp/mcp_ponta_a_ponta_test.dart' show appComMcp, ferramenta;

void main() {
  test('should_back_up_the_slot_before_the_save_the_ai_asked_for_and_the_player_confirmed', () async {
    final pasta = pastaDeBackups();
    final (container, endereco, token) = await appComMcp(extras: [
      pastaDeCopiasProvider.overrideWithValue(pasta),
      preferenciasCopiasProvider.overrideWithValue(PreferenciasCopiasEmMemoria()),
    ]);
    final pedaleira = container.read(conexaoProvider.notifier).transporte! as TransporteDemonstracao;
    final anterior = DocumentoPreset.doJson(pedaleira.conteudoDoSlot(3)!);
    await ferramenta(endereco, token, 'set_parameter', {'row': 1, 'column': 1, 'parameter': 'Threshold', 'value': -12});
    container.listen(pedidoSalvarProvider, (_, pedido) => pedido?.responder(true));

    final (erro, resposta) = await ferramenta(endereco, token, 'save_preset');

    expect(erro, isFalse, reason: '$resposta');
    final guardado = TransferirPreset.interpretar(arquivosDeBackup(pasta).single.readAsStringSync()) as PresetImportado;
    expect(guardado.documento.assinaturaSemCena, anterior.assinaturaSemCena);
  });
}
