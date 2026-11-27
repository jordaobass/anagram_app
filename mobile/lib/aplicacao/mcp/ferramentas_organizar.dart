// Organizar a pedaleira pela IA (DECISOES IA9): limpar slots e mover presets,
// como o menu do preset na lista ("Limpar", "Mover"). As duas mexem no que
// está GRAVADO e não têm volta pelo `undo`, então seguem a IA4: a IA pede, o
// app mostra a lista do que vai acontecer e só a pessoa confirma. Uma
// confirmação vale para o lote inteiro (arrumar a lista toda são dezenas de
// passos). O backup antes de cada escrita é o mesmo da tela (BK1).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/resultado.dart';
import '../estado/acoes_da_lista.dart';
import '../estado/controlador_biblioteca.dart';
import '../estado/controlador_conexao.dart';
import '../estado/controlador_organizar.dart';
import 'avisos_mcp.dart';
import 'sessao_mcp.dart';

/// Os nomes gravados de cada slot da área que a lista mostra (vazio = ausente).
Future<Map<SlotPreset, String>> _ocupados(Ref ref) async {
  final repositorio = ref.read(conexaoProvider.notifier).repositorio;
  if (repositorio == null) throw const RecusaFerramenta('The pedal is not connected.');
  final area = ref.read(bibliotecaProvider).areaSelecionada;
  return switch (await repositorio.listarSlots(area: area)) {
    Sucesso(:final valor) => {for (final r in valor) r.slot: r.nome},
    Falha(:final erro) => throw RecusaFerramenta('Listing the slots failed: ${erro.mensagem}'),
  };
}

SlotPreset _slot(Object? rotulo) {
  if (rotulo is! String) throw const RecusaFerramenta('Each slot must be a label like "03A".');
  try {
    return SlotPreset.doRotulo(rotulo);
  } on FormatException {
    throw RecusaFerramenta('"$rotulo" is not a slot; use bank 01-${SlotPreset.bancos} and A-C, like "03A".');
  }
}

/// Recusa o que a tela também não deixa: fábrica (só leitura), app ocupado, e
/// mexer no slot do preset aberto enquanto ele tem edição não salva.
void _exigirPodeOrganizar(SessaoMcp sessao, Ref ref, Iterable<SlotPreset> envolvidos) {
  exigirPedaleiraConectada(ref);
  if (ref.read(bibliotecaProvider).naFabrica) {
    throw const RecusaFerramenta('The Factory area is read-only; switch the app to one of your areas.');
  }
  final estado = sessao.estado;
  if (estado.ocupado) throw const RecusaFerramenta('The app is loading or saving a preset; try again in a moment.');
  final aberto = estado.slot;
  if (estado.naoSalvo && aberto != null && envolvidos.contains(aberto)) {
    throw RecusaFerramenta(
      '${aberto.rotulo} is open with unsaved edits. Ask the player to save (save_preset) or '
      'drop them (open_slot on another slot with discard_edits=true) first.',
    );
  }
}

/// Pergunta à pessoa e devolve a recusa para a IA quando ela não confirma.
Future<ResultadoFerramenta?> _perguntar(Ref ref, TipoOrganizar tipo, List<String> linhas) async {
  final pedido = ref.read(pedidoOrganizarProvider.notifier);
  final confirmado = await pedido.pedir(tipo, linhas, ref.read(prazoConfirmarSalvarProvider));
  if (confirmado == null) return ResultadoFerramenta.dados({'status': 'timeout'});
  if (!confirmado) return ResultadoFerramenta.dados({'status': 'declined'});
  return null;
}

class LimparSlots extends FerramentaMcp {
  const LimparSlots(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'clear_slot';

  @override
  String get descricao =>
      'Delete the presets in one or more slots of the area shown in the app, leaving them '
      'empty (like "Clear" in the preset menu). Asks the player ONCE for the whole list; nothing is deleted '
      'unless they confirm. The app backs up each preset before deleting it, but undo cannot bring it back. '
      'Returns status "confirmed" (with what was cleared), "declined" or "timeout". To close the gaps afterwards, '
      'use move_slot.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(
    {
      'slots': {
        'type': 'array',
        'items': {'type': 'string'},
        'minItems': 1,
        'description': 'Slot labels to clear, like ["15C", "14B"].',
      },
    },
    obrigatorias: const ['slots'],
  );

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final pedidos = argumentos['slots'];
    if (pedidos is! List || pedidos.isEmpty) throw const RecusaFerramenta('"slots" must list at least one slot.');
    final slots = {for (final p in pedidos) _slot(p)}.toList()..sort((a, b) => a.numero.compareTo(b.numero));
    _exigirPodeOrganizar(sessao, _ref, slots);
    final nomes = await _ocupados(_ref);
    final vazios = [
      for (final s in slots)
        if (!nomes.containsKey(s)) s.rotulo,
    ];
    if (vazios.isNotEmpty) throw RecusaFerramenta('Already empty: ${vazios.join(', ')}. Call list_slots.');

    final recusa = await _perguntar(_ref, TipoOrganizar.limpar, [for (final s in slots) '${s.rotulo}  ${nomes[s]}']);
    if (recusa != null) return recusa;
    final feitos = <String>[];
    for (final slot in slots) {
      if (await _ref.read(acoesDaListaProvider).limpar(slot) case Falha(:final erro)) {
        return ResultadoFerramenta.recusa(
          'Clearing ${slot.rotulo} failed: ${erro.mensagem}. '
          'Already cleared: ${feitos.isEmpty ? 'none' : feitos.join(', ')}.',
        );
      }
      feitos.add(slot.rotulo);
    }
    sessao.avisar('clear ${feitos.join(', ')}');
    return ResultadoFerramenta.dados({'status': 'confirmed', 'cleared': feitos});
  }
}

class MoverSlots extends FerramentaMcp {
  const MoverSlots(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'move_slot';

  @override
  String get descricao =>
      'Move presets between slots of the area shown in the app (like "Move" in the preset '
      'menu). Each move goes from "from" to "to"; if "to" holds a preset, the two SWAP places. Moves run in the '
      'order given, each on the result of the ones before, so plan the list on the current layout (list_slots). '
      'Asks the player ONCE for the whole list; nothing moves unless they confirm. Returns status "confirmed" '
      '(with the moves done), "declined" or "timeout".';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(
    {
      'moves': {
        'type': 'array',
        'minItems': 1,
        'items': {
          'type': 'object',
          'properties': {
            'from': texto('Slot of the preset to move, like "15A".'),
            'to': texto('Destination slot, like "10B".'),
          },
          'required': ['from', 'to'],
        },
        'description': 'The moves, in order.',
      },
    },
    obrigatorias: const ['moves'],
  );

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final pedidos = argumentos['moves'];
    if (pedidos is! List || pedidos.isEmpty) throw const RecusaFerramenta('"moves" must list at least one move.');
    final movimentos = [
      for (final p in pedidos)
        if (p is Map)
          (_slot(p['from']), _slot(p['to']))
        else
          throw const RecusaFerramenta('Each move needs "from" and "to".'),
    ];
    _exigirPodeOrganizar(sessao, _ref, movimentos.expand((m) => [m.$1, m.$2]));

    // simula a lista para a pergunta mostrar o nome certo em cada passo
    final nomes = await _ocupados(_ref);
    final linhas = <String>[];
    for (final (de, para) in movimentos) {
      final nome = nomes[de];
      if (nome == null) throw RecusaFerramenta('${de.rotulo} is empty at that point of the list; nothing to move.');
      final ocupante = nomes[para];
      linhas.add('${de.rotulo} → ${para.rotulo}  $nome${ocupante == null || de == para ? '' : '  ⇄  $ocupante'}');
      nomes.remove(de);
      if (ocupante != null) nomes[de] = ocupante;
      nomes[para] = nome;
    }

    final recusa = await _perguntar(_ref, TipoOrganizar.mover, linhas);
    if (recusa != null) return recusa;
    final organizar = _ref.read(organizarProvider.notifier);
    final feitos = <String>[];
    for (final (de, para) in movimentos) {
      organizar.iniciar(OperacaoPreset.mover, de);
      if (await organizar.concluir(para, confirmado: true) case FalhaAoOrganizar(:final erro)) {
        return ResultadoFerramenta.recusa(
          'Moving ${de.rotulo} to ${para.rotulo} failed: ${erro.mensagem}. '
          'Already done: ${feitos.isEmpty ? 'none' : feitos.join(', ')}.',
        );
      }
      feitos.add('${de.rotulo}→${para.rotulo}');
    }
    sessao.avisar('move ${feitos.join(', ')}');
    return ResultadoFerramenta.dados({'status': 'confirmed', 'moved': feitos});
  }
}
