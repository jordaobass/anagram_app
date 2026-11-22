// A frase de "não salvou" vai para a tela: nome de ação do protocolo e tipo
// de exceção ficam no log, não no aviso.
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/nucleo/protocolo/erros_anagram.dart';
import 'package:anagram_app/apresentacao/textos.dart';
import 'package:flutter_test/flutter_test.dart';
import '../apoio/textos_pt.dart';

void main() {
  test('should_explain_a_save_failure_without_protocol_details_when_the_pedal_times_out', () {
    final falha = FalhaAoSalvar(ErroSemResposta('edit_anagram_presets', const Duration(seconds: 30)));

    expect(textosPt.falhaAoSalvar(falha), isNot(contains('edit_anagram_presets')));
    expect(textosPt.falhaAoSalvar(falha), contains('não respondeu'));
  });

  test('should_explain_a_save_failure_without_the_exception_type_when_the_cable_is_pulled', () {
    const falha = FalhaAoSalvar(
        ErroDesconectado('Falha ao enviar "edit_anagram_presets": ErroDesconectado: cabo removido'));

    expect(textosPt.falhaAoSalvar(falha), isNot(contains('edit_anagram_presets')));
    expect(textosPt.falhaAoSalvar(falha), isNot(contains('ErroDesconectado')));
  });

  test('should_keep_the_app_own_wording_when_the_save_was_refused_by_the_app', () {
    const falha = FalhaAoSalvar(ErroOperacaoEmCurso('Espere a gravação em curso terminar.'));

    expect(textosPt.falhaAoSalvar(falha), 'Não salvou: Espere a gravação em curso terminar.');
  });

  test('should_say_the_slot_read_back_differs_when_the_pedal_confirmed_another_content', () {
    const falha = FalhaAoSalvar(ErroReleituraDiferente('slot relido diferente'));

    expect(textosPt.falhaAoSalvar(falha), contains('diferente do enviado'));
  });
}
