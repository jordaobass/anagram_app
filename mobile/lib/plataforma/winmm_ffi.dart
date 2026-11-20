// Ligações FFI mínimas para a saída MIDI da winmm.dll, que vem em todo
// Windows: listar portas, abrir, mandar mensagem curta e fechar.
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef _NumDevs = Uint32 Function();
typedef _GetDevCaps = Uint32 Function(UintPtr, Pointer<Uint8>, Uint32);
typedef _Open = Uint32 Function(Pointer<IntPtr>, Uint32, UintPtr, UintPtr, Uint32);
typedef _ShortMsg = Uint32 Function(IntPtr, Uint32);
typedef _Close = Uint32 Function(IntPtr);

class WinMm {
  WinMm._(DynamicLibrary lib)
      : midiOutGetNumDevs = lib.lookupFunction<_NumDevs, int Function()>('midiOutGetNumDevs'),
        midiOutGetDevCapsW =
            lib.lookupFunction<_GetDevCaps, int Function(int, Pointer<Uint8>, int)>('midiOutGetDevCapsW'),
        midiOutOpen = lib.lookupFunction<_Open, int Function(Pointer<IntPtr>, int, int, int, int)>('midiOutOpen'),
        midiOutShortMsg = lib.lookupFunction<_ShortMsg, int Function(int, int)>('midiOutShortMsg'),
        midiOutClose = lib.lookupFunction<_Close, int Function(int)>('midiOutClose');

  /// Resultado de sucesso das funções midiOut* (MMSYSERR_NOERROR).
  static const semErro = 0;

  /// MIDIOUTCAPSW: WORD wMid, WORD wPid, UINT vDriverVersion, WCHAR
  /// szPname[32], WORD x4, DWORD dwSupport = 84 bytes; o nome começa no
  /// byte 8.
  static const _tamanhoCapacidades = 84;
  static const _inicioDoNome = 8;
  static const _caracteresDoNome = 32;

  final int Function() midiOutGetNumDevs;
  final int Function(int, Pointer<Uint8>, int) midiOutGetDevCapsW;
  final int Function(Pointer<IntPtr>, int, int, int, int) midiOutOpen;
  final int Function(int, int) midiOutShortMsg;
  final int Function(int) midiOutClose;

  /// null fora do Windows (não há winmm.dll para abrir).
  static WinMm? carregar() {
    try {
      return WinMm._(DynamicLibrary.open('winmm.dll'));
    } on ArgumentError {
      return null;
    }
  }

  /// Nomes das portas de saída, na ordem dos ids que o midiOutOpen aceita.
  List<String> nomesDasSaidas() {
    final capacidades = calloc<Uint8>(_tamanhoCapacidades);
    try {
      return [
        for (var id = 0; id < midiOutGetNumDevs(); id++)
          midiOutGetDevCapsW(id, capacidades, _tamanhoCapacidades) == semErro ? _nome(capacidades) : '',
      ];
    } finally {
      calloc.free(capacidades);
    }
  }

  static String _nome(Pointer<Uint8> capacidades) {
    final letras = (capacidades + _inicioDoNome).cast<Uint16>().asTypedList(_caracteresDoNome);
    final fim = letras.indexOf(0);
    return String.fromCharCodes(fim < 0 ? letras : letras.sublist(0, fim));
  }
}
