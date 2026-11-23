// "Restaurar de um backup…" (DECISOES BK6): a lista dos backups por dia, do
// mais novo para o mais velho, cada um com "Abrir no editor". Os de um backup
// completo ficam juntos num grupo que abre. Abrir põe o preset no editor sem
// slot (como o importar) e volta ao editor: para gravar, Salvar como.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/casos_de_uso/transferir_preset.dart';
import '../../aplicacao/copias/restaurar_copia.dart';
import '../../aplicacao/estado/controlador_biblioteca.dart';
import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/modelo/areas_presets.dart';
import '../../nucleo/modelo/copia_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'dialogo_confirmar.dart';

Future<void> abrirListaDeCopias(BuildContext context, WidgetRef ref) async {
  final escolhida = await showDialog<CopiaGuardada>(context: context, builder: (_) => const _DialogoCopias());
  if (escolhida == null || !context.mounted) return;
  final editor = ref.read(editorProvider);
  if (editor.naoSalvo && !await confirmarLargarEdicoes(context, editor.atual?.nome ?? '')) return;
  if (!context.mounted) return;
  final l = AppLocalizations.of(context);
  final mensageiro = ScaffoldMessenger.of(context);
  final navegador = Navigator.of(context);
  final resultado = await ref.read(restaurarCopiaProvider).abrir(escolhida);
  final texto = switch (resultado) {
    PresetImportado(:final documento) => l.bkAbertoNoEditor(documento.nome),
    final ImportacaoRecusada recusa => l.importacaoRecusada(recusa),
    ImportacaoCancelada() => null,
  };
  if (texto != null) mensageiro.showSnackBar(SnackBar(content: Text(texto)));
  // aberto, a pessoa quer ouvir: volta ao editor
  if (resultado is PresetImportado) await navegador.maybePop();
}

class _DialogoCopias extends ConsumerWidget {
  const _DialogoCopias();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final copias = ref.watch(copiasGuardadasProvider);
    return AlertDialog(
      key: const ValueKey('dialogo-backups'),
      constraints: const BoxConstraints(maxWidth: Medidas.larguraDialogo),
      title: Text(l.bkRestaurarTitulo),
      content: SizedBox(
        width: Medidas.larguraDialogo,
        height: Medidas.alturaListaOpcoes,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.bkRestaurarTexto, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: Espacos.m),
          Expanded(
            child: switch (copias) {
              AsyncData(:final value) when value.isEmpty => Text(l.bkNenhum),
              AsyncData(:final value) => _Lista(value),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ]),
      ),
      actions: [BotaoCancelarDialogo(rotulo: l.bkFechar, aoTocar: () => Navigator.pop(context))],
    );
  }
}

/// Um dia por cabeçalho; os automáticos um por linha, cada backup completo num grupo.
class _Lista extends StatelessWidget {
  const _Lista(this.copias);

  final List<CopiaGuardada> copias;

  @override
  Widget build(BuildContext context) {
    final itens = <Widget>[];
    for (final MapEntry(key: dia, value: doDia) in _porDia().entries) {
      itens.add(_CabecalhoDia(dia));
      for (final grupo in _porLote(doDia)) {
        itens.add(grupo.first.completa == null ? _LinhaCopia(grupo.single) : _GrupoCompleto(grupo));
      }
    }
    return ListView(key: const ValueKey('lista-backups'), children: itens);
  }

  /// A lista já vem do mais novo para o mais velho; o mapa guarda essa ordem.
  Map<String, List<CopiaGuardada>> _porDia() {
    final dias = <String, List<CopiaGuardada>>{};
    for (final copia in copias) {
      dias.putIfAbsent(pastaDoDia(copia.quando), () => []).add(copia);
    }
    return dias;
  }

  /// Cada automático sozinho; os de um mesmo backup completo juntos.
  static Iterable<List<CopiaGuardada>> _porLote(List<CopiaGuardada> doDia) {
    final grupos = <String, List<CopiaGuardada>>{};
    for (final copia in doDia) {
      grupos.putIfAbsent(copia.completa ?? copia.caminho, () => []).add(copia);
    }
    return grupos.values;
  }
}

class _CabecalhoDia extends StatelessWidget {
  const _CabecalhoDia(this.dia);

  final String dia;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Espacos.m, bottom: Espacos.xs),
        child: Text(dia, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.cores.aluminioClaro)),
      );
}

class _GrupoCompleto extends StatelessWidget {
  const _GrupoCompleto(this.copias);

  /// Os presets de um mesmo backup completo.
  final List<CopiaGuardada> copias;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ExpansionTile(
      key: ValueKey('backup-completo-${copias.first.completa}'),
      tilePadding: EdgeInsets.zero,
      // o âmbar é de seleção e ação (DESIGN.md): abrir o grupo não é nenhum dos dois
      iconColor: context.cores.aluminioClaro,
      collapsedIconColor: context.cores.aluminioClaro,
      leading: Icon(Icons.inventory_2_outlined, color: context.cores.aluminioClaro),
      title: Text(l.bkCompletoGrupo(_hora(copias.first.quando), copias.length)),
      children: [for (final copia in copias) _LinhaCopia(copia, comHora: false)],
    );
  }
}

class _LinhaCopia extends ConsumerWidget {
  const _LinhaCopia(this.copia, {this.comHora = true});

  final CopiaGuardada copia;
  final bool comHora;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final origem = copia.origem;
    final area = _nomeDaArea(l, ref.watch(bibliotecaProvider.select((b) => b.areas)), origem.area);
    return ListTile(
      key: ValueKey('backup-${copia.caminho}'),
      contentPadding: EdgeInsets.zero,
      title: Text('${origem.slot.rotulo} · ${origem.nome}', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(comHora ? '${_hora(copia.quando)} · $area' : area,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      trailing: TextButton(
        key: ValueKey('abrir-backup-${copia.caminho}'),
        style: TextButton.styleFrom(foregroundColor: context.cores.texto),
        onPressed: () => Navigator.pop(context, copia),
        child: Text(l.bkAbrirNoEditor),
      ),
    );
  }
}

/// O nome que a área tem hoje na pedaleira; sem ele, "Área N" pelo id.
String _nomeDaArea(AppLocalizations l, AreasDaPedaleira areas, String? id) {
  if (id == null) return l.bkAreaUnica;
  return l.nomeDaArea(areas.area(id) ?? AreaPresets(id, ''));
}

String _hora(DateTime quando) =>
    '${doisDigitos(quando.hour)}:${doisDigitos(quando.minute)}:${doisDigitos(quando.second)}';
