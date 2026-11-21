// Mute e Solo da banda, no título da coluna. O catálogo não tem porta de
// solo (só lo/mid/hi_mute), mas a tela ADV. da pedaleira tem SOLO; o app o
// faz pelos mutes: solo da banda X = X soando e as outras duas mutadas, numa
// alteração só e com DESFAZER. O Solo aparece ligado quando é exatamente esse
// o estado — inclusive se a pessoa chegou nele mutando à mão (DECISOES PP).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'alteracao_em_grupo.dart';
import 'controle_no_painel.dart';

/// Os mutes de todas as bandas do bloco, pelo símbolo.
Map<BandaMultibanda, String> mutesDoArranjo(ArranjoMultibanda arranjo) => {
      for (final b in arranjo.bandas) b.banda: b.mudo,
    };

/// A banda está em solo: só ela soa.
bool emSolo(BandaMultibanda banda, Map<BandaMultibanda, bool> mutadas) =>
    mutadas[banda] == false && mutadas.entries.where((e) => e.key != banda).every((e) => e.value);

/// Os mutes para pôr (ou tirar, se já está) a banda em solo.
Map<String, num> mutesDoSolo(BandaMultibanda banda, Map<BandaMultibanda, String> mutes, Map<BandaMultibanda, bool> mutadas) {
  final tirar = emSolo(banda, mutadas);
  return {for (final MapEntry(key: b, value: simbolo) in mutes.entries) simbolo: !tirar && b != banda ? 1 : 0};
}

class BotoesBanda extends ConsumerWidget {
  const BotoesBanda({
    super.key,
    required this.banda,
    required this.mutes,
    required this.bloco,
    required this.definicao,
    required this.cena,
    required this.cor,
  });

  final BandaMultibanda banda;
  final Color cor;
  final Map<BandaMultibanda, String> mutes;
  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;

  Map<BandaMultibanda, bool> get _mutadas => {
        for (final MapEntry(key: b, value: simbolo) in mutes.entries)
          if (definicao.parametro(simbolo) case final p?)
            b: DefinicaoParametro.estaLigado(ControleNoPainel.valorNaCena(bloco, p, cena)),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mudo = definicao.parametro(mutes[banda]!);
    if (mudo == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final mutadas = _mutadas;
    final muda = mutadas[banda] ?? false;
    final solo = emSolo(banda, mutadas);
    return Wrap(spacing: Espacos.xs, runSpacing: Espacos.xs, children: [
      _alternar(
        chave: 'solo-${banda.name}',
        texto: l.mbSolo,
        ligado: solo,
        cor: cor,
        aoTocar: () => alterarEmGrupo(context, ref,
            bloco: bloco,
            definicao: definicao,
            cena: cena,
            valores: mutesDoSolo(banda, mutes, mutadas),
            aviso: solo ? l.mbSoloDesligado : l.mbSoloLigado(l.mbNomeDaBanda(banda))),
      ),
      // o Mute pinta de alerta quando corta a banda: é o estado que mais se
      // esquece ligado e deixa o grave sumido sem motivo aparente
      _alternar(
        chave: 'mudo-${mudo.simbolo}',
        texto: l.mbMudo,
        ligado: muda,
        cor: Cores.fitaAlerta,
        aoTocar: () => ControleNoPainel.alterar(ref, mudo, bloco)(muda ? 0 : 1, arrastando: false),
      ),
    ]);
  }

  Widget _alternar(
          {required String chave, required String texto, required bool ligado, required Color cor, required VoidCallback aoTocar}) =>
      Semantics(
        toggled: ligado,
        label: texto,
        child: ligado
            ? FilledButton(
                key: ValueKey(chave),
                onPressed: aoTocar,
                style: FilledButton.styleFrom(backgroundColor: cor, foregroundColor: Cores.sobreAlerta),
                child: Text(texto),
              )
            : OutlinedButton(key: ValueKey(chave), onPressed: aoTocar, child: Text(texto)),
      );
}
