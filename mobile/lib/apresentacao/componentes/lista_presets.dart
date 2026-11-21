// Presets por banco (01A … 42C). Tocar abre e faz tocar na pedaleira;
// com edição não salva, pergunta antes de largar — também no slot já aberto,
// porque abrir de novo relê da pedaleira por cima das edições.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../textos.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import 'faixa_escolher_destino.dart';
import 'fluxo_salvar.dart';
import 'seletor_area.dart';
import '../../l10n/app_localizations.dart';

class ListaPresets extends ConsumerWidget {
  const ListaPresets({super.key, this.aoAbrir});

  /// Chamado depois de abrir (no celular, volta para o editor).
  final VoidCallback? aoAbrir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biblioteca = ref.watch(bibliotecaProvider);
    final aberto = ref.watch(editorProvider.select((e) => e.slot));
    final escolhendo = ref.watch(editorProvider.select((e) => e.escolhendoDestino));
    final naPedaleira = ref.watch(editorProvider.select((e) => e.slotNaPedaleira ? e.slot : null));
    // gravando: o resultado da gravação ainda vai escrever o slot salvo
    final salvando = ref.watch(editorProvider.select((e) => e.salvando));
    final lista = ListView.builder(
      key: const ValueKey('lista-presets'),
      itemCount: SlotPreset.bancos,
      itemBuilder: (context, indice) => _Banco(
        banco: indice + 1,
        biblioteca: biblioteca,
        aberto: aberto,
        escolhendo: escolhendo,
        naPedaleira: naPedaleira,
        aoEscolher: salvando ? null : (slot) => _abrir(context, ref, slot),
      ),
    );
    // o seletor de área fica à vista também enquanto a lista da área carrega
    final carregandoLista = biblioteca.carregando && biblioteca.ocupados.isEmpty;
    return Column(children: [
      if (escolhendo) const FaixaEscolherDestino(),
      const SeletorArea(),
      // falhas da lista (listar, tornar a área ativa) não podem ficar mudas:
      // a lista vazia pareceria uma área sem presets
      if (biblioteca.erro case final erro?) _FaixaErro(AppLocalizations.of(context).aviso(erro)),
      Expanded(child: carregandoLista ? const Center(child: CircularProgressIndicator()) : lista),
    ]);
  }

  Future<void> _abrir(BuildContext context, WidgetRef ref, SlotPreset slot) async {
    final estado = ref.read(editorProvider);
    if (estado.escolhendoDestino) {
      final gravou = await salvarComoNoDestino(context, ref, slot);
      if (gravou) aoAbrir?.call();
      return;
    }
    if (estado.naoSalvo) {
      final largar = await _confirmarDescarte(context, estado.atual?.nome ?? '');
      if (!largar) return;
    }
    await ref.read(editorProvider.notifier).abrirSlot(slot);
    aoAbrir?.call();
  }

  Future<bool> _confirmarDescarte(BuildContext context, String nome) {
    final l = AppLocalizations.of(context);
    return confirmar(
      context,
      titulo: l.largarEdicoesTitulo,
      texto: l.largarEdicoesTexto(nome),
      rotuloCancelar: l.continuarEditando,
      rotuloConfirmar: l.largar,
    );
  }
}

class _FaixaErro extends StatelessWidget {
  const _FaixaErro(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('erro-lista'),
        width: double.infinity,
        color: Cores.painelElevado,
        padding: const EdgeInsets.symmetric(horizontal: Espacos.m, vertical: Espacos.s),
        child: Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.erro)),
      );
}

class _Banco extends StatelessWidget {
  const _Banco({
    required this.banco,
    required this.biblioteca,
    required this.aberto,
    required this.escolhendo,
    required this.naPedaleira,
    required this.aoEscolher,
  });

  final bool escolhendo;

  /// Slot em que a pedaleira está (Program Change confirmado), se houver.
  final SlotPreset? naPedaleira;

  final int banco;
  final EstadoBiblioteca biblioteca;
  final SlotPreset? aberto;

  /// `null` enquanto grava: a lista fica visível, mas não abre nem escolhe.
  final void Function(SlotPreset)? aoEscolher;

  @override
  Widget build(BuildContext context) {
    final inicio = (banco - 1) * SlotPreset.porBanco + 1;
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Cores.filete))),
      child: Column(children: [
        for (var n = inicio; n < inicio + SlotPreset.porBanco; n++) _linha(context, SlotPreset(n)),
      ]),
    );
  }

  /// Modo destino: "ORIGEM" no slot aberto, ícone de gravar nos outros.
  /// Fora dele: onde a pedaleira está.
  Widget? _marca(AppLocalizations l, TextTheme tema, SlotPreset slot) {
    if (escolhendo) {
      return slot == aberto
          ? Text(l.origem, style: tema.labelSmall?.copyWith(color: Cores.tally))
          : Icon(Icons.save_alt, color: Cores.aluminio, semanticLabel: l.gravarAqui);
    }
    if (slot != naPedaleira) return null;
    return Icon(Icons.graphic_eq,
        key: const ValueKey('na-pedaleira'), color: Cores.ledLigado, semanticLabel: l.pedaleiraNesteSlot);
  }

  Widget _linha(BuildContext context, SlotPreset slot) {
    final ativo = slot == aberto;
    final escolher = aoEscolher;
    return Material(
      color: ativo ? Cores.painelElevado : Colors.transparent,
      child: InkWell(
        key: ValueKey('slot-${slot.rotulo}'),
        onTap: escolher == null ? null : () => escolher(slot),
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: ativo ? Cores.tally : Colors.transparent, width: Medidas.contornoSelecao)),
          ),
          child: _conteudo(AppLocalizations.of(context), Theme.of(context).textTheme, slot, ativo: ativo),
        ),
      ),
    );
  }

  Widget _conteudo(AppLocalizations l, TextTheme tema, SlotPreset slot, {required bool ativo}) {
    final resumo = biblioteca.resumo(slot);
    return Row(children: [
      SizedBox(
        width: Espacos.xxxl,
        child: Text(slot.rotulo, style: tema.titleSmall?.copyWith(color: ativo ? Cores.tally : Cores.aluminioClaro)),
      ),
      Expanded(
        child: Text(resumo?.nome ?? l.slotVazio,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: resumo == null ? tema.bodySmall : tema.bodyLarge),
      ),
      ?_marca(l, tema, slot),
    ]);
  }
}
