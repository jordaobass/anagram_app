// Confere se o preset relido de um slot é o que se mandou gravar. Serve ao
// salvar sem confirmação (a pedaleira grava e não responde em 30 s): comparar
// só nome e cadeia daria "salvo" com o knob mexido perdido.
import 'bloco_preset.dart';
import 'documento_preset.dart';

/// A pedaleira guarda os valores em precisão simples: 7.6 volta 7.5999999.
const _toleranciaRelativa = 1e-5;

/// Verdadeiro quando [gravado] tem o nome, a cadeia, o arquivo de IR e, em
/// cada cena, o liga/desliga e os valores de tudo o que [enviado] guarda. O
/// que só [gravado] tem (parâmetro que a pedaleira completou) não conta.
bool gravacaoConfere(DocumentoPreset gravado, DocumentoPreset enviado) {
  if (gravado.nome != enviado.nome || _cadeia(gravado) != _cadeia(enviado)) return false;
  for (final bloco in _blocos(enviado)) {
    final relido = gravado.bloco(bloco.posicao);
    if (relido == null || !_blocoConfere(relido, bloco)) return false;
  }
  return true;
}

bool _blocoConfere(BlocoPreset gravado, BlocoPreset enviado) {
  if (gravado.arquivoDeIr != enviado.arquivoDeIr) return false;
  final quantidade = gravado.quantidadeCenas > enviado.quantidadeCenas ? gravado.quantidadeCenas : enviado.quantidadeCenas;
  for (var cena = 1; cena <= quantidade; cena++) {
    if (gravado.habilitadoNaCena(cena) != enviado.habilitadoNaCena(cena)) return false;
    for (final simbolo in enviado.simbolosGuardados) {
      if (!_mesmoValor(gravado.valorNaCena(simbolo, cena), enviado.valorNaCena(simbolo, cena))) return false;
    }
  }
  return true;
}

bool _mesmoValor(num? gravado, num? enviado) {
  if (gravado == null || enviado == null) return gravado == enviado;
  final escala = enviado.abs() > 1 ? enviado.abs() : 1;
  return (gravado - enviado).abs() <= _toleranciaRelativa * escala;
}

Iterable<BlocoPreset> _blocos(DocumentoPreset documento) => [
      for (var linha = 1; linha <= PosicaoBloco.linhas; linha++) ...documento.blocosDaLinha(linha),
    ];

String _cadeia(DocumentoPreset documento) =>
    [for (final bloco in _blocos(documento)) '${bloco.posicao}=${bloco.uri}'].join(';');
