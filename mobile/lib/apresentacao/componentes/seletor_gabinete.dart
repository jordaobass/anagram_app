// Escolha do gabinete no painel do bloco, em três cartões do mesmo tamanho:
// GABINETE (a foto da caixa), MICROFONE (o ícone do tipo) e POSIÇÃO, cada um
// com setas ‹ › para passar opção a opção ouvindo cada uma, e a lista
// completa ao tocar no meio (a dos modelos em galeria com busca). Lado a lado
// no computador, empilhados no celular. A escolha vira o arquivo de IR do
// bloco. Só aparece no build com a tabela do Darkglass Suite.
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
import 'cartoes_de_opcoes.dart';
import 'pintor_microfone.dart';

/// Quantos cartões cabem na linha: com menos escolhas, os que há não esticam.
const _cartoesNaLinha = 3;

class SeletorGabinete extends ConsumerWidget {
  const SeletorGabinete({super.key, required this.bloco, required this.definicao});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = TipoGabinete.daUri(bloco.uri);
    final catalogo = ref.watch(indiceMiniaturasProvider).value?.escolhasDeGabinete;
    if (tipo == null || catalogo == null || !catalogo.temEscolhas(tipo)) return const SizedBox.shrink();
    final cartoes = _Escolhas(context, ref, this, tipo, catalogo).cartoes();
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacos.l),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (catalogo.doArquivo(tipo, bloco.arquivoDeIr) == null && bloco.arquivoDeIr != null) _irProprio(context),
        FileiraDeCartoes(cartoes: cartoes, vagas: _cartoesNaLinha),
      ]),
    );
  }

  /// IR que não está na tabela (do usuário): mostra o arquivo; o modelo ainda pode ser escolhido.
  Widget _irProprio(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Espacos.s),
        child: Text(AppLocalizations.of(context).cbIrDoUsuario(bloco.arquivoDeIr!.split('/').last),
            style: Theme.of(context).textTheme.bodySmall),
      );
}

/// Monta os cartões do gabinete atual; cada escolha grava o IR na hora.
class _Escolhas {
  _Escolhas(this.context, this.ref, this.seletor, this.tipo, this.catalogo)
      : atual = catalogo.doArquivo(tipo, seletor.bloco.arquivoDeIr),
        l = AppLocalizations.of(context);

  final BuildContext context;
  final WidgetRef ref;
  final SeletorGabinete seletor;
  final TipoGabinete tipo;
  final CatalogoGabinetes catalogo;
  final OpcaoGabinete? atual;
  final AppLocalizations l;

  List<Widget> cartoes() {
    final escolhido = atual;
    if (escolhido == null) return [_modelo(null)];
    final posicoes = catalogo.posicoes(tipo, escolhido.modelo, escolhido.microfone);
    return [_modelo(escolhido), _microfone(escolhido), if (posicoes.isNotEmpty) _posicao(escolhido, posicoes)];
  }

  void _gravar(OpcaoGabinete? opcao) {
    if (opcao != null) ref.read(editorProvider.notifier).escolherIrDoGabinete(seletor.bloco.posicao, opcao.caminho);
  }

  /// Foto da caixa pelo IR (todos os IRs de um modelo têm a mesma foto).
  Widget _foto(String? arquivoIr, double tamanho) => ArteBlocoWidget(
      definicao: seletor.definicao, tamanho: tamanho, arquivoIr: arquivoIr, ligado: seletor.bloco.habilitado);

  Widget _fotoDoModelo(String modelo, double tamanho) => _foto(catalogo.escolher(tipo, modelo)?.caminho, tamanho);

  Widget _modelo(OpcaoGabinete? escolhido) {
    void escolher(String modelo) => _gravar(
        catalogo.escolher(tipo, modelo, microfone: escolhido?.microfone, posicao: escolhido?.posicao));
    return CartaoDeOpcoes(
      chave: 'gabinete',
      rotulo: l.cbGabinete,
      opcoes: catalogo.modelos(tipo),
      atual: escolhido?.modelo,
      visual: (m) => _fotoDoModelo(m, Medidas.fotoNaGaleria),
      noCartao: escolhido == null
          ? _foto(seletor.bloco.arquivoDeIr, Medidas.fotoNoCartaoGabinete)
          : _fotoDoModelo(escolhido.modelo, Medidas.fotoNoCartaoGabinete),
      emGrade: true,
      aoEscolher: escolher,
    );
  }

  Widget _microfone(OpcaoGabinete escolhido) {
    Widget icone(String mic, double tamanho) =>
        IconeMicrofone(tipo: TipoMicrofone.doNome(mic), cor: context.cores.aluminioClaro, tamanho: tamanho);
    return CartaoDeOpcoes(
      chave: 'microfone',
      rotulo: l.cbMicrofone,
      opcoes: catalogo.microfones(tipo, escolhido.modelo),
      atual: escolhido.microfone,
      visual: (mic) => icone(mic, Medidas.iconeMicrofone),
      noCartao: icone(escolhido.microfone, Medidas.iconeNoCartaoGabinete),
      aoEscolher: (mic) =>
          _gravar(catalogo.escolher(tipo, escolhido.modelo, microfone: mic, posicao: escolhido.posicao)),
    );
  }

  Widget _posicao(OpcaoGabinete escolhido, List<String> posicoes) => CartaoDeOpcoes(
        chave: 'posicao',
        rotulo: l.cbPosicao,
        opcoes: posicoes,
        atual: escolhido.posicao,
        noCartao: Icon(Icons.track_changes, size: Medidas.iconeNoCartaoGabinete, color: context.cores.aluminioClaro),
        aoEscolher: (pos) =>
            _gravar(catalogo.escolher(tipo, escolhido.modelo, microfone: escolhido.microfone, posicao: pos)),
      );
}
