// Balão que diz o que o parâmetro faz com o som naquele pedal. O painel
// informa qual bloco está aberto ([ContextoExplicacao]); os controles só
// perguntam pelo parâmetro, então valem em qualquer painel abaixo dele.
//
// Onde abre (DECISOES TT2): no computador, com o mouse parado sobre o rótulo;
// no toque, com um toque no rótulo (a dica fica no cabeçalho do bloco: um "?"
// em cada rótulo cortava nomes que cabiam, como "LOW SHELF"). Segurar continua sendo
// "voltar ao padrão" no knob e o arraste continua girando — o balão não
// disputa nenhum dos dois gestos.
import 'package:flutter/material.dart';

import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/explicacoes_parametros.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';
import '../textos.dart';

class ContextoExplicacao extends InheritedWidget {
  const ContextoExplicacao({super.key, required this.uri, required this.explicacoes, required super.child});

  final String uri;
  final ExplicacoesParametros explicacoes;

  /// O texto no idioma da tela, ou null fora de um painel ou sem explicação.
  static String? de(BuildContext context, DefinicaoParametro parametro) {
    final contexto = context.dependOnInheritedWidgetOfExactType<ContextoExplicacao>();
    final texto = contexto?.explicacoes.de(contexto.uri, parametro);
    return texto?.em(AppLocalizations.of(context).localeName.split('_').first);
  }

  @override
  bool updateShouldNotify(ContextoExplicacao antigo) => antigo.uri != uri || antigo.explicacoes != explicacoes;
}

/// Faixa do parâmetro como a pessoa lê: "De -60 dB a 0 dB" ou as opções.
String? faixaDoParametro(AppLocalizations l, DefinicaoParametro p) {
  const maximoOpcoesListadas = 6;
  if (p.alternavel) return null;
  if (p.opcoes.isNotEmpty) {
    return p.opcoes.length <= maximoOpcoesListadas
        ? p.opcoes.join(' · ')
        : l.kbFaixa(p.opcoes.first, p.opcoes.last);
  }
  return l.kbFaixa(l.valorDe(p, p.minimo), l.valorDe(p, p.maximo));
}

/// Envolve [filho] no balão quando há explicação; sem ela, devolve [filho].
/// [aoTocar]: o toque abre o balão (rótulos); senão, segurar abre (chaves).
Widget comExplicacao(BuildContext context, DefinicaoParametro parametro, Widget filho,
    {String? nome, bool aoTocar = true}) {
  final texto = ContextoExplicacao.de(context, parametro);
  if (texto == null) return filho;
  final l = AppLocalizations.of(context);
  final tema = Theme.of(context).textTheme;
  final faixa = faixaDoParametro(l, parametro);
  return Tooltip(
    key: ValueKey('explicacao-${parametro.simbolo}'),
    waitDuration: Duracoes.esperaExplicacao,
    triggerMode: aoTocar ? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
    // o rótulo fica em cima do knob: abrindo para cima, o balão não tapa o controle
    preferBelow: false,
    constraints: const BoxConstraints(maxWidth: Medidas.larguraExplicacao),
    padding: const EdgeInsets.all(Espacos.m),
    decoration: BoxDecoration(
      color: Cores.painelElevado,
      borderRadius: BorderRadius.circular(Raios.controle),
      border: Border.all(color: Cores.filete),
    ),
    richMessage: TextSpan(children: [
      TextSpan(text: nome ?? parametro.nome, style: tema.titleSmall?.copyWith(color: Cores.texto)),
      if (faixa != null) TextSpan(text: '\n$faixa', style: tema.labelMedium?.copyWith(color: Cores.textoSecundario)),
      TextSpan(text: '\n$texto', style: tema.bodyMedium?.copyWith(color: Cores.texto)),
    ]),
    child: filho,
  );
}

/// Rótulo em cima do controle; com explicação, é ele que abre o balão.
class RotuloParametro extends StatelessWidget {
  const RotuloParametro({super.key, required this.parametro, required this.texto});

  final DefinicaoParametro parametro;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.labelMedium;
    final rotulo = Text(texto.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: estilo);
    // o cursor de ajuda só onde há o que explicar
    if (ContextoExplicacao.de(context, parametro) == null) return rotulo;
    return comExplicacao(context, parametro, MouseRegion(cursor: SystemMouseCursors.help, child: rotulo));
  }
}
