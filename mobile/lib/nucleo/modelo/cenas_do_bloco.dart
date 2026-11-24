// A pedaleira toca o que está no PRÓPRIO bloco: o `enabled` e o valor de cada
// parâmetro são os da cena ativa. Cada cena (`scenes`) guarda a foto dela para
// quando voltar a ser a ativa. Conferido nos presets reais (exemplos 1 e 2):
// o bloco tem sempre exatamente os valores da cena ativa. Por isso trocar de
// cena guarda a foto da cena que sai e carrega no bloco a da que entra.
import 'json_util.dart';
import 'preset_bruto.dart';

/// Onde vale uma edição (parâmetro ou liga/desliga) com uma cena ativa: a
/// chave "Controlar" do editor, espelho do botão que a Anagram mostra no modo
/// Scene (manual KosmOS 1.17, "Controlling Active Scene" / "Controlling All
/// Scenes"; DECISOES CE1).
enum EscopoCenas {
  /// Só a cena ativa muda: o parâmetro (ou o liga/desliga) passa a fazer parte
  /// das cenas, e as outras ganham a foto do valor que tinham, para não mudarem.
  soNaCena,

  /// Todas as cenas mudam: o valor vai para o bloco e sai das fotos de cena,
  /// que voltam a seguir o bloco (o parâmetro deixa de variar entre as cenas).
  todasAsCenas,
}

/// Cenas que um preset sem registro de cena tem: as três de sempre.
const cenasMinimas = 3;

/// O firmware 1.16+ aceita até 126 cenas pelo MIDI (CC 107) e o 1.19.2 fala
/// em 127 (issue #39); acima disso a chave é lixo, não cena.
const cenasMaximas = 127;

/// Quantas cenas o preset tem: a maior cena que ele registra em algum lugar
/// (nome, foto de bloco, mensagens MIDI por cena ou a cena ativa), nunca
/// menos que três. O arquivo não guarda a quantidade (504 presets lidos do
/// 1.19.2, nenhum com campo para isso). HIPÓTESE (DECISOES CE3): cena a mais
/// usa as mesmas chaves numéricas das três; uma cena que não registra nada
/// (sem nome, sem foto) não aparece.
int quantidadeDeCenas(Map<String, dynamic> preset) {
  var maior = (numeroOuNulo(preset['scene'])?.toInt() ?? 0) + 1;
  void considerar(Object? mapa) {
    for (final chave in chavesNumericas(mapaOuVazio(mapa))) {
      final cena = int.parse(chave);
      if (cena > maior && cena <= cenasMaximas) maior = cena;
    }
  }

  considerar(preset['sceneNames']);
  considerar(mapaOuVazio(preset['metadata'])['midi_messages_on_scene_change']);
  for (final bloco in todosOsBlocos(preset)) {
    considerar(bloco['scenes']);
  }
  return maior.clamp(cenasMinimas, cenasMaximas);
}

/// Guarda na foto da cena [cena] o estado atual do bloco, só no que a foto
/// já registra: o que ela não registra segue o bloco (e a edição só na cena
/// já cria o registro nas três, ver [EscopoCenas.soNaCena]).
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
void fixarLigaNasOutrasCenas(Map<String, dynamic> bloco, int ativa, int quantidade) {
  final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
  for (final cena in _cenas(quantidade).where((c) => c != ativa)) {
    final foto = cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;
    foto.putIfAbsent('enabled', () => bloco['enabled'] ?? true);
  }
}

/// Antes de um parâmetro mudar só na cena ativa, as outras cenas sem registro
/// dele recebem o valor que tinham ([valorAntes], o do bloco ou o padrão do
/// catálogo quando o bloco não o guarda), para não mudarem junto.
void fixarValorNasOutrasCenas(Map<String, dynamic> bloco, int ativa, int quantidade, String simbolo, num valorAntes) {
  final cenas = bloco.putIfAbsent('scenes', () => <String, dynamic>{}) as Map<String, dynamic>;
  for (final cena in _cenas(quantidade).where((c) => c != ativa)) {
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

/// Ao abrir um preset: o que alguma foto de cena registra (parâmetro ou
/// liga/desliga) passa a estar em todas as [quantidade] cenas, e as que não o tinham recebem o
/// valor do bloco no arquivo (DECISOES CE2). Sem isso a cena sem registro
/// tocava o que a última cena visitada deixou no bloco, sem "NÃO SALVO".
/// Preset em que toda foto registra o mesmo que as outras não muda.
void completarFotosParciais(Map<String, dynamic> bloco, int quantidade) {
  final cenas = bloco['scenes'];
  if (cenas is! Map<String, dynamic> || cenas.isEmpty) return;
  final comLiga = cenas.values.any((c) => mapaOuVazio(c).containsKey('enabled'));
  final simbolos = _simbolosQueVariam(cenas);
  for (final cena in _cenas(quantidade)) {
    if (comLiga) _fotoDaCena(cenas, cena).putIfAbsent('enabled', () => bloco['enabled'] ?? true);
    for (final simbolo in simbolos) {
      // o bloco não guarda o parâmetro: a cena segue o padrão do catálogo
      final valor = valorNoBloco(bloco, simbolo);
      if (valor == null || _registra(mapaOuVazio(cenas['$cena']), simbolo)) continue;
      _gravarNaCena(_fotoDaCena(cenas, cena), simbolo, valor);
    }
  }
}

Iterable<int> _cenas(int quantidade) => [for (var cena = 1; cena <= quantidade; cena++) cena];

Map<String, dynamic> _fotoDaCena(Map<String, dynamic> cenas, int cena) =>
    cenas.putIfAbsent('$cena', () => <String, dynamic>{'parameters': <dynamic>[]}) as Map<String, dynamic>;

/// Tira [simbolo] de todas as fotos de cena: as cenas voltam a seguir o bloco.
void tirarDasFotos(Map<String, dynamic> bloco, String simbolo) {
  for (final foto in _fotos(bloco)) {
    final lista = foto['parameters'];
    if (lista is List) lista.removeWhere((item) => item is Map<String, dynamic> && item['symbol'] == simbolo);
  }
  _soltarFotosVazias(bloco);
}

/// Tira o liga/desliga de todas as fotos de cena: as cenas seguem o bloco.
void tirarLigaDasFotos(Map<String, dynamic> bloco) {
  for (final foto in _fotos(bloco)) {
    foto.remove('enabled');
  }
  _soltarFotosVazias(bloco);
}

Iterable<Map<String, dynamic>> _fotos(Map<String, dynamic> bloco) =>
    mapaOuVazio(bloco['scenes']).values.whereType<Map<String, dynamic>>();

/// Foto sem liga/desliga e sem parâmetro some, como nos presets da própria
/// pedaleira (bloco sem nada por cena tem `scenes: {}`).
void _soltarFotosVazias(Map<String, dynamic> bloco) {
  final cenas = bloco['scenes'];
  if (cenas is! Map<String, dynamic>) return;
  cenas.removeWhere((_, foto) {
    if (foto is! Map<String, dynamic>) return false;
    final lista = foto['parameters'];
    final semParametro = lista == null || (lista is List && lista.isEmpty);
    return semParametro && foto.keys.every((chave) => chave == 'parameters');
  });
}

bool _registra(Map<String, dynamic> foto, String simbolo) {
  final lista = foto['parameters'];
  return lista is List && lista.whereType<Map<String, dynamic>>().any((item) => item['symbol'] == simbolo);
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
