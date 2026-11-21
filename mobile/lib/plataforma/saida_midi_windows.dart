// USB MIDI no Windows pela winmm.dll (FFI, sem plugin): é por ele que o app
// troca o slot da pedaleira com Program Change (DECISOES D4). A porta é
// achada pelo nome; sem ela, o USB MIDI está desligado nos ajustes da Anagram.
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import '../nucleo/midi/saida_midi.dart';
import '../nucleo/protocolo/erros_anagram.dart';
import '../nucleo/registro.dart';
import 'midi_windows.dart';
import 'winmm_ffi.dart';

class SaidaMidiWindows implements SaidaMidiAnagram {
  SaidaMidiWindows({WinMm? Function() carregar = WinMm.carregar}) : _carregar = carregar;

  final WinMm? Function() _carregar;
  WinMm? _winmm;
  int? _porta;

  @override
  String get descricao => 'USB MIDI (winmm)';

  @override
  bool get aberta => _porta != null;

  @override
  Future<void> abrir() async {
    // abrir de novo sem fechar deixaria o handle anterior preso no driver,
    // e a porta passaria a recusar quem tentasse abri-la depois
    await fechar();
    final winmm = _winmm ??= _carregar();
    if (winmm == null) throw const ErroPlataformaSemSuporte('MIDI do Windows (winmm.dll) indisponível.');
    final nomes = winmm.nomesDasSaidas();
    final indice = escolherPortaAnagram(nomes);
    if (indice == null) {
      registro.w('MIDI: portas de saída vistas: $nomes');
      throw const ErroDesconectado('Porta MIDI da Anagram não encontrada. Ligue o USB MIDI nos ajustes de MIDI '
          'da pedaleira e conecte de novo; sem ele, abrir um preset só toca, sem trocar o slot.');
    }
    _porta = _abrirPorta(winmm, indice, nomes[indice]);
  }

  static int _abrirPorta(WinMm winmm, int indice, String nome) {
    final alca = calloc<IntPtr>();
    try {
      // CALLBACK_NULL: o app só manda; não precisa de aviso do driver
      final resultado = winmm.midiOutOpen(alca, indice, 0, 0, 0);
      if (resultado != WinMm.semErro) {
        // outro programa (Darkglass Suite, DAW) pode estar com a porta
        throw ErroDesconectado('A porta MIDI "$nome" não abriu (código $resultado). '
            'Feche outros programas de MIDI e tente de novo.');
      }
      registro.i('MIDI: abriu "$nome"');
      return alca.value;
    } finally {
      calloc.free(alca);
    }
  }

  @override
  Future<void> enviar(List<int> mensagem) async {
    final winmm = _winmm;
    final porta = _porta;
    if (winmm == null || porta == null) throw const ErroDesconectado('MIDI fechado.');
    final resultado = winmm.midiOutShortMsg(porta, empacotarMensagemCurta(mensagem));
    if (resultado != WinMm.semErro) throw ErroDesconectado('MIDI: envio falhou (código $resultado).');
  }

  /// Fechar nunca lança: acontece ao desconectar, quando o erro não muda nada.
  @override
  Future<void> fechar() async {
    final porta = _porta;
    _porta = null;
    if (porta == null) return;
    final resultado = _winmm?.midiOutClose(porta) ?? WinMm.semErro;
    if (resultado != WinMm.semErro) registro.w('MIDI: midiOutClose devolveu $resultado');
  }
}
