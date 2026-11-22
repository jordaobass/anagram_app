// Os tons do TONE3000 da pedaleira conectada, lidos uma vez por conexão: a
// lista de fábrica leva ~1,6 s na pedaleira real, e reler a cada painel
// aberto travaria a fila do protocolo. Trocar de pedaleira (ou desconectar)
// muda o estado da conexão e descarta a lista.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../nucleo/resultado.dart';
import '../../nucleo/tone3000/tons_da_pedaleira.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

final tonsDaPedaleiraProvider = FutureProvider<TonsDaPedaleira>((ref) async {
  if (ref.watch(conexaoProvider) is! Conectada) return const TonsDaPedaleira.indisponivel();
  final repositorio = ref.read(conexaoProvider.notifier).repositorio;
  if (repositorio == null) return const TonsDaPedaleira.indisponivel();
  return switch (await repositorio.lerTonsDaPedaleira()) {
    Sucesso(:final valor) => valor,
    Falha() => const TonsDaPedaleira.indisponivel(falhou: true),
  };
});
