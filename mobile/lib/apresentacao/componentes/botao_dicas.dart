// As dicas de gesto de um painel atrás de um "?": à vista, as mesmas linhas
// em todo bloco viravam ruído (DECISOES UI2). Com mouse, parar sobre o "?"
// mostra; clicar (ou tocar) também, para quem não sabe que pode parar o mouse.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class BotaoDicas extends StatefulWidget {
  const BotaoDicas({super.key, required this.dicas});

  final List<String> dicas;

  @override
  State<BotaoDicas> createState() => _BotaoDicasState();
}

class _BotaoDicasState extends State<BotaoDicas> {
  final _balao = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: AppLocalizations.of(context).uiDicas,
        child: Tooltip(
          key: _balao,
          message: widget.dicas.join('\n'),
          showDuration: Duracoes.dicas,
          constraints: const BoxConstraints(maxWidth: Medidas.larguraExplicacao),
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Cores.aluminioClaro),
            onPressed: () => _balao.currentState?.ensureTooltipVisible(),
          ),
        ),
      );
}
