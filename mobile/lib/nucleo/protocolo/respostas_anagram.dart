// Como ler o que a pedaleira responde: se o quadro recebido é a resposta do
// pedido em curso e se ela recusou o pedido. O formato das respostas de
// escrita não está documentado; o que foi provado na bancada está citado.
import '../modelo/json_util.dart';

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
