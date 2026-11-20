// Regras do MIDI no Windows que não dependem da winmm.dll, separadas para
// poder ser testadas em qualquer máquina.

/// Pedaços do nome com que o driver USB MIDI do Windows anuncia a pedaleira.
/// O nome exato varia com o driver ("Anagram", "Darkglass Anagram", "MIDI 2
/// (Anagram)"), por isso a busca é por trecho e sem diferenciar maiúsculas.
const _trechosDoNome = ['anagram', 'darkglass'];

/// Índice da porta de saída da pedaleira, ou null quando nenhuma serve (o
/// USB MIDI está desligado nos ajustes dela). "Anagram" vence "Darkglass":
/// se a Darkglass tiver outro aparelho plugado, a Anagram é a certa.
int? escolherPortaAnagram(List<String> nomes) {
  for (final trecho in _trechosDoNome) {
    final indice = nomes.indexWhere((nome) => nome.toLowerCase().contains(trecho));
    if (indice >= 0) return indice;
  }
  return null;
}

/// Empacota uma mensagem curta (1 a 3 bytes) no DWORD do midiOutShortMsg: o
/// status no byte menos significativo e os dados nos seguintes. SysEx e
/// mensagens maiores exigem midiOutLongMsg e não cabem aqui.
int empacotarMensagemCurta(List<int> bytes) {
  if (bytes.isEmpty || bytes.length > 3) {
    throw ArgumentError.value(bytes, 'bytes', 'mensagem curta MIDI tem de 1 a 3 bytes');
  }
  var dword = 0;
  for (var i = 0; i < bytes.length; i++) {
    dword |= (bytes[i] & 0xFF) << (8 * i);
  }
  return dword;
}
