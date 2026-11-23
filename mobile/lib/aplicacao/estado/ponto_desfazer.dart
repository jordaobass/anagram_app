// O desfazer da tela e o `undo` do MCP voltam o DOCUMENTO de antes da
// mudança, não só os números da cena visível: em "Todas as cenas" a mudança
// tira o parâmetro das fotos de cena, e reenviar o valor antigo deixava as
// três cenas iguais. Só volta se o preset ainda é o que a mudança deixou:
// senão apagaria a edição feita depois (ou poria outro preset no lugar).
import '../../nucleo/modelo/documento_preset.dart';

class PontoDesfazer {
  const PontoDesfazer(this.antes, this.depois);

  final DocumentoPreset antes;

  /// O documento que a mudança deixou na tela.
  final DocumentoPreset depois;

  bool valeEm(DocumentoPreset? atual) => identical(atual, depois);
}
