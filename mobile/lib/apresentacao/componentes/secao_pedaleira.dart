// A seção "Pedaleira" das Configurações: os ajustes globais da Anagram, que
// valem para todos os presets. Relê ao abrir e no "Atualizar". O modo dos
// footswitches se troca aqui; saídas, Global EQ e entrada só se leem — a
// pedaleira aceita esses valores pelo USB, mas não os aplica ao som, e o
// aviso no topo diz isso antes de qualquer controle (DECISOES AJ1, AJ2).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_ajustes.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../tema/tokens.dart';
import 'cartao_global_eq.dart';
import 'cartao_secao_synth.dart';
import 'controles_ajuste.dart';
import 'seletor_modo_footswitches.dart';

class SecaoPedaleira extends ConsumerStatefulWidget {
  const SecaoPedaleira({super.key});

  @override
  ConsumerState<SecaoPedaleira> createState() => _SecaoPedaleiraState();
}

class _SecaoPedaleiraState extends ConsumerState<SecaoPedaleira> {
  /// O "Input Gain" do Global EQ rola até o cartão Entrada, como o botão da
  /// tela da pedaleira leva à tela de ganho de entrada.
  final _entrada = GlobalKey();

  void _irParaEntrada() {
    final alvo = _entrada.currentContext;
    if (alvo != null) Scrollable.ensureVisible(alvo, duration: Duracoes.curta);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(controladorAjustesProvider.notifier).carregar());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final estado = ref.watch(controladorAjustesProvider);
    final tema = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(l.pdDica, style: tema.bodyMedium?.copyWith(color: context.cores.textoSecundario))),
        TextButton.icon(
          key: const ValueKey('atualizar-ajustes'),
          onPressed: estado.carregando ? null : ref.read(controladorAjustesProvider.notifier).carregar,
          icon: const Icon(Icons.refresh),
          label: Text(l.pdAtualizar),
        ),
      ]),
      const SizedBox(height: Espacos.m),
      _AvisoSemAcesso(texto: l.pdSemAcesso),
      const SizedBox(height: Espacos.m),
      if (estado.lidos == null) _semLeitura(l, estado) else ..._cartoes(l),
    ]);
  }

  Widget _semLeitura(AppLocalizations l, EstadoAjustes estado) {
    if (!estado.falhouLeitura) return Text(l.pdLendo, key: const ValueKey('lendo-ajustes'));
    return Row(children: [
      Expanded(child: Text(l.pdFalhaLer, style: TextStyle(color: context.cores.erro))),
      TextButton(onPressed: ref.read(controladorAjustesProvider.notifier).carregar, child: Text(l.pdTentarDeNovo)),
    ]);
  }

  List<Widget> _cartoes(AppLocalizations l) => [
        CartaoSecaoSynth(
          titulo: l.fmTitulo,
          largura: double.infinity,
          filhos: const [SizedBox(width: double.infinity, child: SeletorModoFootswitches())],
        ),
        const SizedBox(height: Espacos.m),
        _CartaoGrupo(titulo: l.pdSaidas, grupo: GrupoAjuste.saidas, forma: FormaControle.fader, cor: context.cores.mixerGlobal),
        const SizedBox(height: Espacos.m),
        CartaoGlobalEq(aoIrParaEntrada: _irParaEntrada),
        const SizedBox(height: Espacos.m),
        _CartaoGrupo(
            key: _entrada,
            titulo: l.pdEntrada,
            grupo: GrupoAjuste.entrada,
            forma: FormaControle.knob,
            dica: l.pdEntradaDica),
        const SizedBox(height: Espacos.m),
        const _CartaoPlaca(),
      ];
}

class _CartaoGrupo extends StatelessWidget {
  const _CartaoGrupo({super.key, required this.titulo, required this.grupo, required this.forma, this.cor, this.dica});

  final String titulo;
  final GrupoAjuste grupo;
  final FormaControle forma;
  final Color? cor;
  final String? dica;

  @override
  Widget build(BuildContext context) {
    final ajustes = ajustesConfirmados(grupo).toList();
    return CartaoSecaoSynth(
      titulo: titulo,
      largura: double.infinity,
      desenho: dica == null
          ? null
          : Text(dica!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      filhos: [for (final a in ajustes) ControleAjuste(definicao: a, forma: forma, cor: cor)],
    );
  }
}

/// O que o app não consegue fazer com saídas, Global EQ e entrada, em
/// destaque e antes dos controles: sem ele, o fader que não se mexe pareceria
/// defeito.
class _AvisoSemAcesso extends StatelessWidget {
  const _AvisoSemAcesso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('aviso-sem-acesso-ajustes'),
        padding: const EdgeInsets.all(Espacos.m),
        decoration: BoxDecoration(
          color: context.cores.painelElevado,
          border: Border.all(color: context.cores.aluminio),
          borderRadius: BorderRadius.circular(Raios.painel),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline, color: context.cores.aluminioClaro),
          const SizedBox(width: Espacos.s),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.cores.texto))),
        ]),
      );
}

/// A placa de som: só leitura, como texto (a pedaleira não responde a
/// gravações nela, DECISOES PD1).
class _CartaoPlaca extends ConsumerWidget {
  const _CartaoPlaca();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final placa = ref.watch(controladorAjustesProvider.select((e) => e.lidos?.placa)) ?? const {};
    final tema = Theme.of(context).textTheme;
    return CartaoSecaoSynth(
      key: const ValueKey('cartao-placa'),
      titulo: l.pdPlaca,
      largura: double.infinity,
      desenho: Text(l.pdPlacaDica, style: tema.bodySmall?.copyWith(color: context.cores.textoSecundario)),
      filhos: [
        for (final e in placa.entries)
          SizedBox(
            width: Medidas.larguraItemPlaca,
            child: Text('${e.key}: ${e.value}', style: tema.bodyMedium),
          ),
      ],
    );
  }
}
