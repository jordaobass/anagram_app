// A seção "Pedaleira" das Configurações: os ajustes globais da Anagram, que
// valem para todos os presets. Relê ao abrir e no "Atualizar"; mostra só o
// que o app sabe gravar e diz, numa linha, o que ainda falta (DECISOES PD2).
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
        Expanded(child: Text(l.pdDica, style: tema.bodyMedium?.copyWith(color: Cores.textoSecundario))),
        TextButton.icon(
          key: const ValueKey('atualizar-ajustes'),
          onPressed: estado.carregando ? null : ref.read(controladorAjustesProvider.notifier).carregar,
          icon: const Icon(Icons.refresh),
          label: Text(l.pdAtualizar),
        ),
      ]),
      const SizedBox(height: Espacos.m),
      if (estado.lidos == null) _semLeitura(l, estado) else ..._cartoes(l, tema),
    ]);
  }

  Widget _semLeitura(AppLocalizations l, EstadoAjustes estado) {
    if (!estado.falhouLeitura) return Text(l.pdLendo, key: const ValueKey('lendo-ajustes'));
    return Row(children: [
      Expanded(child: Text(l.pdFalhaLer, style: const TextStyle(color: Cores.erro))),
      TextButton(onPressed: ref.read(controladorAjustesProvider.notifier).carregar, child: Text(l.pdTentarDeNovo)),
    ]);
  }

  List<Widget> _cartoes(AppLocalizations l, TextTheme tema) => [
        _CartaoGrupo(titulo: l.pdSaidas, grupo: GrupoAjuste.saidas, forma: FormaControle.fader, cor: Cores.mixerGlobal),
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
        const SizedBox(height: Espacos.s),
        Text(l.pdPendentes, key: const ValueKey('ajustes-pendentes'),
            style: tema.bodySmall?.copyWith(color: Cores.textoSecundario)),
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
          : Text(dica!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Cores.textoSecundario)),
      filhos: [
        for (final a in ajustes) ControleAjuste(definicao: a, forma: forma, cor: cor),
        AvisoErroAjustes(ids: {for (final a in ajustes) a.id}),
      ],
    );
  }
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
      desenho: Text(l.pdPlacaDica, style: tema.bodySmall?.copyWith(color: Cores.textoSecundario)),
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
