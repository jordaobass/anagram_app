// Vários blocos existem em versão mono e estéreo com o mesmo nome no catálogo
// da pedaleira ("Parametric EQ", "Hall Reverb"…): sem marcar o canal, a
// biblioteca e a cadeia mostram dois blocos iguais.
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/fixtures.dart';

void main() {
  final catalogo = lerCatalogo();

  test('should_tell_mono_and_stereo_apart_when_two_blocks_share_the_same_name', () {
    expect(catalogo.definicao('urn:darkglass:fil4#mono').canal, CanalBloco.mono);
    expect(catalogo.definicao('urn:darkglass:fil4#stereo').canal, CanalBloco.estereo);
    expect(catalogo.definicao('urn:darkglass:HallReverb').canal, CanalBloco.mono);
    expect(catalogo.definicao('urn:darkglass:HallReverbStereo').canal, CanalBloco.estereo);
  });

  test('should_not_mark_the_channel_when_the_block_name_is_unique', () {
    expect(catalogo.definicao('urn:darkglass:DarkglassGEQ').canal, CanalBloco.unico);
    expect(catalogo.definicao('urn:darkglass:Suppressor').canal, CanalBloco.unico);
  });
}
