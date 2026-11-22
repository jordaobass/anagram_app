// Ações do protocolo com tipos do app. Formatos de pedido conferidos no
// anagram-tone-maker (MIT) e, para as áreas de presets (firmware 1.18+), no
// Darkglass Suite 6.11.4; formatos de resposta de escrita não estão
// documentados, então qualquer resposta sem "error" conta como aceite.
//
// [area]: id da área de presets ("user", "user-2"…). Nulo = firmware sem
// áreas, e o pedido sai sem `userArea`, igual ao de antes.
import 'dart:convert';

import '../ajustes/ajustes_pedaleira.dart';
import '../modelo/areas_presets.dart';
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
  static const lerAjustes = 'export_settings';
  static const gravarAjustes = 'edit_settings';
  static const trocarPresets = 'swap_anagram_presets';
  static const trocarBancos = 'swap_anagram_banks';
  /// O app não pede mais; fica porque a pedaleira de demonstração responde a ela.
  static const infoBloco = 'get_plugin_info';
  /// Só leitura dos tons do TONE3000 (DECISOES T3K1); nada de enviar nem apagar.
  static const tonsDeFabrica = 'get_t3k_factory_tones';
  static const tonsDoUsuario = 'get_t3k_tones_metadata';

  static const todas = {
    firmware, posicoes, lerPreset, salvar, excluir, tocarAoVivo, lerAjustes, gravarAjustes, trocarPresets,
    trocarBancos, infoBloco, tonsDeFabrica, tonsDoUsuario,
  };
}

class ApiAnagram {
  ApiAnagram(this.cliente);

  final ClienteAnagram cliente;

  static const prazoAjustes = Duration(seconds: 3);

  Future<String> firmware({Duration? prazo}) async {
    final dados = (await cliente.chamar(AcoesAnagram.firmware, const {}, prazo))['data'];
    if (dados is String) return dados;
    if (dados is Map<String, dynamic>) {
      return '${dados['version'] ?? dados['firmware'] ?? jsonEncode(dados)}';
    }
    return 'desconhecido';
  }

  /// Áreas e a ativa, pelos ajustes da pedaleira. Firmware que não conhece
  /// `export_settings` responde com erro ou não responde: aí vale área única,
  /// com prazo curto para não atrasar a conexão.
  Future<AreasDaPedaleira> lerAreas() async {
    final Map<String, dynamic> resposta;
    try {
      resposta = await cliente.chamar(AcoesAnagram.lerAjustes, const {}, prazoAjustes);
    } on ErroRespostaInvalida {
      return const AreasDaPedaleira.unica();
    } on ErroSemResposta {
      return const AreasDaPedaleira.unica();
    }
    final ajustes = resposta['settings'] ?? mapaOuVazio(resposta['data'])['settings'];
    return ajustes is Map<String, dynamic> ? AreasDaPedaleira.dosAjustes(ajustes) : const AreasDaPedaleira.unica();
  }

  /// Passa a pedaleira para [area] (a dos footswitches e do Program Change).
  /// HIPÓTESE (DECISOES, U11): a chave é a mesma que `export_settings` devolve.
  Future<void> tornarAreaAtiva(String area) => cliente.chamar(
        AcoesAnagram.gravarAjustes,
        {'settings': {'selected-preset-area': area}, 'reloadLvgl': true},
      );

  /// Mixer, Global EQ, ganho de entrada e a placa de som: os ajustes globais.
  Future<AjustesPedaleira> lerAjustesGlobais() async =>
      AjustesPedaleira.daResposta(await cliente.chamar(AcoesAnagram.lerAjustes, const {}, prazoAjustes));

  /// [porChave]: chaves planas do protocolo; várias de uma vez valem. O app só
  /// grava `mode` (DECISOES FM1): mixer, Global EQ e ganho de entrada são
  /// aceitos e relidos, mas a pedaleira não os aplica ao som (DECISOES AJ1).
  Future<void> gravarAjustesGlobais(Map<String, Object> porChave) => cliente.chamar(
        AcoesAnagram.gravarAjustes,
        {'settings': porChave, 'reloadLvgl': true},
        prazoAjustes,
      );

  Future<List<ResumoSlot>> listarSlots({String? area}) async {
    final resposta = await cliente.chamar(AcoesAnagram.posicoes, _comArea(const {}, area));
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

  Future<DocumentoPreset?> lerPreset(SlotPreset slot, {String? area}) async {
    final resposta = await cliente.chamar(AcoesAnagram.lerPreset, _comArea({'filename': slot.arquivo}, area));
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

  Future<void> salvar(SlotPreset slot, DocumentoPreset preset, {String? area}) => cliente.chamar(
        AcoesAnagram.salvar,
        _comArea({
          'presets': [
            {'name': slot.arquivo, 'content': preset.paraJson()},
          ],
        }, area),
        const Duration(seconds: 30),
      );

  Future<void> excluir(SlotPreset slot, {String? area}) => cliente.chamar(
        AcoesAnagram.excluir,
        _comArea({'filename': slot.arquivo}, area),
        const Duration(seconds: 25),
      );

  /// Troca dois presets de lugar; com o destino vazio, é mover. Os índices são
  /// o número do slot (1–126), como o Darkglass Suite manda (`fromIndex + 1`).
  Future<void> trocarPresets(SlotPreset de, SlotPreset para, {String? area}) => cliente.chamar(
        AcoesAnagram.trocarPresets,
        _comArea({'fromIndex': de.numero, 'toIndex': para.numero}, area),
        const Duration(seconds: 25),
      );

  /// Troca dois bancos inteiros (1–42): um par por letra, como no Suite.
  Future<void> trocarBancos(int de, int para, {String? area}) => cliente.chamar(
        AcoesAnagram.trocarBancos,
        _comArea({
          'positions': [
            for (var letra = 1; letra <= SlotPreset.porBanco; letra++)
              {
                'fromIndex': (de - 1) * SlotPreset.porBanco + letra,
                'toIndex': (para - 1) * SlotPreset.porBanco + letra,
              },
          ],
        }, area),
        const Duration(seconds: 25),
      );

  static Map<String, dynamic> _comArea(Map<String, dynamic> carga, String? area) =>
      area == null ? carga : {...carga, 'userArea': area};

  static bool _slotValido(Object? arquivo) {
    final numero = SlotPreset.numeroDoArquivo('$arquivo');
    return numero != null && numero >= 1 && numero <= SlotPreset.total;
  }
}
