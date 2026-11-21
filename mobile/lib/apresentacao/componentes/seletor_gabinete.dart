// Escolha do gabinete no painel do bloco, como a pedaleira oferece: GABINETE
// (modelo, com a foto) → MICROFONE → POSIÇÃO. A escolha vira o arquivo de IR
// do bloco. Só aparece no build com a tabela do Darkglass Suite.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/catalogo_gabinetes.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'arte_bloco.dart';

class SeletorGabinete extends ConsumerWidget {
  const SeletorGabinete({super.key, required this.bloco, required this.definicao});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = TipoGabinete.daUri(bloco.uri);
    final catalogo = ref.watch(indiceMiniaturasProvider).value?.escolhasDeGabinete;
    if (tipo == null || catalogo == null || !catalogo.temEscolhas(tipo)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.l),
      child: Wrap(
        spacing: Espacos.l,
        runSpacing: Espacos.m,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: _campos(context, ref, tipo, catalogo),
      ),
    );
  }

  List<Widget> _campos(BuildContext context, WidgetRef ref, TipoGabinete tipo, CatalogoGabinetes catalogo) {
    final atual = catalogo.doArquivo(tipo, bloco.arquivoDeIr);
    final l = AppLocalizations.of(context);
    void escolher(OpcaoGabinete? opcao) {
      if (opcao != null) ref.read(editorProvider.notifier).escolherIrDoGabinete(bloco.posicao, opcao.caminho);
    }

    final modelo = _campo(context, l.cbGabinete, 'gabinete-modelo', atual?.modelo, catalogo.modelos(tipo),
        (m) => escolher(catalogo.escolher(tipo, m, microfone: atual?.microfone, posicao: atual?.posicao)),
        imagem: (m) => _foto(catalogo, tipo, m));
    // IR que não está na tabela (do usuário): mostra o arquivo; o modelo ainda pode ser escolhido
    if (atual == null) return [if (bloco.arquivoDeIr != null) _irProprio(context, l), modelo];
    final posicoes = catalogo.posicoes(tipo, atual.modelo, atual.microfone);
    return [
      modelo,
      _campo(context, l.cbMicrofone, 'gabinete-microfone', atual.microfone, catalogo.microfones(tipo, atual.modelo),
          (mic) => escolher(catalogo.escolher(tipo, atual.modelo, microfone: mic, posicao: atual.posicao))),
      if (posicoes.isNotEmpty)
        _campo(context, l.cbPosicao, 'gabinete-posicao', atual.posicao, posicoes,
            (pos) => escolher(catalogo.escolher(tipo, atual.modelo, microfone: atual.microfone, posicao: pos))),
    ];
  }

  Widget _irProprio(BuildContext context, AppLocalizations l) =>
      Text(l.cbIrDoUsuario(bloco.arquivoDeIr!.split('/').last), style: Theme.of(context).textTheme.bodySmall);

  /// A foto do modelo é a do primeiro IR dele (todos os IRs do modelo têm a mesma).
  Widget _foto(CatalogoGabinetes catalogo, TipoGabinete tipo, String modelo) => ArteBlocoWidget(
        definicao: definicao,
        tamanho: Medidas.fotoNaEscolhaDeGabinete,
        arquivoIr: catalogo.escolher(tipo, modelo)?.caminho,
      );

  Widget _campo(BuildContext context, String rotulo, String chave, String? valor, List<String> opcoes,
      void Function(String) aoEscolher,
      {Widget Function(String)? imagem}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(rotulo.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
      DropdownButton<String>(
        key: ValueKey(chave),
        value: valor,
        hint: Text(AppLocalizations.of(context).cbEscolher),
        onChanged: (escolhido) {
          if (escolhido != null && escolhido != valor) aoEscolher(escolhido);
        },
        items: [
          for (final opcao in opcoes)
            DropdownMenuItem(
              value: opcao,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (imagem != null) ...[imagem(opcao), const SizedBox(width: Espacos.s)],
                Text(opcao),
              ]),
            ),
        ],
      ),
    ]);
  }
}
