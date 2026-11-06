// Presets por banco (01A … 42C). Tocar abre e faz tocar na pedaleira;
// com edição não salva, pergunta antes de largar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import 'faixa_escolher_destino.dart';
import 'fluxo_salvar.dart';

class ListaPresets extends ConsumerWidget {
  const ListaPresets({super.key, this.aoAbrir});

  /// Chamado depois de abrir (no celular, volta para o editor).
  final VoidCallback? aoAbrir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biblioteca = ref.watch(bibliotecaProvider);
    final aberto = ref.watch(editorProvider.select((e) => e.slot));
    if (biblioteca.carregando && biblioteca.ocupados.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final escolhendo = ref.watch(editorProvider.select((e) => e.escolhendoDestino));
    final naPedaleira = ref.watch(editorProvider.select((e) => e.slotNaPedaleira ? e.slot : null));
    final lista = ListView.builder(
      key: const ValueKey('lista-presets'),
      itemCount: SlotPreset.bancos,
      itemBuilder: (context, indice) => _Banco(
        banco: indice + 1,
        biblioteca: biblioteca,
        aberto: aberto,
        escolhendo: escolhendo,
        naPedaleira: naPedaleira,
        aoEscolher: (slot) => _abrir(context, ref, slot),
      ),
    );
    if (!escolhendo) return lista;
    return Column(children: [const FaixaEscolherDestino(), Expanded(child: lista)]);
  }

  Future<void> _abrir(BuildContext context, WidgetRef ref, SlotPreset slot) async {
    final estado = ref.read(editorProvider);
    if (estado.escolhendoDestino) {
      final gravou = await salvarComoNoDestino(context, ref, slot);
      if (gravou) aoAbrir?.call();
      return;
    }
    if (estado.naoSalvo && estado.slot != slot) {
      final largar = await _confirmarDescarte(context, estado.atual?.nome ?? '');
      if (!largar) return;
    }
    await ref.read(editorProvider.notifier).abrirSlot(slot);
    aoAbrir?.call();
  }

  Future<bool> _confirmarDescarte(BuildContext context, String nome) => confirmar(
        context,
        titulo: 'Largar edições?',
        texto: '"$nome" tem mudanças que não foram salvas no slot.',
        rotuloCancelar: 'CONTINUAR EDITANDO',
        rotuloConfirmar: 'LARGAR',
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
  final void Function(SlotPreset) aoEscolher;

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
  Widget? _marca(TextTheme tema, SlotPreset slot) {
    if (escolhendo) {
      return slot == aberto
          ? Text('ORIGEM', style: tema.labelSmall?.copyWith(color: Cores.tally))
          : const Icon(Icons.save_alt, color: Cores.aluminio, semanticLabel: 'Gravar aqui');
    }
    if (slot != naPedaleira) return null;
    return const Icon(Icons.graphic_eq,
        key: ValueKey('na-pedaleira'), color: Cores.ledLigado, semanticLabel: 'A pedaleira está neste slot');
  }

  Widget _linha(BuildContext context, SlotPreset slot) {
    final tema = Theme.of(context).textTheme;
    final resumo = biblioteca.resumo(slot);
    final ativo = slot == aberto;
    return Material(
      color: ativo ? Cores.painelElevado : Colors.transparent,
      child: InkWell(
        key: ValueKey('slot-${slot.rotulo}'),
        onTap: () => aoEscolher(slot),
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: ativo ? Cores.tally : Colors.transparent, width: Medidas.contornoSelecao)),
          ),
          child: Row(children: [
            SizedBox(
              width: Espacos.xxxl,
              child: Text(slot.rotulo, style: tema.titleSmall?.copyWith(color: ativo ? Cores.tally : Cores.aluminioClaro)),
            ),
            Expanded(
              child: Text(resumo?.nome ?? 'vazio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: resumo == null ? tema.bodySmall : tema.bodyLarge),
            ),
            ?_marca(tema, slot),
          ]),
        ),
      ),
    );
  }
}
