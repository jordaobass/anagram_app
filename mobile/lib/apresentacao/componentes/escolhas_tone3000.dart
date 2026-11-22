// Os cartões TOM e MODELO do bloco TONE3000, montados com os tons que a
// pedaleira devolveu. Escolher grava o caminho do modelo no bloco (ao vivo,
// desfazer, não salvo). Tom enviado pela pessoa aparece só para consulta: a
// pedaleira não diz o nome do arquivo dele (DECISOES T3K4).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/modelo_carregado.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/tone3000/tom_tone3000.dart';
import '../../nucleo/tone3000/tons_da_pedaleira.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';
import 'cartoes_de_opcoes.dart';

/// Rótulo por item, sem repetição: dois tons com o mesmo título ganham o id.
Map<String, T> rotulosUnicos<T>(List<T> itens, String Function(T) nome, int Function(T) id) {
  final repetidos = <String, int>{};
  for (final item in itens) {
    repetidos.update(nome(item), (n) => n + 1, ifAbsent: () => 1);
  }
  return {for (final item in itens) repetidos[nome(item)]! > 1 ? '${nome(item)} (#${id(item)})' : nome(item): item};
}

class EscolhasTone3000 {
  EscolhasTone3000(this.context, this.ref, {required this.bloco, required this.definicao, required this.tons})
      : formato = FormatoTom.doBloco(bloco.uri)!,
        l = AppLocalizations.of(context) {
    porRotulo = rotulosUnicos(tons.doFormato(formato), (t) => t.titulo, (t) => t.id);
    noBloco = tons.doBloco(bloco.uri, bloco.arquivoDeIr);
  }

  final BuildContext context;
  final WidgetRef ref;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final TonsDaPedaleira tons;
  final FormatoTom formato;
  final AppLocalizations l;
  late final Map<String, TomTone3000> porRotulo;
  late final TomNoBloco? noBloco;

  List<Widget> cartoes() => [_tom(), if (noBloco case final achado?) _modelo(achado)];

  void _gravar(TomTone3000 tom, ModeloDoTom? modelo) {
    final caminho = modelo == null ? null : tom.caminhoDo(modelo);
    if (caminho != null) ref.read(editorProvider.notifier).escolherIrDoGabinete(bloco.posicao, caminho);
  }

  Widget _fotoDo(TomTone3000 tom, double tamanho) => ArteBlocoWidget(
      definicao: definicao,
      tamanho: tamanho,
      arquivoIr: tom.caminhoDeReferencia,
      gearDoTom: tom.gear,
      ligado: bloco.habilitado);

  Widget _tom() {
    final atual = noBloco?.tom;
    return CartaoDeOpcoes(
      chave: 'tom',
      rotulo: l.t3kTom,
      opcoes: porRotulo.keys.toList(),
      atual: _rotuloDe(porRotulo, atual),
      noCartao: atual == null
          ? ArteBlocoWidget(definicao: definicao, tamanho: Medidas.fotoNoCartaoGabinete, ligado: bloco.habilitado)
          : _fotoDo(atual, Medidas.fotoNoCartaoGabinete),
      visual: (r) => _fotoDo(porRotulo[r]!, Medidas.fotoNaGaleria),
      emGrade: true,
      detalhe: (r) => _detalhe(porRotulo[r]!),
      habilitada: (r) => !porRotulo[r]!.doUsuario,
      // tom novo começa no primeiro modelo, como a pedaleira lista
      aoEscolher: (r) => _gravar(porRotulo[r]!, porRotulo[r]!.modelos.firstOrNull),
    );
  }

  String _detalhe(TomTone3000 tom) {
    final autor = tom.autor ?? l.t3kSemAutor;
    final licenca = tom.licenca ?? '—';
    return tom.doUsuario ? l.t3kDetalheSeu(autor, licenca) : l.t3kDetalheFabrica(autor, licenca);
  }

  Widget _modelo(TomNoBloco achado) {
    final porNome = rotulosUnicos(achado.tom.modelos, (m) => m.nome, (m) => m.id);
    final icone = formato == FormatoTom.ir ? Icons.surround_sound : Icons.graphic_eq;
    return CartaoDeOpcoes(
      chave: 'modelo-tom',
      rotulo: l.t3kModelo,
      opcoes: porNome.keys.toList(),
      // arquivo que não é um dos modelos listados: mostra o nome dele, sem trocar
      atual: _rotuloDe(porNome, achado.modelo) ?? modeloCarregadoDe(bloco.uri, bloco.arquivoDeIr)?.nomeDoArquivo,
      noCartao: Icon(icone, size: Medidas.iconeNoCartaoGabinete, color: Cores.aluminioClaro),
      visual: (_) => Icon(icone, size: Medidas.iconeMicrofone, color: Cores.aluminioClaro),
      habilitada: (_) => !achado.tom.doUsuario,
      aoEscolher: (nome) => _gravar(achado.tom, porNome[nome]),
    );
  }

  static String? _rotuloDe<T>(Map<String, T> porRotulo, T? item) {
    for (final MapEntry(:key, :value) in porRotulo.entries) {
      if (value == item) return key;
    }
    return null;
  }
}
