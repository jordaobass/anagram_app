// Abre um endereço no navegador do sistema (a página da release, no aviso de
// versão nova). Atrás de um tipo para os testes trocarem por um falso.
import 'package:url_launcher/url_launcher.dart';

import '../nucleo/registro.dart';

/// `true` se o sistema abriu o endereço.
typedef AbridorDeLink = Future<bool> Function(Uri endereco);

Future<bool> abrirNoNavegador(Uri endereco) async {
  try {
    final abriu = await launchUrl(endereco, mode: LaunchMode.externalApplication);
    if (!abriu) registro.w('link: o sistema não abriu $endereco');
    return abriu;
  } on Object catch (erro) {
    registro.w('link: falha ao abrir $endereco', error: erro);
    return false;
  }
}
