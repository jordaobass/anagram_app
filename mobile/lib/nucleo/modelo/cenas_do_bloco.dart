// A pedaleira toca o que está no PRÓPRIO bloco: o `enabled` e o valor de cada
// parâmetro são os da cena ativa. Cada cena (`scenes`) guarda a foto dela para
// quando voltar a ser a ativa. Conferido nos presets reais (exemplos 1 e 2):
// o bloco tem sempre exatamente os valores da cena ativa. Por isso trocar de
// cena guarda a foto da cena que sai e carrega no bloco a da que entra.
import 'json_util.dart';
import 'preset_bruto.dart';

/// Onde vale a edição de um parâmetro com uma cena ativa.
enum EscopoParametro {
  /// A regra do knob da tela (DECISOES C1): se a cena ativa já tem valor
  /// próprio, muda só nela; senão muda o bloco e vale para todas as cenas.
  comoNoKnob,

  /// Só a cena ativa muda: as outras cenas que seguiam o bloco ganham a foto
  /// do valor que tinham, para não mudarem junto (como [fixarLigaNasOutrasCenas]).
  soNaCena,

  /// O mesmo valor no bloco e em toda foto que registra o parâmetro.
  todasAsCenas,
}

/// Guarda na foto da cena [cena] o estado atual do bloco, só no que a foto
/// já registra: o que ela não registra segue o bloco (e toda edição de um
/// valor que varia já cria o registro na cena ativa, ver [gravarNaCenaAtiva]).
void guardarFotoDaCena(Map<String, dynamic> bloco, int cena) {
  final foto = mapaOuVazio(mapaOuVazio(bloco['scenes'])['$cena']);
  if (foto.isEmpty) return;
  if (foto.containsKey('enabled')) foto['enabled'] = bloco['enabled'] ?? true;
  final lista = foto['parameters'];
  if (lista is! List) return;
  for (final item in lista.whereType<Map<String, dynamic>>()) {
    final valor = valorNoBloco(bloco, '${item['symbol']}');
    if (valor != null) item['value'] = valor;
  }
}

/// Antes de o liga/desliga mudar na cena ativa, as outras cenas sem registro
/// recebem o estado que tinham (o do bloco), para não mudarem junto.
void fixarLigaNasOutrasCenas(Map<String, dynamic> bloco, int ativa) {
  final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
  for (final cena in [1, 2, 3].where((c) => c != ativa)) {
    final foto = cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;
    foto.putIfAbsent('enabled', () => bloco['enabled'] ?? true);
  }
}

/// Antes de um parâmetro mudar só na cena ativa, as outras cenas sem registro
/// dele recebem o valor que tinham ([valorAntes], o do bloco ou o padrão do
/// catálogo quando o bloco não o guarda), para não mudarem junto.
void fixarValorNasOutrasCenas(Map<String, dynamic> bloco, int ativa, String simbolo, num valorAntes) {
  final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
  for (final cena in [1, 2, 3].where((c) => c != ativa)) {
    final foto = cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;
    if (!_registra(foto, simbolo)) _gravarNaCena(foto, simbolo, valorAntes);
  }
}

/// Grava [valor] na foto da cena [cena], criando a foto e o registro se faltarem.
void gravarNaFotoDaCena(Map<String, dynamic> bloco, int cena, String simbolo, num valor) {
  final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
  final foto = cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;
  _gravarNaCena(foto, simbolo, valor);
}

/// Muda [simbolo] em toda foto que já o registra (as que não registram seguem o bloco).
void mudarEmTodasAsFotos(Map<String, dynamic> bloco, String simbolo, num valor) {
  for (final cena in [1, 2, 3]) {
    mudarSobreposicaoDaCena(bloco, cena, simbolo, valor);
  }
}

bool _registra(Map<String, dynamic> foto, String simbolo) {
  final lista = foto['parameters'];
  return lista is List && lista.whereType<Map<String, dynamic>>().any((item) => item['symbol'] == simbolo);
}

/// Um valor que varia entre as cenas, editado na cena ativa, vai para a foto
/// dela (criando o registro se faltar): senão a edição se perderia ao trocar
/// de cena, e o "não salvo" não a veria.
void gravarNaCenaAtiva(Map<String, dynamic> bloco, int cena, String simbolo, num valor) {
  final cenas = mapaOuVazio(bloco['scenes']);
  if (!_simbolosQueVariam(cenas).contains(simbolo)) return;
  final foto = cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;
  _gravarNaCena(foto, simbolo, valor);
}

/// O bloco sem o estado da cena ativa (o que varia entre as cenas fica só nas
/// fotos): é o que se compara para saber se há edição, porque trocar de cena
/// muda o bloco sem mudar o preset.
void semEstadoDaCena(Map<String, dynamic> bloco) {
  final cenas = mapaOuVazio(bloco['scenes']);
  if (cenas.isEmpty) return;
  if (cenas.values.any((c) => mapaOuVazio(c).containsKey('enabled'))) bloco.remove('enabled');
  final variam = _simbolosQueVariam(cenas);
  for (final entrada in mapaOuVazio(bloco['parameters']).values) {
    if (entrada is Map<String, dynamic> && variam.contains(entrada['symbol'])) entrada.remove('value');
  }
}

/// Traz para o bloco o que a cena [cena] guarda.
void carregarCena(Map<String, dynamic> bloco, int cena) {
  final foto = mapaOuVazio(mapaOuVazio(bloco['scenes'])['$cena']);
  if (foto['enabled'] is bool) bloco['enabled'] = foto['enabled'];
  final lista = foto['parameters'];
  if (lista is! List) return;
  for (final item in lista.whereType<Map<String, dynamic>>()) {
    final valor = numeroOuNulo(item['value']);
    if (valor != null) _gravarNoBloco(bloco, '${item['symbol']}', valor);
  }
}

num? valorNoBloco(Map<String, dynamic> bloco, String simbolo) {
  for (final entrada in mapaOuVazio(bloco['parameters']).values) {
    if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) return numeroOuNulo(entrada['value']);
  }
  return null;
}

Set<String> _simbolosQueVariam(Map<String, dynamic> cenas) => {
      for (final cena in cenas.values)
        if (mapaOuVazio(cena)['parameters'] case final List<dynamic> lista)
          for (final item in lista.whereType<Map<String, dynamic>>()) '${item['symbol']}',
    };

void _gravarNaCena(Map<String, dynamic> foto, String simbolo, num valor) {
  final lista = foto.putIfAbsent('parameters', () => <dynamic>[]) as List;
  for (final item in lista.whereType<Map<String, dynamic>>()) {
    if (item['symbol'] == simbolo) {
      item['value'] = valor;
      return;
    }
  }
  lista.add(<String, dynamic>{'symbol': simbolo, 'value': valor});
}

/// Só muda parâmetro que o bloco já tem: a cena não cria parâmetro novo.
void _gravarNoBloco(Map<String, dynamic> bloco, String simbolo, num valor) {
  for (final entrada in mapaOuVazio(bloco['parameters']).values) {
    if (entrada is Map<String, dynamic> && entrada['symbol'] == simbolo) {
      entrada['value'] = valor;
      return;
    }
  }
}
