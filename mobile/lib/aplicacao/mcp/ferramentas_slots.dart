// Ferramentas do preset como um todo e dos slots: renomear, listar, ler sem
// abrir e abrir. Abrir é o mesmo `abrirSlot` da lista de presets e, como lá,
// nunca descarta edição sem que isso seja pedido (a tela pergunta "descartar
// edições?"; a IA precisa dizer `discard_edits`). Gravar continua só no
// `save_preset`, com a pessoa.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../../nucleo/modelo/documento_preset.dart';
import '../../nucleo/modelo/presets_fabrica.dart';
import '../../nucleo/modelo/slot_preset.dart';
import '../../nucleo/resultado.dart';
import '../avisos.dart';
import '../estado/controlador_biblioteca.dart';
import '../estado/controlador_conexao.dart';
import '../provedores.dart';
import 'descricao_preset.dart';
import 'ferramentas_controles.dart';
import 'sessao_mcp.dart';

class Renomear extends FerramentaMcp {
  const Renomear(this.sessao);
  final SessaoMcp sessao;

  @override
  String get nome => 'rename';

  @override
  String get descricao => 'Rename the open preset or, with "control", the short display name of an assigned '
      'hardware control (foot1-foot3, pot1-pot6, exp). Up to $tamanhoMaximoNome characters; shown immediately, '
      'saved only with save_preset. Scene names cannot be changed by the app.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'name': texto('The new name.'),
        'control': {...esquemaControle(), 'description': 'Optional: rename this control instead of the preset.'},
      }, obrigatorias: const ['name']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final nome = nomeValido(argumentos.textoObrigatorio('name'));
    final documento = sessao.presetAberto();
    if (argumentos['control'] == null) {
      await sessao.mudar('name: $nome', () => sessao.editor.renomear(nome));
      return ResultadoFerramenta.dados({'preset': sessao.presetAberto().nome});
    }
    final id = controlePedido(argumentos);
    if (documento.controles[id] == null) {
      throw RecusaFerramenta('${nomeDoControle(id)} is free; assign it with assign_control first.');
    }
    await sessao.mudar('${nomeDoControle(id).toUpperCase()}: $nome', () => sessao.editor.renomearControle(id, nome));
    return ResultadoFerramenta.dados(descreverControle(sessao, sessao.presetAberto(), id));
  }
}

/// O slot e a área dos argumentos; sem área, a que a lista de presets mostra.
(SlotPreset, String?) _slotEArea(Ref ref, Map<String, dynamic> argumentos) {
  exigirPedaleiraConectada(ref);
  final rotulo = argumentos.textoObrigatorio('slot');
  final SlotPreset slot;
  try {
    slot = SlotPreset.doRotulo(rotulo);
  } on FormatException {
    throw RecusaFerramenta('"$rotulo" is not a slot; use bank 01-${SlotPreset.bancos} and A-C, like "03A".');
  }
  return (slot, _area(ref, argumentos.textoOpcional('area')));
}

String? _area(Ref ref, String? pedida) {
  final biblioteca = ref.read(bibliotecaProvider);
  if (pedida == null) return biblioteca.areaSelecionada;
  final existe = biblioteca.areas.temAreas && (pedida == PresetsDeFabrica.idArea || biblioteca.areas.area(pedida) != null);
  if (existe) return pedida;
  if (!biblioteca.areas.temAreas) throw const RecusaFerramenta('This pedal has a single preset area; omit "area".');
  throw RecusaFerramenta('Unknown area "$pedida". Call list_slots to see the areas.');
}

Map<String, Map<String, dynamic>> _esquemaSlot() => {
      'slot': texto('Slot label: bank 01-${SlotPreset.bancos} plus A, B or C, like "03A".'),
      'area': texto('Optional preset area id from list_slots (default: the area shown in the app).'),
    };

/// O preset gravado no slot, sem abri-lo; nulo = slot vazio.
Future<DocumentoPreset?> _lerDoSlot(Ref ref, SlotPreset slot, String? area) async {
  if (area == PresetsDeFabrica.idArea) return (await ref.read(presetsFabricaProvider.future)).documento(slot);
  final repositorio = ref.read(conexaoProvider.notifier).repositorio;
  if (repositorio == null) throw const RecusaFerramenta('The pedal is not connected.');
  return switch (await repositorio.lerPreset(slot, area: area)) {
    Sucesso(:final valor) => valor,
    Falha(:final erro) => throw RecusaFerramenta('Reading ${slot.rotulo} failed: ${erro.mensagem}'),
  };
}

class ListarSlots extends FerramentaMcp {
  const ListarSlots(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'list_slots';

  @override
  String get descricao => 'List the preset areas of the pedal (if it has more than one) and the occupied slots '
      'of one area, with each preset name. Use it to find a preset for read_slot or open_slot.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({'area': _esquemaSlot()['area']!});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    exigirPedaleiraConectada(_ref);
    final area = _area(_ref, argumentos.textoOpcional('area'));
    final biblioteca = _ref.read(bibliotecaProvider);
    return ResultadoFerramenta.dados({
      'areas': [
        for (final a in biblioteca.areas.areas) {'id': a.id, 'name': a.nome, 'active_on_pedal': a.id == biblioteca.areas.ativa},
      ],
      'area': area,
      'open_slot': sessao.estado.slot?.rotulo,
      'slots': [for (final r in await _resumos(area)) {'slot': r.slot.rotulo, 'name': r.nome}],
    });
  }

  Future<List<ResumoSlot>> _resumos(String? area) async {
    if (area == PresetsDeFabrica.idArea) return (await _ref.read(presetsFabricaProvider.future)).resumos;
    final repositorio = _ref.read(conexaoProvider.notifier).repositorio!;
    final lidos = switch (await repositorio.listarSlots(area: area)) {
      Sucesso(:final valor) => valor,
      Falha(:final erro) => throw RecusaFerramenta('Listing the slots failed: ${erro.mensagem}'),
    };
    return [...lidos]..sort((a, b) => a.slot.numero.compareTo(b.slot.numero));
  }
}

class LerSlot extends FerramentaMcp {
  const LerSlot(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'read_slot';

  @override
  String get descricao => 'Read the preset saved in a slot WITHOUT opening it: nothing is played and the preset '
      'open in the app does not change. Same layout as get_current_preset (blocks, parameters, scenes). Use it '
      'to compare presets or to copy settings from one.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(_esquemaSlot(), obrigatorias: const ['slot']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final (slot, area) = _slotEArea(_ref, argumentos);
    final documento = await _lerDoSlot(_ref, slot, area);
    final descricao = DescricaoPreset(sessao.definicao, sessao.gabinetes());
    return ResultadoFerramenta.dados({
      'slot': slot.rotulo,
      'area': area,
      'empty': documento == null,
      if (documento != null) 'preset': descricao.conteudo(documento),
    });
  }
}

class AbrirSlot extends FerramentaMcp {
  const AbrirSlot(this.sessao, this._ref);
  final SessaoMcp sessao;
  final Ref _ref;

  @override
  String get nome => 'open_slot';

  @override
  String get descricao => 'Open a slot in the app, as if the player picked it in the preset list: the pedal '
      'plays it and it becomes the preset your other tools change. If the open preset has unsaved edits this is '
      'refused; ask the player first, and only then call again with discard_edits=true (those edits are lost). '
      'An EMPTY slot opens a new empty preset with that slot as its destination (like "Create preset here" in the '
      'app): build it with add_block and save it there with save_preset. Opening never writes to the pedal.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        ..._esquemaSlot(),
        'discard_edits': {'type': 'boolean', 'description': 'true = drop the unsaved edits of the open preset.'},
        'new_preset_name': texto('Name of the new preset when the slot is empty (default: "New preset" in the '
            'app language). Max $tamanhoMaximoNome characters.'),
      }, obrigatorias: const ['slot']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final (slot, area) = _slotEArea(_ref, argumentos);
    final estado = sessao.estado;
    if (estado.ocupado) throw const RecusaFerramenta('The app is loading or saving a preset; try again in a moment.');
    if (estado.naoSalvo && argumentos['discard_edits'] != true) {
      throw RecusaFerramenta('"${estado.atual?.nome}" has unsaved edits. Ask the player whether to save them '
          '(save_preset) or drop them; to drop them, call open_slot again with discard_edits=true.');
    }
    final biblioteca = _ref.read(bibliotecaProvider.notifier);
    if (area != null && area != _ref.read(bibliotecaProvider).areaSelecionada) await biblioteca.selecionarArea(area);
    final nomeNovo = _nomeDoPresetNovo(argumentos);
    await sessao.editor.abrirSlot(slot);
    final novo = sessao.estado.slot == slot && sessao.estado.atual == null;
    // slot vazio: o mesmo "Criar preset aqui" da tela, com este slot como destino
    if (novo) await sessao.editor.novoPresetNoSlot(nomeNovo);
    sessao.avisar('open ${slot.rotulo}');
    return _aberto(slot, area, novo: novo);
  }

  String _nomeDoPresetNovo(Map<String, dynamic> argumentos) {
    final pedido = argumentos['new_preset_name'];
    if (pedido == null) return sessao.nomeDePresetNovo();
    if (pedido is! String || motivoNomeInvalido(pedido) != null || pedido.trim().length > tamanhoMaximoNome) {
      throw const RecusaFerramenta('"new_preset_name" must be 1-$tamanhoMaximoNome characters, without "DSTART" or "DEND".');
    }
    return pedido.trim();
  }

  ResultadoFerramenta _aberto(SlotPreset slot, String? area, {bool novo = false}) {
    final estado = sessao.estado;
    if (estado.aviso case AvisoErro(:final erro)) {
      throw RecusaFerramenta('Opening ${slot.rotulo} failed: ${erro.mensagem}');
    }
    if (estado.slot != slot) throw RecusaFerramenta('${slot.rotulo} was not opened; check the app.');
    final documento = estado.atual;
    final descricao = DescricaoPreset(sessao.definicao, sessao.gabinetes());
    return ResultadoFerramenta.dados({
      'slot': slot.rotulo,
      'area': area,
      'empty': documento == null,
      if (novo) 'new_preset': true,
      if (documento != null) 'preset': descricao.preset(estado, documento),
    });
  }
}
