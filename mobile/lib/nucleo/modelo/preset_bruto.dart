// Operações sobre o JSON cru do preset (`chains` → linha → `blocks` → casa):
// achar, pôr e mudar blocos sem perder campos que o app não conhece. Quem
// chama já copiou o JSON: tudo aqui muda o mapa recebido.
import 'bloco_preset.dart';
import 'json_util.dart';

Iterable<Map<String, dynamic>> todosOsBlocos(Map<String, dynamic> preset) => [
      for (final linha in mapaOuVazio(preset['chains']).values)
        ...mapaOuVazio(mapaOuVazio(linha)['blocks']).values.whereType<Map<String, dynamic>>(),
    ];

Map<String, dynamic> blocosBrutos(Map<String, dynamic> preset, int linha) =>
    mapaOuVazio(mapaOuVazio(mapaOuVazio(preset['chains'])['$linha'])['blocks']);

/// Põe o bloco na casa criando a linha se faltar, e mantém as casas em
/// ordem numérica, como a pedaleira grava.
void colocarBloco(Map<String, dynamic> preset, PosicaoBloco posicao, Map<String, dynamic> bloco) {
  final chains = preset.putIfAbsent('chains', () => <String, dynamic>{}) as Map<String, dynamic>;
  final linha = chains.putIfAbsent('${posicao.linha}', () => <String, dynamic>{}) as Map<String, dynamic>;
  final blocos = linha.putIfAbsent('blocks', () => <String, dynamic>{}) as Map<String, dynamic>;
  blocos['${posicao.casa}'] = bloco;
  final ordenado = {for (final chave in chavesNumericas(blocos)) chave: blocos[chave]};
  final outras = {for (final e in blocos.entries) if (!ordenado.containsKey(e.key)) e.key: e.value};
  blocos
    ..clear()
    ..addAll(ordenado)
    ..addAll(outras);
}

/// Muda o valor que a cena [cena] guarda para [simbolo]; falso se a cena não
/// sobrepõe esse parâmetro.
bool mudarSobreposicaoDaCena(Map<String, dynamic> bloco, int cena, String simbolo, num valor) {
  final foto = mapaOuVazio(bloco['scenes'])['$cena'];
  final lista = foto is Map<String, dynamic> ? foto['parameters'] : null;
  if (lista is! List) return false;
  for (final item in lista) {
    if (item is Map<String, dynamic> && item['symbol'] == simbolo) {
      item['value'] = valor;
      return true;
    }
  }
  return false;
}

/// Muda o valor do parâmetro no bloco, criando a entrada se ele não existir.
void mudarValorBase(Map<String, dynamic> bloco, String simbolo, num valor, String nome) {
  final parametros = bloco.putIfAbsent('parameters', () => <String, dynamic>{}) as Map<String, dynamic>;
  for (final entrada in parametros.values) {
    if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) {
      entrada['value'] = valor;
      return;
    }
  }
  parametros[proximaChave(parametros)] = {'name': nome, 'symbol': simbolo, 'value': valor};
}
