// Presets de fábrica da Anagram (a área Factory da pedaleira). A pedaleira não
// os entrega pelo USB (DECISOES U18): vêm de um arquivo gerado do Darkglass
// Suite, fora do git como a arte, e só existem no build que o traz. São só
// leitura: tocar (temporário) e copiar para uma área da pessoa.
import 'dart:convert';

import 'documento_preset.dart';
import 'json_util.dart';
import 'slot_preset.dart';

class PresetsDeFabrica {
  const PresetsDeFabrica.vazio() : _porSlot = const {};

  PresetsDeFabrica._(this._porSlot);

  /// Id da área na lista do app. Não é um id da pedaleira, e nunca vai para
  /// ela: "factory" ela aceita e responde com a área padrão (U18), o que faria
  /// uma gravação "na fábrica" cair por cima de um preset da pessoa.
  static const idArea = 'app-fabrica';

  /// `{"presets": [{"arquivo": "1.json", "nome": …, "preset": envelope}]}`.
  /// Entrada sem slot ou que não seja preset da Anagram fica de fora: um
  /// preset estragado não pode esconder os outros.
  factory PresetsDeFabrica.doTexto(String texto) {
    final lista = mapaOuVazio(jsonDecode(texto))['presets'];
    final porSlot = <SlotPreset, DocumentoPreset>{};
    for (final entrada in lista is List ? lista : const []) {
      if (_ler(entrada) case (final slot, final documento)) porSlot[slot] = documento;
    }
    return PresetsDeFabrica._(porSlot);
  }

  static (SlotPreset, DocumentoPreset)? _ler(Object? entrada) {
    final campos = mapaOuVazio(entrada);
    try {
      final slot = SlotPreset.doArquivo(textoOuNulo(campos['arquivo']) ?? '');
      return (slot, DocumentoPreset.doJson(mapaOuVazio(campos['preset'])));
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  final Map<SlotPreset, DocumentoPreset> _porSlot;

  bool get vazio => _porSlot.isEmpty;

  List<ResumoSlot> get resumos => [
    for (final MapEntry(key: slot, value: documento) in _porSlot.entries)
      ResumoSlot(slot: slot, nome: documento.nome, id: documento.uuid),
  ];

  /// O documento é imutável: editar na tela gera outro, a fábrica não muda.
  DocumentoPreset? documento(SlotPreset slot) => _porSlot[slot];
}
