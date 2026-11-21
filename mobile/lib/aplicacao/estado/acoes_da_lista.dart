// Ações do menu de um preset da lista que não pedem um slot de destino:
// limpar o slot e ler o preset GRAVADO para exportar. Organizar (mover,
// clonar, trocar banco) fica no ControladorOrganizar, porque espera o destino.
// Tudo vale para a área que está na tela; a fábrica é só leitura.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/resultado.dart';
import '../provedores.dart';
import 'controlador_biblioteca.dart';
import 'controlador_conexao.dart';
import 'controlador_editor.dart';

final acoesDaListaProvider = Provider<AcoesDaLista>(AcoesDaLista.new);

class AcoesDaLista {
  AcoesDaLista(this._ref);

  final Ref _ref;

  static const _semPedaleira = ErroDesconectado('Conecte a pedaleira para mexer nos presets.');

  /// Apaga o preset de [slot] na pedaleira. A lista mostra o slot vazio e, se
  /// era o preset aberto, o editor também.
  Future<Resultado<void>> limpar(SlotPreset slot) async {
    final repositorio = _ref.read(conexaoProvider.notifier).repositorio;
    final biblioteca = _ref.read(bibliotecaProvider);
    if (repositorio == null) return const Falha(_semPedaleira);
    // a fábrica é do app, não da pedaleira: não há o que apagar (o menu nem oferece)
    if (biblioteca.naFabrica) return const Falha(ErroRespostaInvalida('A área Fábrica é só leitura.'));
    final area = biblioteca.areaSelecionada;
    final resultado = await repositorio.excluir(slot, area: area);
    if (resultado is Sucesso) {
      _ref.read(bibliotecaProvider.notifier).registrarVazio(slot);
      _ref.read(editorProvider.notifier).aoLimparSlot(slot, area: area);
    }
    return resultado;
  }

  /// O preset como está GRAVADO em [slot] (não a edição aberta no editor):
  /// na fábrica, do arquivo do Suite; nas áreas da pessoa, lido da pedaleira.
  Future<Resultado<DocumentoPreset?>> lerGravado(SlotPreset slot) async {
    final biblioteca = _ref.read(bibliotecaProvider);
    if (biblioteca.naFabrica) {
      return Sucesso((await _ref.read(presetsFabricaProvider.future)).documento(slot));
    }
    final repositorio = _ref.read(conexaoProvider.notifier).repositorio;
    if (repositorio == null) return const Falha(_semPedaleira);
    return repositorio.lerPreset(slot, area: biblioteca.areaSelecionada);
  }
}
