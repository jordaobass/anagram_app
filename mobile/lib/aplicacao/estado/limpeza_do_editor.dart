// O slot aberto no editor mudou na pedaleira pelo menu da lista, fora do
// editor. Limpo: o editor passa a mostrar o slot vazio, como se tivesse sido
// aberto agora. Sem documento não há "não salvo": a edição que houvesse era
// de um preset que a pessoa acabou de mandar apagar. Regravado (um clone
// foi para ele): o editor reabre o slot, senão o "original" seria o preset
// substituído e o Salvar gravaria ele de volta por cima do clone.
// Recarregar da pedaleira é o mesmo reabrir, pedido pela pessoa.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/slot_preset.dart';
import 'estado_editor.dart';

mixin LimpezaDoEditor on Notifier<EstadoEditor> {
  Future<void> abrirSlot(SlotPreset slot);

  /// [slot] de [area] ficou vazio; só mexe no editor se for o slot aberto.
  void aoLimparSlot(SlotPreset slot, {required String? area}) {
    if (!_estaAberto(slot, area)) return;
    state = state.copiar(original: null, atual: null, selecionado: null, aviso: null);
  }

  /// [slot] de [area] recebeu outro preset; só mexe no editor se for o aberto.
  Future<void> aoRegravarSlot(SlotPreset slot, {required String? area}) async {
    if (_estaAberto(slot, area)) await abrirSlot(slot);
  }

  /// Relê da pedaleira o slot aberto (mudou por fora, ou a pessoa quer a
  /// versão gravada): as edições não salvas se perdem, e a tela confirma antes.
  Future<void> recarregarDaPedaleira() async {
    final slot = state.slot;
    if (slot != null) await abrirSlot(slot);
  }

  bool _estaAberto(SlotPreset slot, String? area) => state.slot == slot && state.area == area;
}
