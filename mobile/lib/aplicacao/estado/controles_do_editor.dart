// Edição dos footswitches, pots e pedal de expressão do preset aberto. Vai
// pelo mesmo caminho das outras edições ([aplicarDocumento]): toca ao vivo,
// marca "não salvo" e só chega ao slot com Salvar.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/edicao_controles.dart';
import 'estado_editor.dart';

mixin ControlesDoEditor on Notifier<EstadoEditor> {
  Future<void> aplicarDocumento(DocumentoPreset documento);

  /// Pot ou pedal de expressão passa a mover [parametro] do bloco em [posicao].
  Future<void> atribuirParametro(IdControle id, PosicaoBloco posicao, DefinicaoParametro parametro) =>
      _editarSeHouverBloco(posicao, (atual) => atual.comParametroNoControle(id, posicao, parametro));

  /// Footswitch [id] liga e desliga o bloco em [posicao].
  Future<void> atribuirFootswitch(IdControle id, PosicaoBloco posicao, String nomeDoBloco) =>
      _editarSeHouverBloco(posicao, (atual) => atual.comFootswitchNoBloco(id, posicao, nomeDoBloco));

  Future<void> removerAlvoDoControle(IdControle id, int indice) =>
      _editar((atual) => atual.semAlvoNoControle(id, indice));

  Future<void> removerControle(IdControle id) => _editar((atual) => atual.semControle(id));

  /// Nome vazio ou com marcador de quadro é ignorado (o diálogo já explica).
  Future<void> renomearControle(IdControle id, String nome) async {
    if (motivoNomeInvalido(nome) == null) await _editar((atual) => atual.comNomeDoControle(id, nome.trim()));
  }

  /// Faixa recusada não muda nada e volta para a tela dizer por quê.
  Future<RecusaFaixa?> mudarFaixa(IdControle id, int indice, DefinicaoParametro parametro, num minimo, num maximo) async {
    final recusa = motivoFaixaInvalida(parametro, minimo, maximo);
    if (recusa == null) await _editar((atual) => atual.comFaixaNoAlvo(id, indice, minimo, maximo));
    return recusa;
  }

  Future<void> _editarSeHouverBloco(PosicaoBloco posicao, DocumentoPreset Function(DocumentoPreset) mudar) async {
    if (state.atual?.bloco(posicao) != null) await _editar(mudar);
  }

  Future<void> _editar(DocumentoPreset Function(DocumentoPreset atual) mudar) async {
    final atual = state.atual;
    if (atual != null) await aplicarDocumento(mudar(atual));
  }
}
