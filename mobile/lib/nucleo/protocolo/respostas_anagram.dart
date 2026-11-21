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
/// (RN5), e a leitura de slot vazio, que não ecoa arquivo nenhum, quando ainda
/// se espera uma atrasada daquela ação (RN10). Eco ausente, desconhecido ou num
/// formato que não se reconhece é aceito.
bool ehRespostaDe(MensagemAnagram pedido, Map<String, dynamic> quadro, RespostasAtrasadas atrasadas) {
  final motivo = _outraConversa(pedido, quadro, atrasadas);
  if (motivo != null) registro.w('anagram: descartada resposta atrasada $motivo enquanto esperava "${pedido.acao}"');
  return motivo == null;
}

String? _outraConversa(MensagemAnagram pedido, Map<String, dynamic> quadro, RespostasAtrasadas atrasadas) {
  final ecoada = quadro['action'];
  if (ecoada is String && ecoada != pedido.acao && AcoesAnagram.todas.contains(ecoada)) {
    atrasadas.consumir(ecoada);
    return 'de "$ecoada"';
  }
  final pedidoSlot = _numeroDoSlot(pedido.carga['filename']);
  final ecoadoSlot = _numeroDoSlot(_arquivoEcoado(quadro));
  if (pedidoSlot != null && ecoadoSlot != null && pedidoSlot != ecoadoSlot) {
    atrasadas.consumir(pedido.acao);
    return 'do arquivo $ecoadoSlot.json';
  }
  final semDono = pedidoSlot != null && ecoadoSlot == null;
  return semDono && atrasadas.consumir(pedido.acao) ? 'sem arquivo (slot vazio)' : null;
}

/// Chamadas que estouraram o prazo e cuja resposta ainda pode chegar, por
/// ação. Cada resposta atrasada que chega consome uma; passada a validade,
/// a pedaleira não vai mais responder e a anotação some, para nunca
/// descartar a resposta certa de uma leitura de slot vazio.
class RespostasAtrasadas {
  RespostasAtrasadas({this.validade = const Duration(seconds: 30), DateTime Function()? agora})
      : _agora = agora ?? DateTime.now;

  final Duration validade;
  final DateTime Function() _agora;
  final Map<String, List<DateTime>> _pendentes = {};

  void anotar(String acao) => (_pendentes[acao] ??= []).add(_agora());

  /// Consome a anotação mais antiga ainda válida da ação; `false` se não havia.
  bool consumir(String acao) {
    final lista = _pendentes[acao];
    if (lista == null) return false;
    lista.removeWhere((quando) => _agora().difference(quando) > validade);
    if (lista.isEmpty) return false;
    lista.removeAt(0);
    return true;
  }
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
