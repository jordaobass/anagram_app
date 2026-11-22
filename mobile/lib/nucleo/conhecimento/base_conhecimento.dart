// As três partes do conhecimento de timbre que o MCP entrega à IA, juntas.
// Sem os arquivos, a base fica vazia e as ferramentas de ajuste continuam
// funcionando: só o guia é que não responde.
import 'guia_blocos.dart';
import 'guia_timbre.dart';
import 'receitas_timbre.dart';

export 'guia_blocos.dart';
export 'guia_timbre.dart';
export 'receitas_timbre.dart';

class BaseConhecimento {
  const BaseConhecimento({required this.guiaBlocos, required this.guiaTimbre, required this.receitas});

  static final vazia = BaseConhecimento(
    guiaBlocos: GuiaBlocos.vazio,
    guiaTimbre: GuiaTimbre.vazio,
    receitas: ReceitasTimbre.vazio,
  );

  final GuiaBlocos guiaBlocos;
  final GuiaTimbre guiaTimbre;
  final ReceitasTimbre receitas;
}
