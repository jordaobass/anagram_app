// Atribuir o parâmetro de um knob a um pot ou ao pedal de expressão. Abre
// pelo botão direito no knob e pela ação do leitor de tela; no toque, a
// mesma atribuição sai do cartão do controle (ver dialogo_controle.dart).
// Cada item diz o que o controle já tem, para não tomar um pot sem querer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../../nucleo/modelo/controles_pedaleira.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'item_de_menu.dart';

/// Os controles que movem um parâmetro contínuo: os pots e o pedal.
final controlesDeParametro = [...IdControle.doTipo(TipoControle.pot), IdControle.expressao];

Future<void> abrirMenuAtribuir(
    BuildContext context, WidgetRef ref, PosicaoBloco posicao, DefinicaoParametro parametro, Offset ponto) async {
  final controles = ref.read(editorProvider).atual?.controles;
  if (controles == null) return;
  final l = AppLocalizations.of(context);
  final escolhido = await showMenu<IdControle>(
    context: context,
    position: RelativeRect.fromLTRB(ponto.dx, ponto.dy, ponto.dx, ponto.dy),
    items: [
      for (final id in controlesDeParametro)
        itemDeControle(context, id,
            controle: controles[id],
            rotulo: l.ctlAtribuirA(l.rotuloControle(id)),
            icone: id.tipo == TipoControle.pot ? Icons.tune : Icons.straighten,
            jaAqui: _temOParametro(controles[id], posicao, parametro.simbolo)),
    ],
  );
  if (escolhido != null) await ref.read(editorProvider.notifier).atribuirParametro(escolhido, posicao, parametro);
}

/// O item de um controle: o que fazer à esquerda, o que ele tem à direita.
PopupMenuItem<T> itemDeControle<T>(BuildContext context, T valor,
    {required ControlePedaleira? controle,
    required String rotulo,
    required bool jaAqui,
    required IconData icone,
    String? chave}) {
  final l = AppLocalizations.of(context);
  final situacao = jaAqui ? l.ctlJaAqui : (controle == null ? l.ctlLivre : controle.nome);
  return PopupMenuItem<T>(
    key: ValueKey(chave ?? 'atribuir-${valor is IdControle ? valor.chave : valor}'),
    value: valor,
    enabled: !jaAqui,
    height: alturaItemDeMenu,
    child: LinhaDeMenu(
      icone: icone,
      ativo: !jaAqui,
      child: Row(children: [
        Expanded(child: Text(rotulo)),
        const SizedBox(width: Espacos.l),
        DetalheDeMenu(situacao),
      ]),
    ),
  );
}

bool _temOParametro(ControlePedaleira? controle, PosicaoBloco posicao, String simbolo) =>
    controle?.alvos.any((alvo) => alvo.mesmoParametro(posicao, simbolo)) ?? false;

/// Os controles que já movem o parâmetro do bloco em [posicao].
List<IdControle> controlesDoParametro(Map<IdControle, ControlePedaleira> controles, PosicaoBloco posicao, String simbolo) =>
    [for (final MapEntry(:key, :value) in controles.entries) if (_temOParametro(value, posicao, simbolo)) key];
