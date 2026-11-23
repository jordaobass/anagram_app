// Monitoramento de Entrada no clique em CONECTAR (DECISOES CA5). Ainda não
// decidido: o app mostra o pedido do sistema ANTES de abrir o USB, em vez de
// deixar o IOKit pedir no meio da abertura (o app "pulando no Dock" do relato).
// Negado: nem abre o USB; a tela de conectar explica e leva aos Ajustes.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../nucleo/registro.dart';
import '../plataforma/acesso_entrada_mac.dart';
import 'conectar_ao_abrir.dart';

/// Pedido do sistema; os testes trocam por um falso.
final pedidoAcessoEntradaMacProvider = Provider<ConsultaAcessoEntrada>((ref) => pedirAcessoEntradaMac);

/// `true` se o clique pode abrir o USB. Fora do Mac, sempre.
final liberacaoEntradaMacProvider = Provider<Future<bool> Function()>((ref) => () => _liberarParaClique(ref));

Future<bool> _liberarParaClique(Ref ref) async {
  if (ref.read(plataformaDeAberturaProvider) != PlataformaDeAbertura.macOS) return true;
  final atual = await ref.read(acessoEntradaMacProvider)();
  final acesso = atual == AcessoEntrada.naoDecidido ? await _pedir(ref) : atual;
  // desconhecido = build nativo sem a consulta: abre como antes
  if (acesso == AcessoEntrada.concedido || acesso == AcessoEntrada.desconhecido) return true;
  registro.i('conexão: Monitoramento de Entrada ${acesso.name}; USB não aberto, a tela explica o caminho nos Ajustes');
  return false;
}

Future<AcessoEntrada> _pedir(Ref ref) async {
  registro.i('conexão: Monitoramento de Entrada não decidido; pedindo ao macOS antes de abrir o USB');
  final depois = await ref.read(pedidoAcessoEntradaMacProvider)();
  registro.i('conexão: pedido de Monitoramento de Entrada respondeu ${depois.name}');
  return depois;
}
