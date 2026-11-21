// O slot aberto no editor foi limpo na pedaleira (pelo menu da lista): o
// editor passa a mostrar o slot vazio, como se tivesse sido aberto agora. Sem
// documento não há "não salvo": a edição que houvesse era de um preset que
// a pessoa acabou de mandar apagar.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/slot_preset.dart';
import 'estado_editor.dart';

mixin LimpezaDoEditor on Notifier<EstadoEditor> {
  /// [slot] de [area] ficou vazio; só mexe no editor se for o slot aberto.
  void aoLimparSlot(SlotPreset slot, {required String? area}) {
    if (state.slot != slot || state.area != area) return;
    state = state.copiar(original: null, atual: null, selecionado: null, aviso: null);
  }
}
