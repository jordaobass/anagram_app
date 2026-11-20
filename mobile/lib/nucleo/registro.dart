// Registro único do app (nunca print). O nível padrão mostra informação;
// testes podem trocar a saída.
import 'package:logger/logger.dart';

final Logger registro = Logger(
  printer: SimplePrinter(printTime: true, colors: false),
  level: Level.info,
);
