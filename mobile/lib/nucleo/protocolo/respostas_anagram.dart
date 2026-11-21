// Como ler o que a pedaleira responde: se o quadro recebido é a resposta do
// pedido em curso e se ela recusou o pedido. O formato das respostas de
// escrita não está documentado; o que foi provado na bancada está citado.
import '../modelo/json_util.dart';
import '../modelo/slot_preset.dart';
import '../registro.dart';
import 'api_anagram.dart' show AcoesAnagram;
import 'quadros_hid.dart';

/// O protocolo não tem id de pedido: a resposta atrasada de uma chamada que
/// estourou o prazo chega no meio da conversa seguinte. Ela é descartada
/// quando ecoa OUTRA ação conhecida (DECISOES L7) ou outro arquivo de slot
/// (RN5). Eco ausente, desconhecido ou num formato que não se reconhece é
/// aceito: o formato exato do eco do firmware não está documentado.
bool ehRespostaDe(MensagemAnagram pedido, Map<String, dynamic> quadro) {
  final motivo = _outraConversa(pedido, quadro);
  if (motivo != null) registro.w('anagram: descartada resposta atrasada $motivo enquanto esperava "${pedido.acao}"');
  return motivo == null;
}

String? _outraConversa(MensagemAnagram pedido, Map<String, dynamic> quadro) {
  final ecoada = quadro['action'];
  if (ecoada is String && ecoada != pedido.acao && AcoesAnagram.todas.contains(ecoada)) return 'de "$ecoada"';
  final pedidoSlot = _numeroDoSlot(pedido.carga['filename']);
  final ecoadoSlot = _numeroDoSlot(_arquivoEcoado(quadro));
  if (pedidoSlot != null && ecoadoSlot != null && pedidoSlot != ecoadoSlot) return 'do arquivo $ecoadoSlot.json';
  return null;
}

/// HIPÓTESE (RN5): a leitura do slot ecoa o arquivo em `data.presetFile.name`.
Object? _arquivoEcoado(Map<String, dynamic> quadro) =>
    mapaOuVazio(mapaOuVazio(mapaOuVazio(quadro['payload'])['data'])['presetFile'])['name'];

int? _numeroDoSlot(Object? arquivo) => arquivo is String ? SlotPreset.numeroDoArquivo(arquivo) : null;

/// Por que a pedaleira recusou o pedido, ou `null` se não recusou. Valem
/// `error`, `status: "error"` com `message`, e o formato provado na bancada:
/// `success: 0` (ou `false`) com `err_message` (DECISOES PD1, RN6).
Object? motivoDaRecusa(Map<String, dynamic> carga) {
  final erro = carga['error'] ?? (carga['status'] == 'error' ? carga['message'] : null);
  if (erro != null) return erro;
  final sucesso = carga['success'];
  if (sucesso != 0 && sucesso != false) return null;
  final mensagem = textoOuNulo(carga['err_message'])?.trim() ?? '';
  return mensagem.isEmpty ? 'sem motivo informado' : mensagem;
}
