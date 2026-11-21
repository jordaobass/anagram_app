// Registro único do app (nunca print). O nível padrão mostra informação;
// testes podem trocar a saída. O console sempre recebe; o arquivo de registro
// entra depois, pela plataforma, porque o exe com janela não tem console e
// quem relata um defeito precisa de algo para mandar.
import 'package:logger/logger.dart';

final saidasDoRegistro = SaidasDoRegistro();

final Logger registro = Logger(
  // o filtro padrão do pacote só deixa passar com `assert` ligado: na release
  // o registro saía mudo, no console e no arquivo (provado no Windows, 0.1.17)
  filter: ProductionFilter(),
  printer: SimplePrinter(printTime: true, colors: false),
  output: saidasDoRegistro,
  level: Level.info,
);

/// Repassa cada linha a todos os destinos ligados (console e, onde houver, arquivo).
class SaidasDoRegistro extends LogOutput {
  final List<LogOutput> _destinos = [ConsoleOutput()];

  void acrescentar(LogOutput destino) => _destinos.add(destino);

  void remover(LogOutput destino) => _destinos.remove(destino);

  @override
  void output(OutputEvent event) {
    for (final destino in List.of(_destinos)) {
      destino.output(event);
    }
  }
}
