// A pedaleira e o Darkglass Suite tratam a mesma uri com e sem o sufixo de
// canal ("#stereo", "#mono"): o Suite compara `uri == base || uri == base +
// "#stereo"`. Catálogo e arte guardam uma das formas só; a busca tenta as
// outras para o bloco não cair sem nome nem arte por causa do sufixo.

/// A uri exata primeiro, depois sem o sufixo "#…", depois as variantes
/// estéreo e mono (há plugin que o catálogo só traz com uma delas).
List<String> variantesDeUri(String uri) {
  final base = semSufixoDeCanal(uri);
  return {uri, base, '$base#stereo', '$base#mono'}.toList();
}

String semSufixoDeCanal(String uri) {
  final marca = uri.indexOf('#');
  return marca < 0 ? uri : uri.substring(0, marca);
}

/// O primeiro valor de [mapa] numa das variantes de [uri], ou null.
T? buscarPorVariantes<T>(Map<String, T> mapa, String uri) {
  for (final variante in variantesDeUri(uri)) {
    final valor = mapa[variante];
    if (valor != null) return valor;
  }
  return null;
}
