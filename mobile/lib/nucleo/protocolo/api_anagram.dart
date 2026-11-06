// Ações do protocolo com tipos do app. Formatos de pedido conferidos no
// anagram-tone-maker (MIT); formatos de resposta de escrita não estão
// documentados, então qualquer resposta sem "error" conta como aceite.
import 'dart:convert';

import '../modelo/documento_preset.dart';
import '../modelo/json_util.dart';
import '../modelo/slot_preset.dart';
import 'cliente_anagram.dart';
import 'erros_anagram.dart';

abstract final class AcoesAnagram {
  static const firmware = 'fetch_firmware_version';
  static const posicoes = 'get_anagram_preset_positions';
  static const lerPreset = 'fetch_anagram_preset';
  static const salvar = 'edit_anagram_presets';
  static const excluir = 'delete_anagram_preset';
  static const tocarAoVivo = 'try_anagram_preset';
  /// O app não pede mais; fica porque a pedaleira de demonstração responde a ela.
  static const infoBloco = 'get_plugin_info';

  static const todas = {firmware, posicoes, lerPreset, salvar, excluir, tocarAoVivo, infoBloco};
}

class ApiAnagram {
  ApiAnagram(this.cliente);

  final ClienteAnagram cliente;

  Future<String> firmware({Duration? prazo}) async {
    final dados = (await cliente.chamar(AcoesAnagram.firmware, const {}, prazo))['data'];
    if (dados is String) return dados;
    if (dados is Map<String, dynamic>) {
      return '${dados['version'] ?? dados['firmware'] ?? jsonEncode(dados)}';
    }
    return 'desconhecido';
  }

  Future<List<ResumoSlot>> listarSlots() async {
    final resposta = await cliente.chamar(AcoesAnagram.posicoes);
    final dados = resposta['data'];
    final arquivos = dados is Map<String, dynamic> ? dados['files'] : null;
    if (arquivos is! List) throw const ErroRespostaInvalida('Lista de presets sem "files".');
    // a resposta é entrada externa: campo com tipo inesperado vale como ausente
    return [
      for (final item in arquivos.whereType<Map<String, dynamic>>())
        if (_slotValido(item['filename']))
          ResumoSlot(
            slot: SlotPreset.doArquivo('${item['filename']}'),
            nome: textoOuNulo(item['name']) ?? '',
            id: textoOuNulo(item['id']),
          ),
    ];
  }

  Future<DocumentoPreset?> lerPreset(SlotPreset slot) async {
    final resposta = await cliente.chamar(AcoesAnagram.lerPreset, {'filename': slot.arquivo});
    final dados = resposta['data'];
    // resposta sem "data" não é "slot vazio": é resposta que não entendemos
    if (dados is! Map<String, dynamic>) {
      throw ErroRespostaInvalida('Leitura de ${slot.rotulo} sem "data".');
    }
    final arquivo = dados['presetFile'];
    final conteudo = arquivo is Map<String, dynamic> ? arquivo['content'] : null;
    if (conteudo is! Map<String, dynamic>) return null;
    return DocumentoPreset.doJson(conteudo);
  }

  /// Toca o preset na pedaleira sem gravar (vale até trocar de preset nela).
  Future<void> tocarAoVivo(DocumentoPreset preset) => cliente.chamar(
        AcoesAnagram.tocarAoVivo,
        {'presetData': preset.paraJson(), 'type': 0},
        const Duration(seconds: 25),
      );

  Future<void> salvar(SlotPreset slot, DocumentoPreset preset) => cliente.chamar(
        AcoesAnagram.salvar,
        {
          'presets': [
            {'name': slot.arquivo, 'content': preset.paraJson()},
          ],
        },
        const Duration(seconds: 30),
      );

  Future<void> excluir(SlotPreset slot) => cliente.chamar(
        AcoesAnagram.excluir,
        {'filename': slot.arquivo},
        const Duration(seconds: 25),
      );

  static bool _slotValido(Object? arquivo) {
    final numero = int.tryParse('$arquivo'.split('.').first);
    return numero != null && numero >= 1 && numero <= SlotPreset.total;
  }
}
