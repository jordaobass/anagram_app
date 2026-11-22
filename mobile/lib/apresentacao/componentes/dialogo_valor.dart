// Digitar o valor de um knob: clicar no número embaixo dele abre este
// diálogo. A pessoa escreve o que vê ("-12,5 dB", "1,5k"); o núcleo lê, põe
// dentro da faixa e arredonda quando o parâmetro é inteiro.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/formatador_valor.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';

/// Devolve o valor escolhido, ou nulo se a pessoa cancelar.
Future<num?> digitarValor(BuildContext context, DefinicaoParametro parametro, num atual) =>
    showDialog<num>(context: context, builder: (_) => _DialogoValor(parametro: parametro, atual: atual));

class _DialogoValor extends StatefulWidget {
  const _DialogoValor({required this.parametro, required this.atual});

  final DefinicaoParametro parametro;
  final num atual;

  @override
  State<_DialogoValor> createState() => _EstadoDialogoValor();
}

class _EstadoDialogoValor extends State<_DialogoValor> {
  late final TextEditingController _texto;
  bool _invalido = false;

  @override
  void initState() {
    super.initState();
    _texto = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // começa com o valor de agora, já selecionado: digitar substitui
    if (_texto.text.isEmpty) {
      _texto.text = AppLocalizations.of(context).valorDe(widget.parametro, widget.atual);
      _texto.selection = TextSelection(baseOffset: 0, extentOffset: _texto.text.length);
    }
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _aplicar() {
    final valor = FormatadorValor.lerDigitado(widget.parametro, _texto.text);
    if (valor == null) return setState(() => _invalido = true);
    Navigator.pop(context, valor);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = widget.parametro;
    return AlertDialog(
      title: Text(p.nome),
      content: TextField(
        key: const ValueKey('digitar-valor'),
        controller: _texto,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _aplicar(),
        decoration: InputDecoration(
          helperText: l.kbFaixa(l.valorDe(p, p.minimo), l.valorDe(p, p.maximo)),
          errorText: _invalido ? l.kbNaoEhNumero : null,
        ),
      ),
      actions: [
        BotaoCancelarDialogo(rotulo: l.cancelar, aoTocar: () => Navigator.pop(context)),
        FilledButton(onPressed: _aplicar, child: Text(l.kbAplicar)),
      ],
    );
  }
}
