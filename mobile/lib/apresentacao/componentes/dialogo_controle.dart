// Edição de um controle da pedaleira: o nome que o visor mostra, os alvos
// com a faixa de cada um, tirar um alvo, soltar o controle e atribuir um
// parâmetro do bloco aberto (o caminho do toque, onde não há botão direito).
// Tudo pelo editor: soa ao vivo, marca "não salvo" e só grava com Salvar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'alvo_do_controle.dart';
import 'atribuir_do_bloco.dart';
import 'dialogo_renomear.dart' show tamanhoMaximoNome;
import 'linha_alvo_controle.dart';

Future<void> abrirEdicaoControle(BuildContext context, WidgetRef ref, IdControle id) =>
    showDialog<void>(context: context, builder: (_) => DialogoControle(id: id));

class DialogoControle extends ConsumerStatefulWidget {
  const DialogoControle({super.key, required this.id});

  final IdControle id;

  @override
  ConsumerState<DialogoControle> createState() => _EstadoDialogoControle();
}

class _EstadoDialogoControle extends ConsumerState<DialogoControle> {
  late final _campo = TextEditingController(text: _controleAtual()?.nome ?? '');
  NomeInvalido? _motivo;

  ControlePedaleira? _controleAtual() => ref.read(editorProvider).atual?.controles[widget.id];

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  /// Nome mudado só vai ao preset ao confirmar o campo ou fechar: cada
  /// mudança toca o preset inteiro ao vivo, letra a letra seria demais.
  Future<bool> _aplicarNome() async {
    final controle = _controleAtual();
    if (controle == null || _campo.text.trim() == controle.nome) return true;
    final motivo = motivoNomeInvalido(_campo.text);
    if (motivo != null) {
      setState(() => _motivo = motivo);
      return false;
    }
    await ref.read(editorProvider.notifier).renomearControle(widget.id, _campo.text);
    return true;
  }

  Future<void> _fechar() async {
    if (await _aplicarNome() && mounted) Navigator.pop(context);
  }

  Future<void> _soltar() async {
    await ref.read(editorProvider.notifier).removerControle(widget.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // controle criado ou trocado enquanto o diálogo está aberto: o campo segue
    ref.listen(editorProvider.select((e) => e.atual?.controles[widget.id]?.nome), (antes, depois) {
      if (_campo.text.trim() == (antes ?? '')) _campo.text = depois ?? '';
    });
    final documento = ref.watch(editorProvider.select((e) => e.atual));
    final controle = documento?.controles[widget.id];
    final l = AppLocalizations.of(context);
    return AlertDialog(
      key: const ValueKey('dialogo-controle'),
      title: Text(l.rotuloControle(widget.id)),
      content: SizedBox(
        width: Medidas.larguraDialogo,
        child: SingleChildScrollView(child: _corpo(l, documento, controle)),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (controle != null)
          // tirar não é a ação principal: texto neutro, o âmbar fica no FECHAR
          TextButton(
              key: const ValueKey('soltar-controle'),
              style: TextButton.styleFrom(foregroundColor: context.cores.texto),
              onPressed: _soltar,
              child: Text(l.ctlRemoverControle))
        else
          const SizedBox.shrink(),
        FilledButton(key: const ValueKey('fechar-controle'), onPressed: _fechar, child: Text(l.ctlFechar)),
      ],
    );
  }

  Widget _corpo(AppLocalizations l, DocumentoPreset? documento, ControlePedaleira? controle) {
    final alvos = controle?.alvos ?? const <AlvoControle>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      if (controle != null) _campoNome(l),
      if (alvos.isEmpty)
        Text(l.ctlSemAlvos, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.cores.textoSecundario)),
      for (var i = 0; i < alvos.length; i++)
        LinhaAlvoControle(id: widget.id, indice: i, alvo: AlvoNaTela.de(ref, documento!, alvos[i])),
      const SizedBox(height: Espacos.m),
      AtribuirDoBloco(id: widget.id),
    ]);
  }

  Widget _campoNome(AppLocalizations l) {
    final motivo = _motivo;
    final longo = _campo.text.trim().length > ControlePedaleira.maiorNomeConhecido;
    return TextField(
      key: const ValueKey('campo-nome-controle'),
      controller: _campo,
      maxLength: tamanhoMaximoNome,
      decoration: InputDecoration(
        labelText: l.ctlNome,
        errorText: motivo == null ? null : l.nomeInvalido(motivo),
        helperText: longo ? l.ctlNomeLongo(ControlePedaleira.maiorNomeConhecido) : null,
      ),
      onChanged: (_) => setState(() => _motivo = null),
      onSubmitted: (_) => _aplicarNome(),
    );
  }
}
