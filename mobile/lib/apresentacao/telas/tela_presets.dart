// Lista de presets em tela cheia (celular).
import 'package:flutter/material.dart';

import '../componentes/lista_presets.dart';
import '../navegacao.dart';
import '../../l10n/app_localizations.dart';

class TelaPresets extends StatelessWidget {
  const TelaPresets({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).presets)),
        body: ListaPresets(aoAbrir: () => voltarSePuder(context)),
      );
}
