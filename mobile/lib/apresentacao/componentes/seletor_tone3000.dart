// Escolha do tom no painel dos blocos TONE3000 (NAM Loader e Tone3000
// Cabinet), entre os tons que estão na pedaleira, nos cartões do gabinete:
// TOM (foto ou ícone do tipo, galeria com busca, autor e licença) e MODELO.
// Sem rede e sem enviar arquivo: a lista é a que a pedaleira devolveu, lida
// uma vez por conexão. Sem lista (firmware sem `t3k`, sem conexão), nada
// aparece e o bloco continua como estava.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/tons_da_pedaleira.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/modelo_carregado.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/tone3000/tom_tone3000.dart';
import '../../nucleo/tone3000/tons_da_pedaleira.dart';
import '../tema/tokens.dart';
import 'cartoes_de_opcoes.dart';
import 'escolhas_tone3000.dart';

/// TOM e MODELO lado a lado; a terceira vaga fica vazia, para os cartões
/// terem a largura dos do gabinete.
const _vagas = 3;

class SeletorTone3000 extends ConsumerWidget {
  const SeletorTone3000({super.key, required this.bloco, required this.definicao});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (FormatoTom.doBloco(bloco.uri) == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final conteudo = switch (ref.watch(tonsDaPedaleiraProvider)) {
      AsyncData(:final value) when value.disponivel => _comTons(context, ref, value),
      AsyncData(:final value) when value.falhou => _falhou(context, ref, l),
      AsyncLoading() => _aviso(context, l.t3kLendo, chave: 't3k-lendo'),
      _ => null,
    };
    if (conteudo == null) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: Espacos.l), child: conteudo);
  }

  Widget _comTons(BuildContext context, WidgetRef ref, TonsDaPedaleira tons) {
    final l = AppLocalizations.of(context);
    final escolhas = EscolhasTone3000(context, ref, bloco: bloco, definicao: definicao, tons: tons);
    final tom = escolhas.noBloco?.tom;
    final carregado = modeloCarregadoDe(bloco.uri, bloco.arquivoDeIr);
    final doFormato = tons.doFormato(escolhas.formato);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (tom == null && carregado != null)
        _aviso(context, l.t3kNaoEncontrado(carregado.nomeDoArquivo), chave: 't3k-nao-encontrado'),
      if (tom != null && tom.doUsuario) _aviso(context, l.t3kSoConsulta, chave: 't3k-so-consulta'),
      FileiraDeCartoes(cartoes: escolhas.cartoes(), vagas: _vagas),
      const SizedBox(height: Espacos.xs),
      _aviso(context, l.t3kResumo(doFormato.where((t) => !t.doUsuario).length, doFormato.where((t) => t.doUsuario).length),
          chave: 't3k-resumo'),
      if (escolhas.formato == FormatoTom.ir) _aviso(context, l.t3kIrNaoConferido, chave: 't3k-ir-nao-conferido'),
    ]);
  }

  Widget _falhou(BuildContext context, WidgetRef ref, AppLocalizations l) => Row(children: [
        Flexible(child: _aviso(context, l.t3kFalhou, chave: 't3k-falhou')),
        TextButton(
          key: const ValueKey('t3k-tentar-de-novo'),
          onPressed: () => ref.invalidate(tonsDaPedaleiraProvider),
          child: Text(l.t3kTentarDeNovo),
        ),
      ]);

  Widget _aviso(BuildContext context, String texto, {required String chave}) => Padding(
        padding: const EdgeInsets.only(bottom: Espacos.s),
        child: Text(texto,
            key: ValueKey(chave),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      );
}
