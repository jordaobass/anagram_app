// Versão do app à vista: com builds com e sem a arte da pedaleira circulando,
// é por ela que a pessoa (e quem dá suporte) sabe qual app está aberto.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../nucleo/registro.dart';
import 'provedores.dart';

/// A versão do pubspec, que o Flutter grava no build de cada plataforma.
final versaoAppProvider = FutureProvider<String>((ref) async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } on Object catch (erro) {
    // sem a versão o app segue igual; só o rótulo fica sem número
    registro.w('versão do app indisponível', error: erro);
    return '';
  }
});

/// A versão e se o build traz a arte da pedaleira; a tela monta a frase
/// ("v0.1.3 · arte da pedaleira") no idioma em uso. Versão vazia = sem rótulo.
final rotuloVersaoProvider = Provider<({String versao, bool comArte})>((ref) {
  final versao = ref.watch(versaoAppProvider).value ?? '';
  final comArte = ref.watch(indiceMiniaturasProvider).value?.temArteDaPedaleira ?? false;
  return (versao: versao, comArte: comArte);
});
