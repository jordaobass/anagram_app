// Lista de presets em tela cheia (celular).
import 'package:flutter/material.dart';

import '../componentes/lista_presets.dart';

class TelaPresets extends StatelessWidget {
  const TelaPresets({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Presets')),
        body: ListaPresets(aoAbrir: () => Navigator.of(context).maybePop()),
      );
}
