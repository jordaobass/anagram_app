// Lista do modo Biblioteca (DECISOES BB1): presets prontos agrupados por
// banda. Tocar abre o preset sem slot e o faz soar (temporário, como um
// importado); "Aplicar num slot…" abre o mesmo e põe a lista da pedaleira em
// modo "escolher destino" — o "Salvar como" de sempre, que pergunta antes de
// substituir um slot ocupado e dá uuid novo ao preset gravado. O menu do
// cabeçalho importa uma coleção e exporta a biblioteca (BB2); a lista vem
// em coleções que se recolhem, com busca e ordem por cima (BB3).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/estado/estado_editor.dart';
import '../../aplicacao/estado/modo_biblioteca.dart';
import '../../aplicacao/estado/biblioteca_presets.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/biblioteca_bandas.dart';
import '../tema/tokens.dart';
import 'dialogo_confirmar.dart';
import 'barra_busca_biblioteca.dart';
import 'fluxo_salvar.dart';
import 'menu_biblioteca.dart';

class ListaBiblioteca extends ConsumerWidget {
  const ListaBiblioteca({super.key, this.aoAbrir});

  /// Chamado depois de abrir um preset (no celular, volta para o editor).
  final VoidCallback? aoAbrir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final biblioteca = ref.watch(bibliotecaBandasProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Cabecalho(l),
        const BarraBuscaBiblioteca(),
        Expanded(
          // relendo a pasta, a lista de antes fica à vista em vez do indicador
          child: switch (biblioteca) {
            AsyncValue(value: final value?) when value.vazia => _Vazia(l.bbVazia),
            AsyncValue(value: final value?) => _colecoes(context, ref, value),
            AsyncError() => _Vazia(l.bbVazia),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }

  Widget _colecoes(BuildContext context, WidgetRef ref, BibliotecaBandas biblioteca) {
    final l = AppLocalizations.of(context);
    final estado = ref.watch(editorProvider);
    final filtro = ref.watch(filtroBibliotecaProvider);
    final aberto = _abertoDaBiblioteca(estado, biblioteca);
    final visivel = biblioteca.filtrada(busca: filtro.busca, ordem: filtro.ordem);
    if (visivel.vazia) return _Vazia(l.bbSemResultados(filtro.busca.trim()));
    return ListView(
      key: const ValueKey('lista-biblioteca'),
      children: [
        for (final colecao in visivel.colecoes) ...[
          _TituloColecao(
            colecao: colecao,
            total: biblioteca.colecoes.firstWhere((c) => c.nome == colecao.nome).quantidadePresets,
            recolhida: filtro.recolhida(colecao.nome),
          ),
          if (!filtro.recolhida(colecao.nome))
            for (final banda in colecao.bandas) ...[
              if (banda.nome.isNotEmpty) _TituloBanda(colecao.nome, banda.nome),
              for (final preset in banda.presets)
                _LinhaPreset(
                  preset: preset,
                  ativo:
                      preset.documento.assinaturaSemCena == aberto?.documento.assinaturaSemCena &&
                      preset.colecao == aberto?.colecao,
                  aoTocar: estado.salvando ? null : () => _abrir(context, ref, biblioteca, preset),
                  aoAplicar: estado.salvando ? null : () => _aplicar(context, ref, biblioteca, preset),
                ),
            ],
        ],
      ],
    );
  }

  /// O preset da biblioteca que está aberto, sem slot e sem edição.
  static PresetDaBiblioteca? _abertoDaBiblioteca(EstadoEditor estado, BibliotecaBandas biblioteca) {
    final atual = estado.atual;
    if (estado.slot != null || atual == null) return null;
    for (final preset in biblioteca.presets) {
      if (preset.documento.assinaturaSemCena == atual.assinaturaSemCena) return preset;
    }
    return null;
  }

  /// Só pergunta se há edição de verdade: um preset da biblioteca aberto e
  /// intocado não tem o que perder.
  Future<bool> _abrirNoEditor(
    BuildContext context,
    WidgetRef ref,
    BibliotecaBandas biblioteca,
    PresetDaBiblioteca preset,
  ) async {
    final estado = ref.read(editorProvider);
    final intocado = _abertoDaBiblioteca(estado, biblioteca) != null;
    if (estado.naoSalvo && !intocado && !await confirmarLargarEdicoes(context, estado.atual?.nome ?? '')) return false;
    if (!context.mounted) return false;
    await ref.read(editorProvider.notifier).abrirSemSlot(preset.documento);
    return context.mounted;
  }

  Future<void> _abrir(
    BuildContext context,
    WidgetRef ref,
    BibliotecaBandas biblioteca,
    PresetDaBiblioteca preset,
  ) async {
    if (await _abrirNoEditor(context, ref, biblioteca, preset) && context.mounted) aoAbrir?.call();
  }

  /// A escolha de destino desliga o modo Biblioteca: a lista volta a ser a da
  /// pedaleira, com a faixa "escolha o destino" por cima.
  Future<void> _aplicar(
    BuildContext context,
    WidgetRef ref,
    BibliotecaBandas biblioteca,
    PresetDaBiblioteca preset,
  ) async {
    if (!await _abrirNoEditor(context, ref, biblioteca, preset) || !context.mounted) return;
    abrirEscolhaDeDestino(context, ref);
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.l);

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('cabecalho-biblioteca'),
      padding: const EdgeInsets.fromLTRB(Espacos.m, Espacos.xs, Espacos.xs, Espacos.s),
      decoration: BoxDecoration(
        color: context.cores.painelElevado,
        border: Border(bottom: BorderSide(color: context.cores.filete)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // o título divide a linha com o menu do arquivo da biblioteca (BB2)
          Row(
            children: [
              Expanded(
                child: Text(l.bbTitulo, style: tema.labelLarge?.copyWith(color: context.cores.tallyTinta)),
              ),
              const MenuBiblioteca(),
            ],
          ),
          const SizedBox(height: Espacos.xs),
          Padding(
            padding: const EdgeInsets.only(right: Espacos.s),
            child: Text(l.bbTexto, style: tema.bodySmall?.copyWith(color: context.cores.textoSecundario)),
          ),
        ],
      ),
    );
  }
}

/// Coleção: toque recolhe ou abre; ao lado, quantos presets ela tem e o
/// menu dela (exportar; apagar, se importada).
class _TituloColecao extends ConsumerWidget {
  const _TituloColecao({required this.colecao, required this.total, required this.recolhida});

  final ColecaoDaBiblioteca colecao;

  /// Os presets da coleção inteira, não só os que a busca achou.
  final int total;
  final bool recolhida;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    final nome = colecao.embutida ? l.bbColecaoEmbutida : colecao.nome;
    return Material(
      color: context.cores.painel,
      child: InkWell(
        key: ValueKey('colecao-${colecao.nome}'),
        onTap: () => ref.read(filtroBibliotecaProvider.notifier).alternarColecao(colecao.nome),
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.only(left: Espacos.s),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.cores.filete)),
          ),
          child: Row(
            children: [
              Icon(recolhida ? Icons.chevron_right : Icons.expand_more, color: context.cores.textoSecundario),
              const SizedBox(width: Espacos.xs),
              Expanded(
                child: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.titleSmall?.copyWith(color: context.cores.texto),
                ),
              ),
              Text('$total', style: tema.labelMedium?.copyWith(color: context.cores.textoSecundario)),
              MenuColecao(nome: colecao.nome, embutida: colecao.embutida),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloBanda extends StatelessWidget {
  const _TituloBanda(this.colecao, this.nome);

  final String colecao;
  final String nome;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(Espacos.l, Espacos.m, Espacos.m, Espacos.xs),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: context.cores.filete)),
    ),
    child: Text(
      nome.toUpperCase(),
      key: ValueKey('banda-$colecao-$nome'),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.cores.aluminioClaro),
    ),
  );
}

class _LinhaPreset extends StatelessWidget {
  const _LinhaPreset({required this.preset, required this.ativo, required this.aoTocar, required this.aoAplicar});

  final PresetDaBiblioteca preset;
  final bool ativo;
  final VoidCallback? aoTocar;
  final VoidCallback? aoAplicar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context).textTheme;
    return Material(
      color: ativo ? context.cores.painelElevado : Colors.transparent,
      child: InkWell(
        key: ValueKey('biblioteca-${preset.colecao}-${preset.nome}'),
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: Medidas.alvoMinimo),
          padding: const EdgeInsets.only(left: Espacos.m),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: ativo ? context.cores.tallyTinta : Colors.transparent,
                width: Medidas.contornoSelecao,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  preset.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.bodyLarge?.copyWith(fontWeight: Tipos.nomeNaLista),
                ),
              ),
              IconButton(
                key: ValueKey('aplicar-${preset.colecao}-${preset.nome}'),
                tooltip: l.bbAplicar,
                icon: Icon(Icons.save_alt, color: context.cores.aluminioClaro),
                onPressed: aoAplicar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vazia extends StatelessWidget {
  const _Vazia(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Espacos.l),
    child: Text(texto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
  );
}
