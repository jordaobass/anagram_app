// Gravar é ato deliberado: slot ocupado exige confirmação explícita, e a
// gravação só conta depois de relida do aparelho (como faz o cli.py de
// referência).
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/protocolo/erros_anagram.dart';
import '../../nucleo/resultado.dart';

sealed class ResultadoSalvar {
  const ResultadoSalvar();
}

final class PresetSalvo extends ResultadoSalvar {
  const PresetSalvo(this.slot, this.relido);
  final SlotPreset slot;
  final DocumentoPreset relido;
}

final class SlotOcupado extends ResultadoSalvar {
  const SlotOcupado(this.slot, this.nomeAtual);
  final SlotPreset slot;
  final String nomeAtual;
}

final class FalhaAoSalvar extends ResultadoSalvar {
  const FalhaAoSalvar(this.erro);
  final ErroAnagram erro;

  /// Frase para a tela, escolhida pelo tipo do erro: a mensagem dos erros do
  /// protocolo traz o nome da ação e a exceção de origem, que só servem ao log.
  /// Os recusados pelo próprio app já vêm com a frase certa.
  String get motivo => switch (erro) {
        ErroDesconectado() => 'a pedaleira está desconectada. Conecte e tente de novo.',
        ErroSemResposta() => 'a pedaleira não respondeu a tempo. O slot pode não ter sido gravado; confira antes de tentar de novo.',
        ErroRespostaInvalida() => 'a pedaleira recusou ou devolveu uma resposta inesperada.',
        ErroInterfaceOcupada() => 'outro programa está segurando a pedaleira.',
        ErroOperacaoEmCurso(:final mensagem) || ErroPlataformaSemSuporte(:final mensagem) => mensagem,
      };
}

class SalvarNoSlot {
  const SalvarNoSlot(this._repositorio);

  final RepositorioPedaleira _repositorio;

  Future<ResultadoSalvar> executar(
    SlotPreset slot,
    DocumentoPreset preset, {
    bool sobrescreverConfirmado = false,
  }) async {
    if (!sobrescreverConfirmado) {
      final ocupante = await _repositorio.lerPreset(slot);
      if (ocupante case Falha(:final erro)) return FalhaAoSalvar(erro);
      if (ocupante case Sucesso(valor: final DocumentoPreset atual)) {
        return SlotOcupado(slot, atual.nome);
      }
    }
    final gravacao = await _repositorio.salvar(slot, preset);
    if (gravacao case Falha(:final erro)) return FalhaAoSalvar(erro);
    return _conferir(slot);
  }

  Future<ResultadoSalvar> _conferir(SlotPreset slot) async {
    final releitura = await _repositorio.lerPreset(slot);
    return switch (releitura) {
      Sucesso(valor: final DocumentoPreset relido) => PresetSalvo(slot, relido),
      Sucesso() => const FalhaAoSalvar(
          ErroRespostaInvalida('A pedaleira aceitou, mas o slot voltou vazio na releitura.'),
        ),
      Falha(:final erro) => FalhaAoSalvar(erro),
    };
  }
}
