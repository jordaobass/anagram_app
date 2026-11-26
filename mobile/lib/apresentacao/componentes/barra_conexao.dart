// Barra de cima em dois grupos (DECISOES BS1). À esquerda, o que diz respeito
// à pedaleira: o chip da conexão (que abre o menu com Desconectar) e o "Ao
// vivo" com a latência e, ao lado, o modo Biblioteca (presets prontos por
// banda, BB1). À direita, o que é do app: o indicador "IA" quando o
// MCP escuta e a engrenagem das Configurações, com um ponto quando há versão
// nova. O Sobre, a versão do app e o aviso de versão nova moram nas
// Configurações: a barra fica só com o que muda enquanto se toca.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_conexao.dart';
import '../../aplicacao/estado/estado_conexao.dart';
import '../tema/tokens.dart';
import 'acoes_da_barra.dart';
import 'ao_vivo_da_barra.dart';
import 'chip_conexao.dart';
import 'interruptor_biblioteca.dart';

class BarraConexao extends ConsumerWidget {
  const BarraConexao({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conectada = ref.watch(conexaoProvider) is Conectada;
    final medidas = MedidasDoTopo.daPlataforma;
    // Material (e não só a cor do Container): o realce de passar o mouse no
    // chip é pintado no Material mais próximo, que precisa estar à vista
    return _semMargemDeToque(context, medidas, Material(
      color: context.cores.painel,
      child: Container(
      constraints: BoxConstraints(minHeight: medidas.barraConexao),
      // o chip e a engrenagem já trazem o respiro do próprio alvo: o LED fica
      // a 16 px da borda, alinhado à lista de presets
      padding: const EdgeInsets.symmetric(horizontal: Espacos.s),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.cores.filete))),
      child: Row(children: [
        Expanded(
          child: Row(children: [
            Flexible(child: ChipConexao(compacta: compacta)),
            if (conectada) ...[
              const SizedBox(width: Espacos.l),
              AoVivoDaBarra(compacta: compacta),
              // presets prontos por banda (DECISOES BB1); no celular a barra
              // não tem espaço: o interruptor fica no topo da lista de presets
              if (!compacta) ...[const SizedBox(width: Espacos.m), const InterruptorBiblioteca(compacta: false)],
            ],
          ]),
        ),
        const SizedBox(width: Espacos.s),
        const IndicadorIa(),
        const BotaoConfiguracoes(),
      ]),
    )));
  }

  /// Com mouse, ícones, interruptor e botões da barra sem a margem de toque
  /// de 48 dp: ficam com 40 px, e a barra com 48 (DECISOES BC1).
  static Widget _semMargemDeToque(BuildContext context, MedidasDoTopo medidas, Widget barra) => medidas.comMouse
      ? Theme(data: Theme.of(context).copyWith(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap), child: barra)
      : barra;
}
