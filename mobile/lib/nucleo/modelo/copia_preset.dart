// Nome e leitura dos arquivos de backup dos presets (DECISOES BK2). O nome do
// arquivo diz tudo o que a lista de restaurar mostra — quando, área, slot e
// nome —, para listar sem abrir cada JSON:
//   backups/AAAA-MM-DD/HHMMSS_<area>_<slot>_<nome>.json            (automático)
//   backups/AAAA-MM-DD/completo_HHMMSS/<area>_<slot>_<nome>.json   (completo)
import 'slot_preset.dart';

/// Área no nome do arquivo quando o firmware não tem áreas (antes da 1.18).
const areaUnicaNaCopia = 'unica';

/// Prefixo da pasta de um backup completo, dentro da pasta do dia.
const prefixoCopiaCompleta = 'completo_';

/// Só letras (com acento), dígitos, espaço, hífen e sublinhado: o nome do
/// preset é livre e pode ter barra ou dois-pontos, que o sistema de arquivos
/// recusa. O acento fica: "Área" não pode virar "rea" na lista de backups.
String nomeSeguroDeArquivo(String nome, {String padrao = 'preset'}) {
  final limpo = nome.replaceAll(RegExp(r'[^\p{L}\p{N}_\- ]', unicode: true), '').trim();
  return limpo.isEmpty ? padrao : limpo;
}

String doisDigitos(int n) => n.toString().padLeft(2, '0');

/// "2026-11-22": a pasta do dia.
String pastaDoDia(DateTime quando) =>
    '${quando.year.toString().padLeft(4, '0')}-${doisDigitos(quando.month)}-${doisDigitos(quando.day)}';

/// "143205": a hora no começo do arquivo (ou no nome da pasta do completo).
String horaDaCopia(DateTime quando) =>
    '${doisDigitos(quando.hour)}${doisDigitos(quando.minute)}${doisDigitos(quando.second)}';

/// De onde veio o preset guardado.
class OrigemDaCopia {
  const OrigemDaCopia({required this.slot, required this.area, required this.nome});

  final SlotPreset slot;

  /// Id da área ("user", "user-2"); nulo = firmware sem áreas.
  final String? area;
  final String nome;

  /// "user-2_01A_My tone": o fim do nome do arquivo, sem hora nem extensão.
  String get sufixo => '${area ?? areaUnicaNaCopia}_${slot.rotulo}_${nomeSeguroDeArquivo(nome)}';
}

/// Um arquivo de backup achado na pasta.
class CopiaGuardada {
  const CopiaGuardada({required this.caminho, required this.quando, required this.origem, this.completa});

  final String caminho;
  final DateTime quando;
  final OrigemDaCopia origem;

  /// A pasta do backup completo de que o arquivo faz parte; nulo = automático.
  final String? completa;

  /// Lê o caminho relativo à pasta de backups (partes já separadas):
  /// `[dia, arquivo]` ou `[dia, completo_HHMMSS, arquivo]`. Fora do formato
  /// (arquivo da pessoa, nome mexido) = nulo, e a lista o ignora.
  static CopiaGuardada? doCaminho(String caminho, List<String> partes) {
    if (partes.length < 2 || partes.length > 3 || !partes.last.endsWith('.json')) return null;
    final dia = DateTime.tryParse(partes.first);
    if (dia == null || partes.first.length != 10) return null;
    final completa = partes.length == 3 ? partes[1] : null;
    final semExtensao = partes.last.substring(0, partes.last.length - '.json'.length);
    final campos = semExtensao.split('_');
    final hora = completa == null ? campos.firstOrNull : _horaDaPasta(completa);
    final resto = completa == null ? campos.skip(1).toList() : campos;
    if (hora == null || resto.length < 3) return null;
    final quando = _juntar(dia, hora);
    final slot = _slot(resto[1]);
    if (quando == null || slot == null) return null;
    final area = resto.first == areaUnicaNaCopia ? null : resto.first;
    return CopiaGuardada(
      caminho: caminho,
      quando: quando,
      origem: OrigemDaCopia(slot: slot, area: area, nome: resto.skip(2).join('_')),
      completa: completa,
    );
  }

  static String? _horaDaPasta(String pasta) =>
      pasta.startsWith(prefixoCopiaCompleta) ? pasta.substring(prefixoCopiaCompleta.length) : null;

  static DateTime? _juntar(DateTime dia, String hora) {
    if (hora.length != 6 || int.tryParse(hora) == null) return null;
    final (h, m, s) = (int.parse(hora.substring(0, 2)), int.parse(hora.substring(2, 4)), int.parse(hora.substring(4)));
    if (h > 23 || m > 59 || s > 59) return null;
    return DateTime(dia.year, dia.month, dia.day, h, m, s);
  }

  static SlotPreset? _slot(String rotulo) {
    if (rotulo.length < 2) return null;
    try {
      return SlotPreset.doRotulo(rotulo);
    } on FormatException {
      return null;
    }
  }
}
