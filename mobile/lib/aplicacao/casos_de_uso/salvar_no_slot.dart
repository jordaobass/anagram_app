// Gravar é ato deliberado: slot ocupado exige confirmação explícita, e a
// gravação só conta depois de relida do aparelho (como faz o cli.py de
// referência).
import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/modelo/conferencia_gravacao.dart';
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

}

/// O slot já não tem o que o app abriu: alguém gravou nele por fora (na
/// própria pedaleira ou pelo Suite). [atual] é o que está lá agora (nulo se
/// o slot ficou vazio). Nada foi gravado: a pessoa decide.
final class SlotAlteradoFora extends ResultadoSalvar {
  const SlotAlteradoFora(this.slot, this.atual);
  final SlotPreset slot;
  final DocumentoPreset? atual;
}

class SalvarNoSlot {
  const SalvarNoSlot(this._repositorio, {this.esperaReleitura = const Duration(milliseconds: 500)});

  final RepositorioPedaleira _repositorio;

  /// Pausa antes de reler de novo um slot que voltou diferente do enviado.
  final Duration esperaReleitura;

  Future<ResultadoSalvar> executar(
    SlotPreset slot,
    DocumentoPreset preset, {
    bool sobrescreverConfirmado = false,
    String? area,
    DocumentoPreset? aberto,
  }) async {
    if (aberto != null) {
      if (await _mudouDesde(slot, area, aberto) case final recusa?) return recusa;
    } else if (!sobrescreverConfirmado) {
      final ocupante = await _repositorio.lerPreset(slot, area: area);
      if (ocupante case Falha(:final erro)) return FalhaAoSalvar(erro);
      if (ocupante case Sucesso(valor: final DocumentoPreset atual)) {
        return SlotOcupado(slot, atual.nome);
      }
    }
    final gravacao = await _repositorio.salvar(slot, preset, area: area);
    if (gravacao case Falha(:final erro)) return FalhaAoSalvar(erro);
    return _conferir(slot, area, preset);
  }

  /// Relê o slot e compara com o que o app abriu dele ([aberto]): a cena
  /// ativa não conta (trocar de cena é tocar, como no "não salvo").
  Future<ResultadoSalvar?> _mudouDesde(SlotPreset slot, String? area, DocumentoPreset aberto) async {
    final leitura = await _repositorio.lerPreset(slot, area: area);
    return switch (leitura) {
      Falha(:final erro) => FalhaAoSalvar(erro),
      Sucesso(valor: final DocumentoPreset atual) when atual.assinaturaSemCena == aberto.assinaturaSemCena => null,
      Sucesso(:final valor) => SlotAlteradoFora(slot, valor),
    };
  }

  /// A confirmação da pedaleira não basta: o slot relido tem de ter o que se
  /// mandou (RN1, ver [gravacaoConfere]). Diferente, relê mais uma vez depois
  /// de [esperaReleitura]; se continuar diferente, não conta como salvo.
  Future<ResultadoSalvar> _conferir(SlotPreset slot, String? area, DocumentoPreset enviado) async {
    final primeira = await _reler(slot, area, enviado);
    if (primeira is! FalhaAoSalvar || primeira.erro is! ErroReleituraDiferente) return primeira;
    await Future<void>.delayed(esperaReleitura);
    return _reler(slot, area, enviado);
  }

  Future<ResultadoSalvar> _reler(SlotPreset slot, String? area, DocumentoPreset enviado) async {
    final releitura = await _repositorio.lerPreset(slot, area: area);
    return switch (releitura) {
      Sucesso(valor: final DocumentoPreset relido) when gravacaoConfere(relido, enviado) => PresetSalvo(slot, relido),
      Sucesso(valor: DocumentoPreset()) => const FalhaAoSalvar(
          ErroReleituraDiferente('A pedaleira confirmou, mas o slot relido é diferente do enviado.'),
        ),
      Sucesso() => const FalhaAoSalvar(
          ErroRespostaInvalida('A pedaleira aceitou, mas o slot voltou vazio na releitura.'),
        ),
      Falha(:final erro) => FalhaAoSalvar(erro),
    };
  }
}
