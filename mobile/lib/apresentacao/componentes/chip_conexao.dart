// O estado da conexão num chip só, à esquerda da barra: LED + frase curta
// ("Anagram · fw 1.18", "Demonstração", "Procurando a pedaleira…"). Com a
// pedaleira (ou a demonstração) do outro lado, o chip abre um menu com a
// frase inteira e o Desconectar; nos outros estados ele só informa, porque a
// tela de conectar logo abaixo já traz as ações (DECISOES BS1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'item_de_menu.dart';

/// O que o chip mostra: a cor do LED, a frase curta e a frase inteira (menu e leitor de tela).
typedef ResumoConexao = ({Color cor, String curto, String completo});

ResumoConexao resumoDaConexao(AppLocalizations l, Paleta cores, EstadoConexao estado) => switch (estado) {
      SemConexao() => (cor: cores.ledDesligado, curto: l.estadoSemConexao, completo: l.estadoSemConexao),
      Conectando(demonstracao: true) =>
        (cor: cores.tallyTinta, curto: l.txEstadoAbrindoDemonstracao, completo: l.txEstadoAbrindoDemonstracao),
      Conectando(automatica: true) => (cor: cores.tallyTinta, curto: l.caProcurando, completo: l.caProcurando),
      Conectando(:final meio) => _igual(cores.tallyTinta, l.estadoConectando(TextosDoApp.meioVisivel(meio))),
      Conectada(demonstracao: true) =>
        (cor: cores.ledDemonstracao, curto: l.barraDemonstracaoCurta, completo: l.estadoDemonstracao),
      Conectada(:final meio, :final firmware) => (
          cor: cores.ledLigado,
          curto: l.barraConectadaCurta(firmwareCurto(firmware)),
          completo: l.estadoConectada(TextosDoApp.meioVisivel(meio), firmware),
        ),
      FalhaDeConexao() => _igual(cores.erro, l.estadoFalha),
    };

/// "v1.18.1.23 (beta)" vira "1.18.1.23": o rótulo "fw" já diz o que é, e o
/// resto continua na frase inteira, no menu.
String firmwareCurto(String firmware) =>
    TextosDoApp.meioVisivel(firmware).replaceFirst(RegExp('^[vV](?=[0-9])'), '');

ResumoConexao _igual(Color cor, String texto) => (cor: cor, curto: texto, completo: texto);

enum _AcaoConexao { desconectar }

class ChipConexao extends ConsumerWidget {
  const ChipConexao({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final estado = ref.watch(conexaoProvider);
    final resumo = resumoDaConexao(l, context.cores, estado);
    final comMenu = estado is Conectada;
    final chip = Semantics(
      liveRegion: true,
      label: l.conexaoSemantica(resumo.completo),
      excludeSemantics: true,
      child: _CorpoDoChip(resumo: resumo, comMenu: comMenu, linhas: compacta ? 2 : 1),
    );
    if (!comMenu) return chip;
    // o realce do mouse segue o canto do chip, não um retângulo
    return ClipRRect(
      borderRadius: BorderRadius.circular(Raios.controle),
      child: PopupMenuButton<_AcaoConexao>(
      key: const ValueKey('chip-conexao'),
      tooltip: l.conexaoSemantica(resumo.completo),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Raios.controle)),
      onSelected: (_) => ref.read(conexaoProvider.notifier).desconectar(),
      itemBuilder: (_) => [
        PopupMenuItem<_AcaoConexao>(
          enabled: false,
          height: alturaItemDeMenu,
          child: DetalheDeMenu(resumo.completo),
        ),
        const PopupMenuDivider(height: Espacos.s),
        itemDeMenu(_AcaoConexao.desconectar,
            key: const ValueKey('menu-desconectar'), icone: Icons.link_off, rotulo: l.desconectar),
      ],
      child: chip,
    ));
  }
}

/// LED + frase + (com menu) a seta; o mesmo desenho em todos os estados,
/// para a barra não pular quando a conexão muda.
class _CorpoDoChip extends StatelessWidget {
  const _CorpoDoChip({required this.resumo, required this.comMenu, required this.linhas});

  final ResumoConexao resumo;
  final bool comMenu;
  final int linhas;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: MedidasDoTopo.daPlataforma.chipConexao),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              key: const ValueKey('led-conexao'),
              width: Medidas.led,
              height: Medidas.led,
              decoration: BoxDecoration(color: resumo.cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: Espacos.s),
            Flexible(
              child: Text(resumo.curto,
                  key: const ValueKey('texto-conexao'),
                  maxLines: linhas,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            if (comMenu) ...[
              const SizedBox(width: Espacos.xs),
              Icon(Icons.expand_more, size: Medidas.setaChip, color: context.cores.aluminioClaro),
            ],
          ]),
        ),
      );
}
