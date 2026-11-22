// Os utilitários internos da pedaleira não têm arte nem no Darkglass Suite,
// nem na tabela do anagramcontrol.online, nem no Marketplace: o app desenha um
// ícone pela função de cada um (DECISOES A19), escolhido pela uri.
import 'variantes_uri.dart';

enum TipoUtilitario { afinador, mixer, medidor, vu, espectro, midiCc, midiPc, senoide, pedalExpressao, looper }

const _porUri = {
  'urn:darkglass:Tuner': TipoUtilitario.afinador,
  'urn:darkglass-anagram:mixer': TipoUtilitario.mixer,
  'urn:darkglass-anagram:meters': TipoUtilitario.vu,
  'http://gareus.org/oss/lv2/modmeter': TipoUtilitario.medidor,
  'http://gareus.org/oss/lv2/modspectre': TipoUtilitario.espectro,
  'urn:darkglass-anagram:midi-cc-helper': TipoUtilitario.midiCc,
  'urn:darkglass-anagram:midi-pc-gen': TipoUtilitario.midiPc,
  'urn:darkglass-anagram:sine-gen': TipoUtilitario.senoide,
  'urn:darkglass-anagram:exp-pedal': TipoUtilitario.pedalExpressao,
  'http://looperlative.com/plugins/lp3-anagram': TipoUtilitario.looper,
};

/// O utilitário que a uri é (com ou sem sufixo de canal), ou null.
TipoUtilitario? utilitarioDaUri(String uri) => buscarPorVariantes(_porUri, uri);
