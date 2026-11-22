// Ferramentas dos ajustes GLOBAIS da pedaleira (valem para todos os presets).
// Mixer, Global EQ e ganho de entrada só se leem: a Anagram aceita e relê o
// que se manda, mas não aplica ao som (DECISOES AJ1), então a IA é avisada e
// recusada em vez de dizer à pessoa que mudou algo. O que se grava é o modo
// dos footswitches, pelo mesmo controlador do seletor da tela (DECISOES AJ3).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/ajustes/modo_footswitches.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../estado/controlador_ajustes.dart';
import '../estado/controlador_modo_footswitches.dart';
import 'sessao_mcp.dart';

const _semAcesso = 'the app has no access to this pedal feature: the pedal accepts the value but does not apply it '
    'to the sound. Ask the player to change it on the pedal itself (its knobs and screens).';

/// Mixer, Global EQ ou entrada, pelo id do app ou por qualquer chave desses
/// grupos (também as que o app não mostra, como `mixer.speaker.vol`).
bool _ehDoSom(String pedido) =>
    ajustePorIdOuChave(pedido) != null || ['mixer.', 'globaleq.', 'input-gain'].any(pedido.startsWith);

Map<String, dynamic> _descrever(DefinicaoAjuste a, num? valor) => {
      'setting': a.id,
      'name': a.nome,
      'group': a.grupo.name,
      'value': ?valor,
      'min': a.minimo,
      'max': a.maximo,
      'unit': ?a.unidade,
      'readOnly': true,
    };

class LerAjustesGlobais extends FerramentaMcp {
  const LerAjustesGlobais(this.ref);
  final Ref ref;

  @override
  String get nome => 'get_global_settings';

  @override
  String get descricao => 'Read the pedal-wide settings that apply to every preset, as the pedal reports them: '
      'output levels (mixer), the 6-band Global EQ (low shelf "ls", peaks "1" to "4", high shelf "hs"; gain, freq '
      'and width 0-4 each), instrument input gain and the sound card. These are READ ONLY: $_semAcesso '
      'Also returns the footswitch mode (preset, stomp or scene), the one you can change with set_global_setting.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    exigirPedaleiraConectada(ref);
    await ref.read(controladorAjustesProvider.notifier).carregar();
    final estado = ref.read(controladorAjustesProvider);
    final lidos = estado.lidos;
    if (lidos == null) throw const RecusaFerramenta('The pedal did not answer; try again in a moment.');
    return ResultadoFerramenta.dados({
      'settings': [for (final a in ajustesConfirmados()) _descrever(estado.faixa(a), estado.valor(a))],
      'soundcardReadOnly': lidos.placa,
      'footswitchMode': ?lidos.modo?.valor,
    });
  }
}

class MudarAjusteGlobal extends FerramentaMcp {
  const MudarAjusteGlobal(this.ref);
  final Ref ref;

  @override
  String get nome => 'set_global_setting';

  @override
  String get descricao => 'Change the footswitch mode, the only pedal-wide setting the app can apply (no save '
      'needed): setting "mode", value "preset", "stomp" or "scene". Output levels, Global EQ and input gain are '
      'refused: $_semAcesso';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'setting': texto('"mode" (the footswitch mode).'),
        'value': {
          'type': 'string',
          'enum': [for (final m in ModoFootswitches.values) m.valor],
          'description': 'The new footswitch mode.',
        },
      }, obrigatorias: const ['setting', 'value']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    exigirPedaleiraConectada(ref);
    final pedido = argumentos.textoObrigatorio('setting');
    if (_ehDoSom(pedido)) throw RecusaFerramenta('"$pedido" is read only: $_semAcesso');
    if (pedido != chaveModoFootswitches) {
      throw RecusaFerramenta('Unknown setting "$pedido". The only one that can be changed is "$chaveModoFootswitches".');
    }
    final modo = ModoFootswitches.doValor(argumentos['value']);
    if (modo == null) throw const RecusaFerramenta('"value" must be "preset", "stomp" or "scene".');
    final controlador = ref.read(controladorModoProvider.notifier);
    await controlador.garantirLeitura();
    if (!ref.read(modoDisponivelProvider)) {
      throw const RecusaFerramenta('This pedal firmware does not report the footswitch mode, so the app cannot change it.');
    }
    if (!await controlador.escolher(modo)) throw const RecusaFerramenta('The pedal did not confirm the mode change.');
    return ResultadoFerramenta.dados({'setting': chaveModoFootswitches, 'value': modo.valor});
  }
}
