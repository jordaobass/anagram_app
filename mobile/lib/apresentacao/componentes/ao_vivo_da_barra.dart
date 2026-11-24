// "AO VIVO" + interruptor, com a latência do último envio ao lado. A
// latência é discreta (texto secundário) enquanto a pedaleira responde bem e
// só ganha cor quando atrasa: âmbar acima de 500 ms, vermelho acima de 1500
// (DECISOES BS1). A frase inteira ("ida e volta…") vai na dica.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../tema/tokens.dart';

/// Acima disto a resposta da pedaleira já se sente ao girar um knob.
const latenciaLenta = Duration(milliseconds: 500);

/// Acima disto a edição ao vivo deixa de parecer ao vivo.
const latenciaMuitoLenta = Duration(milliseconds: 1500);

enum NivelLatencia { normal, lenta, muitoLenta }

NivelLatencia nivelDaLatencia(Duration latencia) => latencia > latenciaMuitoLenta
    ? NivelLatencia.muitoLenta
    : latencia > latenciaLenta
        ? NivelLatencia.lenta
        : NivelLatencia.normal;

class AoVivoDaBarra extends ConsumerWidget {
  const AoVivoDaBarra({super.key, required this.compacta});

  final bool compacta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aoVivo = ref.watch(editorProvider.select((e) => e.aoVivo));
    final latencia = ref.watch(editorProvider.select((e) => e.latencia));
    final tema = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (latencia != null && aoVivo && !compacta) ...[
          LatenciaDaBarra(latencia),
          const SizedBox(width: Espacos.s),
        ],
        // desligado precisa saltar aos olhos: a pedaleira não ouve as edições
        Container(
          key: const ValueKey('rotulo-ao-vivo'),
          padding: const EdgeInsets.symmetric(horizontal: Espacos.s, vertical: Espacos.xxs),
          color: aoVivo ? Colors.transparent : context.cores.fitaAlerta,
          child: Text(aoVivo ? l.aoVivo : l.aoVivoDesligado,
              style: tema.labelLarge?.copyWith(color: aoVivo ? context.cores.tallyTinta : context.cores.sobreAlerta)),
        ),
        Switch(
          key: const ValueKey('interruptor-ao-vivo'),
          value: aoVivo,
          activeThumbColor: context.cores.tally,
          onChanged: ref.read(editorProvider.notifier).definirAoVivo,
        ),
      ],
    );
  }
}

/// "42 ms" em figuras tabulares, para o número não dançar a cada envio.
class LatenciaDaBarra extends StatelessWidget {
  const LatenciaDaBarra(this.latencia, {super.key});

  final Duration latencia;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ms = latencia.inMilliseconds;
    final cor = switch (nivelDaLatencia(latencia)) {
      NivelLatencia.normal => context.cores.textoSecundario,
      NivelLatencia.lenta => context.cores.tallyTinta,
      NivelLatencia.muitoLenta => context.cores.erro,
    };
    return Tooltip(
      message: l.latenciaDica(ms),
      child: Text(
        l.latenciaCurta(ms),
        key: const ValueKey('latencia-ao-vivo'),
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
      ),
    );
  }
}
