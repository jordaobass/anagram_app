import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'aplicacao/diagnostico.dart';
import 'aplicacao/erros_nao_tratados.dart';
import 'aplicacao/idioma.dart';
import 'aplicacao/tema.dart';
import 'apresentacao/app_anagram.dart';
import 'aplicacao/provedores.dart';
import 'dados/preferencias_idioma.dart';
import 'dados/preferencias_pausa.dart';
import 'dados/preferencias_tema.dart';
import 'plataforma/registro_em_arquivo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registrarErrosNaoTratados();
  final arquivoDeRegistro = ligarRegistroEmArquivo();
  // o idioma escolhido antes da primeira tela, para ela já nascer nele
  final salvo = IdiomaApp.doCodigo(await PreferenciasIdiomaLocais().ler());
  // o tema também: a primeira tela já nasce clara ou escura
  final tema = EscolhaTema.doCodigo(await PreferenciasTemaLocais().ler());
  // a pausa USB vale já na primeira conversa com a pedaleira
  final pausa = await PreferenciasPausaLocais().ler();
  runApp(ProviderScope(
    overrides: [
      idiomaSalvoProvider.overrideWithValue(salvo),
      temaSalvoProvider.overrideWithValue(tema),
      pausaSalvaProvider.overrideWithValue(pausa == null ? null : Duration(milliseconds: pausa)),
      registroEmArquivoProvider.overrideWithValue(arquivoDeRegistro),
    ],
    child: const AppAnagram(),
  ));
}
