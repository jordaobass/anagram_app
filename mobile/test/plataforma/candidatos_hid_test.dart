import 'package:anagram_app/plataforma/transporte_hidapi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_try_only_the_vendor_interface_when_one_announces_itself', () {
    const audio = CandidatoHid('/dev/hidraw0', paginaDeUso: 0x0C, numeroInterface: 0);
    const controle = CandidatoHid('/dev/hidraw1', paginaDeUso: 0xFF00, numeroInterface: 3);

    expect(ordenarCandidatos([audio, controle]), [controle]);
  });

  test('should_try_every_interface_by_number_when_no_usage_page_is_reported', () {
    const terceira = CandidatoHid('/dev/hidraw7', paginaDeUso: 0, numeroInterface: 3);
    const primeira = CandidatoHid('/dev/hidraw2', paginaDeUso: 0, numeroInterface: 1);

    expect(ordenarCandidatos([terceira, primeira]), [primeira, terceira]);
  });
}
