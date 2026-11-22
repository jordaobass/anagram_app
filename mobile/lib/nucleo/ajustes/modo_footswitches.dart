// O modo dos footswitches, ajuste global da Anagram. Chave `mode` do
// `export_settings`/`edit_settings`, com os três valores provados na v1.19.2.24
// em 2026-11-22 (DECISOES FM1). O Darkglass Suite chama os modos "P (Preset)",
// "STP (Stomp)" e "SCN (Scene)". `scene-mode` vem junto e não é mexido.
enum ModoFootswitches {
  preset('preset'),
  stomp('stomp'),
  scene('scene');

  const ModoFootswitches(this.valor);

  /// Como a pedaleira grava e devolve.
  final String valor;

  /// Nulo = valor que o app não conhece (outro firmware): fica "desconhecido".
  static ModoFootswitches? doValor(Object? valor) {
    for (final modo in values) {
      if (modo.valor == valor) return modo;
    }
    return null;
  }
}

/// A chave plana do modo nos ajustes da pedaleira.
const chaveModoFootswitches = 'mode';
