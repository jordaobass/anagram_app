// Idioma da interface: o do sistema por padrão, ou o escolhido na tela Sobre,
// que fica guardado. Os textos estão em lib/l10n (português é o modelo).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dados/preferencias_idioma.dart';

enum IdiomaApp {
  portugues('pt'),
  ingles('en'),
  espanhol('es'),
  frances('fr');

  const IdiomaApp(this.codigo);
  final String codigo;

  static IdiomaApp? doCodigo(String? codigo) => values.where((i) => i.codigo == codigo).firstOrNull;

  /// O do sistema, se for um dos quatro; qualquer outro cai no inglês.
  static IdiomaApp doSistema(String codigoSistema) =>
      doCodigo(codigoSistema.toLowerCase().split(RegExp('[-_]')).first) ?? ingles;
}

final preferenciasIdiomaProvider = Provider<PreferenciasIdioma>((ref) => PreferenciasIdiomaLocais());

/// O que estava salvo ao abrir o app; o main lê antes de desenhar a primeira
/// tela, para não piscar no idioma do sistema e depois trocar.
final idiomaSalvoProvider = Provider<IdiomaApp?>((ref) => null);

final idiomaProvider = NotifierProvider<ControladorIdioma, IdiomaApp?>(ControladorIdioma.new);

/// Nulo = seguir o idioma do sistema.
class ControladorIdioma extends Notifier<IdiomaApp?> {
  @override
  IdiomaApp? build() => ref.read(idiomaSalvoProvider);

  void escolher(IdiomaApp? idioma) {
    state = idioma;
    unawaited(ref.read(preferenciasIdiomaProvider).gravar(idioma?.codigo));
  }
}
