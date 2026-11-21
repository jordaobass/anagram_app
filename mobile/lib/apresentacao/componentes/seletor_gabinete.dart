// Escolha do gabinete no painel do bloco, como a pedaleira mostra: a foto
// grande da caixa escolhida e, ao lado, GABINETE (busca escrevendo, setas
// ‹ ›) → MICROFONE → POSIÇÃO em botões, no estilo das opções dos parâmetros.
// A escolha vira o arquivo de IR do bloco. Só aparece no build com a tabela
// do Darkglass Suite.
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
import 'campo_modelo_gabinete.dart';
import 'escolha_em_botoes.dart';
import 'pintor_microfone.dart';

class SeletorGabinete extends ConsumerWidget {
  const SeletorGabinete({super.key, required this.bloco, required this.definicao});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = TipoGabinete.daUri(bloco.uri);
    final catalogo = ref.watch(indiceMiniaturasProvider).value?.escolhasDeGabinete;
    if (tipo == null || catalogo == null || !catalogo.temEscolhas(tipo)) return const SizedBox.shrink();
    final foto = _foto(bloco.arquivoDeIr, Medidas.fotoGabineteGrande);
    final controles = _controles(context, ref, tipo, catalogo);
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.l),
      child: LayoutBuilder(
        builder: (context, restricoes) => restricoes.maxWidth >= Medidas.larguraGabineteLadoALado
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                foto,
                const SizedBox(width: Espacos.xl),
                Expanded(child: controles),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: foto),
                const SizedBox(height: Espacos.m),
                controles,
              ]),
      ),
    );
  }

  Widget _controles(BuildContext context, WidgetRef ref, TipoGabinete tipo, CatalogoGabinetes catalogo) {
    final l = AppLocalizations.of(context);
    final atual = catalogo.doArquivo(tipo, bloco.arquivoDeIr);
    void escolher(OpcaoGabinete? opcao) {
      if (opcao != null) ref.read(editorProvider.notifier).escolherIrDoGabinete(bloco.posicao, opcao.caminho);
    }

    final modelo = CampoModeloGabinete(
      rotulo: l.cbGabinete,
      modelos: catalogo.modelos(tipo),
      atual: atual?.modelo,
      foto: (m) => _foto(catalogo.escolher(tipo, m)?.caminho, Medidas.fotoNaEscolhaDeGabinete),
      aoEscolher: (m) => escolher(catalogo.escolher(tipo, m, microfone: atual?.microfone, posicao: atual?.posicao)),
    );
    // IR que não está na tabela (do usuário): mostra o arquivo; o modelo ainda pode ser escolhido
    if (atual == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (bloco.arquivoDeIr != null) _irProprio(context, l),
        modelo,
      ]);
    }
    final posicoes = catalogo.posicoes(tipo, atual.modelo, atual.microfone);
    final cor = Cores.daFamilia(definicao.familia);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      modelo,
      const SizedBox(height: Espacos.m),
      EscolhaEmBotoes(
        rotulo: l.cbMicrofone,
        prefixoChave: 'microfone',
        opcoes: catalogo.microfones(tipo, atual.modelo),
        atual: atual.microfone,
        cor: cor,
        icone: (mic, marcada) =>
            IconeMicrofone(tipo: TipoMicrofone.doNome(mic), cor: marcada ? Cores.tintaMarcador : Cores.aluminioClaro),
        aoEscolher: (mic) => escolher(catalogo.escolher(tipo, atual.modelo, microfone: mic, posicao: atual.posicao)),
      ),
      if (posicoes.any((p) => p.isNotEmpty)) ...[
        const SizedBox(height: Espacos.m),
        EscolhaEmBotoes(
          rotulo: l.cbPosicao,
          prefixoChave: 'posicao',
          opcoes: posicoes,
          atual: atual.posicao,
          cor: cor,
          aoEscolher: (pos) => escolher(catalogo.escolher(tipo, atual.modelo, microfone: atual.microfone, posicao: pos)),
        ),
      ],
    ]);
  }

  Widget _irProprio(BuildContext context, AppLocalizations l) => Padding(
        padding: const EdgeInsets.only(bottom: Espacos.s),
        child: Text(l.cbIrDoUsuario(bloco.arquivoDeIr!.split('/').last), style: Theme.of(context).textTheme.bodySmall),
      );

  /// Foto da caixa pelo IR (todos os IRs de um modelo têm a mesma foto).
  Widget _foto(String? arquivoIr, double tamanho) =>
      ArteBlocoWidget(definicao: definicao, tamanho: tamanho, arquivoIr: arquivoIr, ligado: bloco.habilitado);
}
