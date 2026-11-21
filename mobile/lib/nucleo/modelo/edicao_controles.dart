// Atribuir e ajustar os controles da pedaleira com o catálogo à mão: a faixa
// padrão é a do parâmetro e o valor do controle é o que o parâmetro tem na
// cena ativa (no `:bypass`, 1 = bloco ligado), como nos presets gravados.
import 'dart:math' as math;

import '../catalogo/definicao_bloco.dart';
import 'bloco_preset.dart';
import 'controles_pedaleira.dart';
import 'documento_preset.dart';

/// O liga/desliga do bloco visto como parâmetro de um controle.
const parametroBypass =
    DefinicaoParametro(simbolo: simboloBypass, nome: 'Bypass', minimo: 0, maximo: 1, padrao: 1, alternavel: true);

/// Por que uma faixa de controle não serve.
enum RecusaFaixa { iguais, foraDaFaixa }

/// Mínimo igual ao máximo deixaria o controle sem curso; fora da faixa do
/// parâmetro, a pedaleira receberia um valor que o bloco não aceita.
/// Mínimo maior que o máximo vale: é o controle invertido.
RecusaFaixa? motivoFaixaInvalida(DefinicaoParametro parametro, num minimo, num maximo) {
  if (minimo == maximo) return RecusaFaixa.iguais;
  final piso = math.min(parametro.minimo, parametro.maximo);
  final teto = math.max(parametro.minimo, parametro.maximo);
  bool dentro(num valor) => valor >= piso && valor <= teto;
  return dentro(minimo) && dentro(maximo) ? null : RecusaFaixa.foraDaFaixa;
}

extension EdicaoDosControles on DocumentoPreset {
  /// Pot ou pedal passa a mover [parametro] do bloco em [posicao], na faixa inteira.
  DocumentoPreset comParametroNoControle(IdControle id, PosicaoBloco posicao, DefinicaoParametro parametro) {
    final valor = _blocoEm(posicao).valorNaCena(parametro.simbolo, cenaAtiva) ?? parametro.padrao;
    return comControles((preset) => atribuirAlvo(
        preset,
        id,
        NovoAlvo(
          posicao: posicao,
          simbolo: parametro.simbolo,
          minimo: parametro.minimo,
          maximo: parametro.maximo,
          valorAtual: valor,
          nomePadrao: parametro.nome,
        )));
  }

  /// Footswitch liga e desliga o bloco; o controle novo leva o nome dele.
  DocumentoPreset comFootswitchNoBloco(IdControle id, PosicaoBloco posicao, String nomeDoBloco) {
    final ligado = _blocoEm(posicao).habilitadoNaCena(cenaAtiva);
    return comControles((preset) => atribuirAlvo(
        preset,
        id,
        NovoAlvo(
          posicao: posicao,
          simbolo: simboloBypass,
          minimo: parametroBypass.minimo,
          maximo: parametroBypass.maximo,
          valorAtual: ligado ? 1 : 0,
          nomePadrao: nomeDoBloco,
        )));
  }

  DocumentoPreset semAlvoNoControle(IdControle id, int indice) =>
      comControles((preset) => removerAlvo(preset, id, indice));

  DocumentoPreset semControle(IdControle id) => comControles((preset) => removerControle(preset, id));

  DocumentoPreset comNomeDoControle(IdControle id, String nome) =>
      comControles((preset) => renomearControle(preset, id, nome));

  DocumentoPreset comFaixaNoAlvo(IdControle id, int indice, num minimo, num maximo) =>
      comControles((preset) => mudarFaixaDoAlvo(preset, id, indice, minimo, maximo));

  BlocoPreset _blocoEm(PosicaoBloco posicao) =>
      bloco(posicao) ?? (throw StateError('Não há bloco em $posicao.'));
}
