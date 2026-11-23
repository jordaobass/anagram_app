// Tema da interface: o do sistema por padrão (claro de dia, escuro à noite,
// como o aparelho estiver), ou escuro ou claro fixos, escolhidos nas
// Configurações e guardados (DECISOES TC1).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dados/preferencias_tema.dart';

enum EscolhaTema {
  sistema('sistema'),
  escuro('escuro'),
  claro('claro');

  const EscolhaTema(this.codigo);
  final String codigo;

  static EscolhaTema? doCodigo(String? codigo) => values.where((t) => t.codigo == codigo).firstOrNull;
}

final preferenciasTemaProvider = Provider<PreferenciasTema>((ref) => PreferenciasTemaLocais());

/// O que estava salvo ao abrir o app; o main lê antes de desenhar a primeira
/// tela, para ela não nascer escura e piscar para o claro.
final temaSalvoProvider = Provider<EscolhaTema?>((ref) => null);

final temaProvider = NotifierProvider<ControladorTema, EscolhaTema>(ControladorTema.new);

class ControladorTema extends Notifier<EscolhaTema> {
  @override
  EscolhaTema build() => ref.read(temaSalvoProvider) ?? EscolhaTema.sistema;

  void escolher(EscolhaTema tema) {
    state = tema;
    unawaited(ref.read(preferenciasTemaProvider).gravar(tema.codigo));
  }
}
