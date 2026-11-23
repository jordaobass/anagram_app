// Porta do servidor MCP: só números, validada antes de aplicar (abaixo de
// 1024 o sistema pede administrador; acima de 65535 não existe).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../aplicacao/mcp/controlador_mcp.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

class CampoPortaMcp extends StatefulWidget {
  const CampoPortaMcp({super.key, required this.porta, required this.aoAplicar});

  final int porta;
  final Future<void> Function(int porta) aoAplicar;

  @override
  State<CampoPortaMcp> createState() => _EstadoCampoPorta();
}

class _EstadoCampoPorta extends State<CampoPortaMcp> {
  late final _texto = TextEditingController(text: '${widget.porta}');
  bool _invalida = false;

  @override
  void didUpdateWidget(CampoPortaMcp antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.porta != widget.porta) _texto.text = '${widget.porta}';
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _aplicar() {
    final invalida = motivoPortaInvalida(_texto.text) != null;
    setState(() => _invalida = invalida);
    if (!invalida) widget.aoAplicar(int.parse(_texto.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: Medidas.larguraCampoPorta,
        child: TextField(
          key: const ValueKey('mcp-porta'),
          controller: _texto,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
          decoration: InputDecoration(labelText: l.mcpPorta),
          onSubmitted: (_) => _aplicar(),
        ),
      ),
      const SizedBox(width: Espacos.s),
      Padding(
        padding: const EdgeInsets.only(top: Espacos.s),
        child: TextButton(key: const ValueKey('mcp-aplicar-porta'), onPressed: _aplicar, child: Text(l.mcpAplicarPorta)),
      ),
      if (_invalida)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: Espacos.m, left: Espacos.s),
            child: Text(l.mcpPortaInvalida, style: TextStyle(color: context.cores.erro)),
          ),
        ),
    ]);
  }
}
