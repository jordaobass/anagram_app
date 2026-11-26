import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'aplicacao/copias/copia_automatica.dart';
import 'aplicacao/diagnostico.dart';
import 'aplicacao/erros_nao_tratados.dart';
import 'aplicacao/idioma.dart';
import 'aplicacao/tema.dart';
import 'apresentacao/app_anagram.dart';
import 'aplicacao/provedores.dart';
import 'dados/preferencias_copias.dart';
import 'dados/preferencias_idioma.dart';
import 'dados/preferencias_pausa.dart';
import 'dados/preferencias_tema.dart';
import 'plataforma/copias_de_seguranca.dart';
import 'plataforma/pasta_biblioteca.dart';
import 'plataforma/arquivos_abertos.dart';
import 'apresentacao/componentes/recebedor_de_arquivos.dart';
import 'aplicacao/estado/biblioteca_presets.dart';
import 'plataforma/registro_em_arquivo.dart';

Future<void> main(List<String> argumentos) async {
  WidgetsFlutterBinding.ensureInitialized();
  registrarErrosNaoTratados();
  final arquivoDeRegistro = ligarRegistroEmArquivo();
  // o idioma escolhido antes da primeira tela, para ela já nascer nele
  final salvo = IdiomaApp.doCodigo(await PreferenciasIdiomaLocais().ler());
  // o tema também: a primeira tela já nasce clara ou escura
  final tema = EscolhaTema.doCodigo(await PreferenciasTemaLocais().ler());
  // a pausa USB vale já na primeira conversa com a pedaleira
  final pausa = await PreferenciasPausaLocais().ler();
  // a pasta de backups antes da primeira gravação (no macOS vem do path_provider)
  final pastaDeCopias = await ligarPastaDeCopias();
  final backupAutomatico = await PreferenciasCopiasLocais().lerAutomatica();
  // a pasta da biblioteca de presets (BB4): no macOS também vem do path_provider
  final pastaBiblioteca = await ligarPastaBiblioteca();
  runApp(ProviderScope(
    overrides: [
      idiomaSalvoProvider.overrideWithValue(salvo),
      temaSalvoProvider.overrideWithValue(tema),
      pausaSalvaProvider.overrideWithValue(pausa == null ? null : Duration(milliseconds: pausa)),
      registroEmArquivoProvider.overrideWithValue(arquivoDeRegistro),
      pastaDeCopiasProvider.overrideWithValue(pastaDeCopias),
      copiaAutomaticaSalvaProvider.overrideWithValue(backupAutomatico),
      pastaBibliotecaProvider.overrideWithValue(pastaBiblioteca),
      // "Abrir com" o app: argumentos no Windows/Linux, canal no macOS (BB5)
      arquivosAbertosProvider.overrideWithValue(ArquivosAbertos.daPlataforma(argumentos)),
    ],
    child: const AppAnagram(),
  ));
}
