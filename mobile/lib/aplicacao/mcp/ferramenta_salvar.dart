// Gravar no slot é a única coisa que a IA não faz sozinha: ela pede, o app
// mostra a pergunta e só a pessoa confirma. O que acontece depois é o mesmo
// "Salvar" do botão (inclusive cair no "Salvar como" quando não há slot).
// Slot mudado na pedaleira depois de aberto é recusado: sobrescrever é
// decisão da pessoa, na tela, nunca da IA.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../casos_de_uso/salvar_no_slot.dart';
import 'avisos_mcp.dart';
import 'sessao_mcp.dart';

class SalvarPreset extends FerramentaMcp {
  const SalvarPreset(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'save_preset';

  @override
  String get descricao => 'Ask the player to save the preset to its slot on the pedal. The app shows a '
      'confirmation dialog; nothing is written unless the player confirms. Returns status '
      '"confirmed", "declined", "timeout" or "needs_destination".';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  /// A pessoa confirma o preset que estava aberto ao perguntar (IA4): se ele
  /// mudou durante a pergunta (outra chamada da IA, outro slot aberto), gravar
  /// agora poria no slot algo que ninguém confirmou, então nada é gravado.
  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final documento = sessao.presetAberto();
    final slot = sessao.estado.slot;
    final pedido = _ref.read(pedidoSalvarProvider.notifier);
    final confirmado = await pedido.pedir(documento.nome, slot?.rotulo, _ref.read(prazoConfirmarSalvarProvider));
    if (confirmado == null) return ResultadoFerramenta.dados({'status': 'timeout'});
    if (!confirmado) return ResultadoFerramenta.dados({'status': 'declined'});
    if (!identical(sessao.estado.atual, documento) || sessao.estado.slot != slot) {
      return ResultadoFerramenta.recusa('The preset changed while the player was confirming; nothing was saved. '
          'Call save_preset again so the player confirms the current version.');
    }
    return _gravado(await sessao.editor.salvar());
  }

  static ResultadoFerramenta _gravado(ResultadoSalvar? resultado) => switch (resultado) {
        PresetSalvo(:final slot) => ResultadoFerramenta.dados({'status': 'confirmed', 'saved_to': slot.rotulo}),
        null => ResultadoFerramenta.dados({
            'status': 'needs_destination',
            'message': 'This preset has no slot of its own here; the player must pick one in the app.',
          }),
        SlotOcupado(:final slot) => ResultadoFerramenta.recusa('Slot ${slot.rotulo} is taken; the player must confirm in the app.'),
        SlotAlteradoFora(:final slot) => ResultadoFerramenta.recusa('Slot ${slot.rotulo} was changed on the pedal '
            'since it was opened in the app; nothing was saved. Ask the player to reload it from the pedal, or to '
            'save from the app, where they can choose to overwrite it.'),
        FalhaAoSalvar(:final erro) => ResultadoFerramenta.recusa('Saving failed: ${erro.mensagem}'),
      };
}
