// Ligações FFI mínimas para a hidapi (Linux: libhidapi-hidraw; Windows:
// hidapi.dll). A biblioteca não vem no app: tem de estar instalada.
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final class HidInfoDispositivo extends Struct {
  external Pointer<Utf8> path;
  @Uint16()
  external int vendorId;
  @Uint16()
  external int productId;
  external Pointer<Void> serialNumber;
  @Uint16()
  external int releaseNumber;
  external Pointer<Void> manufacturerString;
  external Pointer<Void> productString;
  @Uint16()
  external int usagePage;
  @Uint16()
  external int usage;
  @Int32()
  external int interfaceNumber;
  external Pointer<HidInfoDispositivo> next;
}

typedef _Init = Int32 Function();
typedef _Enumerate = Pointer<HidInfoDispositivo> Function(Uint16, Uint16);
typedef _Free = Void Function(Pointer<HidInfoDispositivo>);
typedef _OpenPath = Pointer<Void> Function(Pointer<Utf8>);
typedef _Write = Int32 Function(Pointer<Void>, Pointer<Uint8>, Size);
typedef _ReadTimeout = Int32 Function(Pointer<Void>, Pointer<Uint8>, Size, Int32);
typedef _Close = Void Function(Pointer<Void>);

class HidApi {
  HidApi._(DynamicLibrary lib, this.nomeBiblioteca)
      : hid_init = lib.lookupFunction<_Init, int Function()>('hid_init'),
        hid_enumerate = lib.lookupFunction<_Enumerate, Pointer<HidInfoDispositivo> Function(int, int)>(
            'hid_enumerate'),
        hid_free_enumeration = lib.lookupFunction<_Free, void Function(Pointer<HidInfoDispositivo>)>(
            'hid_free_enumeration'),
        hid_open_path = lib.lookupFunction<_OpenPath, Pointer<Void> Function(Pointer<Utf8>)>('hid_open_path'),
        hid_write = lib.lookupFunction<_Write, int Function(Pointer<Void>, Pointer<Uint8>, int)>('hid_write'),
        hid_read_timeout = lib.lookupFunction<_ReadTimeout, int Function(Pointer<Void>, Pointer<Uint8>, int, int)>(
            'hid_read_timeout'),
        hid_close = lib.lookupFunction<_Close, void Function(Pointer<Void>)>('hid_close');

  static const _candidatos = {
    'linux': ['libhidapi-hidraw.so.0', 'libhidapi-hidraw.so', 'libhidapi-libusb.so.0'],
    'windows': ['hidapi.dll'],
    'macos': ['libhidapi.dylib'],
  };

  /// Carrega a primeira biblioteca encontrada; `null` se nenhuma existir.
  static HidApi? carregar([String? nome]) {
    final nomes = nome != null ? [nome] : (_candidatos[Platform.operatingSystem] ?? const <String>[]);
    for (final candidato in nomes) {
      try {
        return HidApi._(DynamicLibrary.open(candidato), candidato);
      } on ArgumentError {
        continue;
      }
    }
    return null;
  }

  final String nomeBiblioteca;
  final int Function() hid_init;
  final Pointer<HidInfoDispositivo> Function(int, int) hid_enumerate;
  final void Function(Pointer<HidInfoDispositivo>) hid_free_enumeration;
  final Pointer<Void> Function(Pointer<Utf8>) hid_open_path;
  final int Function(Pointer<Void>, Pointer<Uint8>, int) hid_write;
  final int Function(Pointer<Void>, Pointer<Uint8>, int, int) hid_read_timeout;
  final void Function(Pointer<Void>) hid_close;
}
