// Registro para suporte nas Configurações: o caminho do arquivo (selecionável)
// e um botão que copia as linhas mais novas para colar numa issue.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../plataforma/registro_em_arquivo.dart';
import '../tema/tokens.dart';

/// Quantas linhas vão para a área de transferência: o bastante para a sessão
/// em que o defeito aconteceu, pouco o bastante para caber numa issue.
const _linhasCopiadas = 300;

class SecaoRegistro extends StatelessWidget {
  const SecaoRegistro(this.arquivo, {super.key});

  final RegistroEmArquivo arquivo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.registroOnde, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Espacos.xs),
        SelectableText(arquivo.caminho,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
        const SizedBox(height: Espacos.m),
        OutlinedButton.icon(
          key: const ValueKey('copiar-registro'),
          icon: const Icon(Icons.copy),
          label: Text(l.registroCopiar),
          onPressed: () => _copiar(context),
        ),
      ],
    );
  }

  Future<void> _copiar(BuildContext context) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final aviso = AppLocalizations.of(context).registroCopiado;
    await Clipboard.setData(ClipboardData(text: await arquivo.ultimasLinhas(_linhasCopiadas)));
    mensageiro.showSnackBar(SnackBar(content: Text(aviso)));
  }
}
