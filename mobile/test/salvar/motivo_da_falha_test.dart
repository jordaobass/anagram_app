// A frase de "não salvou" vai para a tela: nome de ação do protocolo e tipo
// de exceção ficam no log, não no aviso.
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should_explain_a_save_failure_without_protocol_details_when_the_pedal_times_out', () {
    final falha = FalhaAoSalvar(ErroSemResposta('edit_anagram_presets', const Duration(seconds: 30)));

    expect(falha.motivo, isNot(contains('edit_anagram_presets')));
    expect(falha.motivo, contains('não respondeu'));
  });

  test('should_explain_a_save_failure_without_the_exception_type_when_the_cable_is_pulled', () {
    const falha = FalhaAoSalvar(
        ErroDesconectado('Falha ao enviar "edit_anagram_presets": ErroDesconectado: cabo removido'));

    expect(falha.motivo, isNot(contains('edit_anagram_presets')));
    expect(falha.motivo, isNot(contains('ErroDesconectado')));
  });

  test('should_keep_the_app_own_wording_when_the_save_was_refused_by_the_app', () {
    const falha = FalhaAoSalvar(ErroOperacaoEmCurso('Espere a gravação em curso terminar.'));

    expect(falha.motivo, 'Espere a gravação em curso terminar.');
  });
}
