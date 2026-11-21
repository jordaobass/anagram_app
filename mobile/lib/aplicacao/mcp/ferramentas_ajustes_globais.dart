// Ferramentas dos ajustes GLOBAIS da pedaleira (mixer, Global EQ, ganho de
// entrada): valem para todos os presets e mudam na hora, sem "Salvar".
// Passam pelo [ControladorAjustes], o mesmo caminho dos controles da tela,
// e só aceitam os ajustes cuja chave o app conhece (DECISOES PD2).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/mcp/ferramenta_mcp.dart';
import '../estado/controlador_ajustes.dart';
import '../estado/controlador_conexao.dart';
import '../estado/estado_conexao.dart';

ControladorAjustes _controlador(Ref ref) {
  if (ref.read(conexaoProvider) is! Conectada) {
    throw const RecusaFerramenta('The pedal is not connected. Ask the player to connect it in the Anagram App.');
  }
  return ref.read(controladorAjustesProvider.notifier);
}

Map<String, dynamic> _descrever(DefinicaoAjuste a, num? valor) => {
      'setting': a.id,
      'name': a.nome,
      'group': a.grupo.name,
      'value': ?valor,
      'min': a.minimo,
      'max': a.maximo,
      'unit': ?a.unidade,
    };

class LerAjustesGlobais extends FerramentaMcp {
  const LerAjustesGlobais(this.ref);
  final Ref ref;

  @override
  String get nome => 'get_global_settings';

  @override
  String get descricao => 'Read the pedal-wide settings that apply to every preset: output levels (mixer), '
      'the 6-band Global EQ (low shelf "ls", peaks "1" to "4", high shelf "hs"; gain, freq and width each) and '
      'instrument input gain, plus the read-only sound card values. '
      'Change them with set_global_setting.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto(const {});

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final controlador = _controlador(ref);
    await controlador.carregar();
    final estado = ref.read(controladorAjustesProvider);
    if (estado.lidos == null) throw const RecusaFerramenta('The pedal did not answer; try again in a moment.');
    return ResultadoFerramenta.dados({
      'settings': [for (final a in ajustesConfirmados()) _descrever(estado.faixa(a), estado.valor(a))],
      'soundcardReadOnly': estado.lidos!.placa,
    });
  }
}

class MudarAjusteGlobal extends FerramentaMcp {
  const MudarAjusteGlobal(this.ref);
  final Ref ref;

  @override
  String get nome => 'set_global_setting';

  @override
  String get descricao => 'Change one pedal-wide setting (applies to every preset, immediately, no save needed). '
      'Use a "setting" id from get_global_settings. Out-of-range values are clamped.';

  @override
  Map<String, dynamic> get esquema => esquemaObjeto({
        'setting': texto('Setting id from get_global_settings, e.g. "headphones", "eq_ls_gain" or "eq_2_freq".'),
        'value': {'type': 'number', 'description': 'New value in the setting unit (dB, Hz, or 0-1 for EQ width).'},
      }, obrigatorias: const ['setting', 'value']);

  @override
  Future<ResultadoFerramenta> executar(Map<String, dynamic> argumentos) async {
    final controlador = _controlador(ref);
    final pedido = argumentos.textoObrigatorio('setting');
    final ajuste = ajustePorIdOuChave(pedido);
    if (ajuste == null || !ajuste.confirmado) {
      final validos = ajustesConfirmados().map((a) => a.id).join(', ');
      throw RecusaFerramenta('Unknown or not yet supported setting "$pedido". Valid: $validos.');
    }
    final valor = argumentos['value'];
    if (valor is! num) throw const RecusaFerramenta('"value" must be a number.');
    controlador.alterar(ajuste, valor);
    if (!await controlador.enviarAgora()) throw const RecusaFerramenta('The pedal did not accept the change.');
    final estado = ref.read(controladorAjustesProvider);
    final faixa = estado.faixa(ajuste);
    return ResultadoFerramenta.dados({..._descrever(faixa, estado.valor(ajuste)), 'clamped': faixa.limitar(valor) != valor});
  }
}
