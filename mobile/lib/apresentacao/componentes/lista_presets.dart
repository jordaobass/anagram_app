// Presets por banco (01A … 42C). Tocar abre e faz tocar na pedaleira;
// com edição não salva, pergunta antes de largar — também no slot já aberto,
// porque abrir de novo relê da pedaleira por cima das edições. Botão direito,
// toque longo ou o ⋮ de um preset abrem mover, clonar e trocar de banco.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/controlador_organizar.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../textos.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import 'faixa_escolher_destino.dart';
import 'faixas_lista.dart';
import 'fluxo_salvar.dart';
import 'menu_preset.dart';
import 'seletor_area.dart';
import '../../l10n/app_localizations.dart';

class ListaPresets extends ConsumerWidget {
  const ListaPresets({super.key, this.aoAbrir});

  /// Chamado depois de abrir (no celular, volta para o editor).
  final VoidCallback? aoAbrir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biblioteca = ref.watch(bibliotecaProvider);
    final escolhendo = ref.watch(editorProvider.select((e) => e.escolhendoDestino));
    final organizando = ref.watch(organizarProvider);
    // o seletor de área fica à vista também enquanto a lista da área carrega
    final carregandoLista = biblioteca.carregando && biblioteca.ocupados.isEmpty;
    return Column(children: [
      if (escolhendo) const FaixaEscolherDestino(),
      if (organizando != null) FaixaOrganizar(organizando),
      const SeletorArea(),
      // falhas da lista (listar, tornar a área ativa) não podem ficar mudas:
      // a lista vazia pareceria uma área sem presets
      if (biblioteca.erro case final erro?) FaixaErroLista(AppLocalizations.of(context).aviso(erro)),
      Expanded(child: carregandoLista ? const Center(child: CircularProgressIndicator()) : _lista(context, ref)),
    ]);
  }

  Widget _lista(BuildContext context, WidgetRef ref) {
    final biblioteca = ref.watch(bibliotecaProvider);
    final escolhendo = ref.watch(editorProvider.select((e) => e.escolhendoDestino));
    final naPedaleira = ref.watch(editorProvider.select((e) => e.slotNaPedaleira ? e.slot : null));
    // a marca de "pedaleira aqui" usa a cor do LED da barra (azul na demonstração)
    final demonstracao = ref.watch(conexaoProvider.select((c) => c is Conectada && c.demonstracao));
    // gravando: o resultado da gravação ainda vai escrever o slot salvo
    final salvando = ref.watch(editorProvider.select((e) => e.salvando));
    final semMenu = salvando || escolhendo || ref.watch(organizarProvider) != null;
    final aberto = ref.watch(editorProvider.select((e) => e.slot));
    return ListView.builder(
      key: const ValueKey('lista-presets'),
      itemCount: SlotPreset.bancos,
      itemBuilder: (context, indice) => _Banco(
        banco: indice + 1,
        biblioteca: biblioteca,
        aberto: aberto,
        escolhendo: escolhendo,
        naPedaleira: naPedaleira,
        corLed: demonstracao ? context.cores.ledDemonstracao : context.cores.ledLigado,
        aoEscolher: salvando ? null : (slot) => _abrir(context, ref, slot),
        // o menu só existe fora de outra escolha de destino (salvar ou organizar)
        aoMenu: semMenu ? null : (slot, onde) => abrirMenuPreset(context, ref, slot, onde),
      ),
    );
  }

  /// Toda espera pode terminar com a lista já fechada (o "voltar" do celular
  /// durante a leitura): depois dela, nada de ref nem de voltar de novo.
  Future<void> _abrir(BuildContext context, WidgetRef ref, SlotPreset slot) async {
    if (ref.read(organizarProvider) != null) return concluirOrganizacao(context, ref, slot);
    final estado = ref.read(editorProvider);
    if (estado.escolhendoDestino) {
      final gravou = await salvarComoNoDestino(context, ref, slot);
      if (gravou && context.mounted) aoAbrir?.call();
      return;
    }
    if (estado.naoSalvo && !await confirmarLargarEdicoes(context, estado.atual?.nome ?? '')) return;
    if (!context.mounted) return;
    await ref.read(editorProvider.notifier).abrirSlot(slot);
    if (context.mounted) aoAbrir?.call();
  }
}

class _Banco extends StatelessWidget {
  const _Banco({
    required this.banco,
    required this.biblioteca,
    required this.aberto,
    required this.escolhendo,
    required this.naPedaleira,
    required this.corLed,
    required this.aoEscolher,
    required this.aoMenu,
  });

  final Color corLed;

  final bool escolhendo;

  /// Slot em que a pedaleira está (Program Change confirmado), se houver.
  final SlotPreset? naPedaleira;

  final int banco;
  final EstadoBiblioteca biblioteca;
  final SlotPreset? aberto;

  /// `null` enquanto grava: a lista fica visível, mas não abre nem escolhe.
  final void Function(SlotPreset)? aoEscolher;

  /// Menu de mover/clonar/trocar banco de um preset, na posição tocada.
  final void Function(SlotPreset, Offset)? aoMenu;

  @override
  Widget build(BuildContext context) {
    final inicio = (banco - 1) * SlotPreset.porBanco + 1;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.cores.filete))),
      child: Column(children: [
        for (var n = inicio; n < inicio + SlotPreset.porBanco; n++) _linha(context, SlotPreset(n)),
      ]),
    );
  }

  /// Modo destino: "ORIGEM" no slot aberto; nos outros, gravar (vazio) ou
  /// substituir (ocupado). Fora dele: onde a pedaleira está.
  Widget? _marca(AppLocalizations l, TextTheme tema, Paleta cores, SlotPreset slot) {
    if (escolhendo) {
      if (slot == aberto) return Text(l.origem, style: tema.labelSmall?.copyWith(color: cores.tallyTinta));
      return biblioteca.resumo(slot) == null
          ? Icon(Icons.save_alt, color: cores.aluminio, semanticLabel: l.gravarAqui)
          : Icon(Icons.find_replace, color: cores.aluminioClaro, semanticLabel: l.sbSubstituirAqui);
    }
    // slot vazio (preset novo ainda não gravado) não tem o que tocar
    if (slot != naPedaleira || biblioteca.resumo(slot) == null) return null;
    return Icon(Icons.graphic_eq, key: const ValueKey('na-pedaleira'), color: corLed, semanticLabel: l.pedaleiraNesteSlot);
  }

  Widget _linha(BuildContext context, SlotPreset slot) {
    final ativo = slot == aberto;
    final escolher = aoEscolher;
    return Material(
      color: ativo ? context.cores.painelElevado : Colors.transparent,
      child: InkWell(
        key: ValueKey('slot-${slot.rotulo}'),
        onTap: escolher == null ? null : () => escolher(slot),
        onSecondaryTapDown: _menuEm(slot, (d) => d.globalPosition),
        onLongPress: aoMenu == null || biblioteca.resumo(slot) == null ? null : () => _menuNoCentro(context, slot),
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.m),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: ativo ? context.cores.tallyTinta : Colors.transparent, width: Medidas.contornoSelecao)),
          ),
          child: _conteudo(AppLocalizations.of(context), Theme.of(context).textTheme, context.cores, slot, ativo: ativo),
        ),
      ),
    );
  }

  Widget _conteudo(AppLocalizations l, TextTheme tema, Paleta cores, SlotPreset slot, {required bool ativo}) {
    final resumo = biblioteca.resumo(slot);
    return Row(children: [
      SizedBox(
        width: Espacos.xxxl,
        child: Text(slot.rotulo, style: tema.titleSmall?.copyWith(color: ativo ? cores.tallyTinta : cores.aluminioClaro)),
      ),
      Expanded(child: _nome(l, tema, slot, resumo?.nome)),
      ?_marca(l, tema, cores, slot),
      if (aoMenu != null && resumo != null) _botaoMenu(l, slot),
    ]);
  }

  /// O nome, "vazio" ou, escolhendo o destino do "Salvar como", o que o
  /// toque vai substituir (o slot aberto continua com o nome: é a origem).
  Widget _nome(AppLocalizations l, TextTheme tema, SlotPreset slot, String? nome) {
    final substitui = escolhendo && nome != null && slot != aberto;
    final texto = nome == null ? l.slotVazio : (substitui ? l.sbSubstitui(nome) : nome);
    return Text(texto,
        maxLines: 1, overflow: TextOverflow.ellipsis, style: nome == null || substitui ? tema.bodySmall : tema.bodyLarge);
  }

  /// O menu só vale para slot com preset; o vazio não tem o que mover.
  void Function(TapDownDetails)? _menuEm(SlotPreset slot, Offset Function(TapDownDetails) onde) {
    final menu = aoMenu;
    if (menu == null || biblioteca.resumo(slot) == null) return null;
    return (detalhes) => menu(slot, onde(detalhes));
  }

  void _menuNoCentro(BuildContext context, SlotPreset slot) {
    final caixa = context.findRenderObject() as RenderBox?;
    aoMenu?.call(slot, caixa == null ? Offset.zero : caixa.localToGlobal(caixa.size.center(Offset.zero)));
  }

  Widget _botaoMenu(AppLocalizations l, SlotPreset slot) => Builder(
        builder: (contexto) => IconButton(
          key: ValueKey('menu-preset-${slot.rotulo}'),
          tooltip: l.opAcoesPreset,
          icon: Icon(Icons.more_vert, color: contexto.cores.textoSecundario),
          onPressed: () => _menuNoCentro(contexto, slot),
        ),
      );
}
