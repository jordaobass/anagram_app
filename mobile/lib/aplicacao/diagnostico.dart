// Onde fica o registro do app, para a tela mostrar e copiar. O `main` liga o
// arquivo e entrega por override; sem arquivo (web, celular) fica nulo.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../plataforma/registro_em_arquivo.dart';

final registroEmArquivoProvider = Provider<RegistroEmArquivo?>((ref) => null);
