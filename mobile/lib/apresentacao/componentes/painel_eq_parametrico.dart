// Painel do bloco Parametric EQ com a mesma tela do Global EQ (é o mesmo
// equalizador): seletor Gain/Frequency/Width nas cores da pedaleira, a curva
// somada com os pontos arrastáveis, as 6 bandas com o valor do modo num chip
// e o Reset. O que só o bloco tem fica embaixo: a chave de cada seção (banda
// desligada sai da curva e fica apagada), os cortes passa-altas/passa-baixas
// e o ganho geral. Tudo pelo caminho do editor: ao vivo, cena, desfazer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../l10n/app_localizations.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/curva_eq_parametrico.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import '../textos.dart';
import 'alteracao_em_grupo.dart';
import 'cartao_grupo_eq.dart';
import 'controle_no_painel.dart';
import 'dialogo_confirmar.dart';
import 'tela_eq.dart';

class PainelEqParametrico extends ConsumerStatefulWidget {
  const PainelEqParametrico(
      {super.key, required this.bloco, required this.definicao, required this.cena, required this.parametros});

  final BlocoPreset bloco;
  final DefinicaoBloco definicao;
  final int cena;
  final List<DefinicaoParametro> parametros;

  @override
  ConsumerState<PainelEqParametrico> createState() => _PainelEqParametricoState();
}

class _PainelEqParametricoState extends ConsumerState<PainelEqParametrico> {
  ModoEq _modo = ModoEq.gain;

  num _valor(DefinicaoParametro p) => ControleNoPainel.valorNaCena(widget.bloco, p, widget.cena);

  @override
  Widget build(BuildContext context) {
    final grupos = agruparParametros(widget.definicao, widget.parametros);
    final curva = bandasDaCurva(grupos, _valor);
    return Column(key: const ValueKey('painel-eq-parametrico'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TelaEq(
        modo: _modo,
        aoEscolherModo: (m) => setState(() => _modo = m),
        acoes: TextButton(
            key: const ValueKey('eq-bloco-reset'), onPressed: _reset, child: Text(AppLocalizations.of(context).pdEqReset)),
        chaveCurva: const ValueKey('curva-eq-bloco'),
        bandasDaCurva: [for (final (_, banda) in curva) banda],
        ganhoGeral: ganhoGeralDoBloco(grupos, _valor),
        aoArrastar: (i, frequencia, ganho, {required arrastando}) =>
            _arrastar(curva[i], frequencia, ganho, arrastando: arrastando),
        bandas: [
          for (final g in grupos)
            if (ehBandaDoSeletor(g)) _BandaDoBloco(grupo: g, modo: _modo, painel: widget),
        ],
      ),
      const SizedBox(height: Espacos.l),
      Wrap(alignment: WrapAlignment.center, spacing: Espacos.m, runSpacing: Espacos.m, children: [
        for (final g in grupos)
          if (!ehBandaDoSeletor(g))
            CartaoGrupoEq(grupo: g, bloco: widget.bloco, definicao: widget.definicao, cena: widget.cena),
      ]),
    ]);
  }

  /// Arrastar o ponto muda frequência e ganho da banda; no corte, só a frequência.
  /// Ao soltar ([arrastando] falso) o valor final vai ao vivo na hora, como no knob.
  void _arrastar(BandaDaCurva alvo, double frequencia, double ganho, {required bool arrastando}) {
    final (grupo, banda) = alvo;
    final editor = ref.read(editorProvider.notifier);
    void mudar(ModoEq modo, double valor) {
      final p = parametroDoModo(grupo, modo)?.parametro;
      if (p == null) return;
      editor.alterarParametro(p.simbolo, p.limitar(valor),
          arrastando: arrastando, nome: p.nome, posicao: widget.bloco.posicao, padrao: p.padrao);
    }

    mudar(ModoEq.freq, frequencia);
    if (!banda.ehCorte) mudar(ModoEq.gain, ganho);
  }

  /// Pergunta e volta todos os parâmetros ao padrão do catálogo, com desfazer.
  Future<void> _reset() async {
    final l = AppLocalizations.of(context);
    final sim = await confirmar(context,
        titulo: l.eqbResetTitulo,
        texto: l.eqbResetTexto,
        rotuloCancelar: l.cancelar,
        rotuloConfirmar: l.pdEqResetConfirmar,
        chaveConfirmar: const ValueKey('confirmar-reset-eq-bloco'));
    if (!sim || !mounted) return;
    await alterarEmGrupo(context, ref,
        bloco: widget.bloco,
        definicao: widget.definicao,
        cena: widget.cena,
        valores: {for (final p in widget.parametros) p.simbolo: p.padrao},
        aviso: l.eqbResetFeito);
  }
}

/// Uma das 6 bandas: a chave da seção em cima e o knob do modo, com o valor
/// num chip da cor do modo e, no rótulo, o outro número da banda (como a
/// pedaleira: "35.0 Hz [−18.0 dB]"). Desligada, fica apagada mas ajustável.
class _BandaDoBloco extends StatelessWidget {
  const _BandaDoBloco({required this.grupo, required this.modo, required this.painel});

  final GrupoParametros grupo;
  final ModoEq modo;
  final PainelEqParametrico painel;

  @override
  Widget build(BuildContext context) {
    final noModo = parametroDoModo(grupo, modo);
    final outro = parametroDoModo(grupo, modo == ModoEq.freq ? ModoEq.gain : ModoEq.freq);
    final chave = grupo.chave;
    final ligada = chave == null || DefinicaoParametro.estaLigado(ControleNoPainel.valorNaCena(painel.bloco, chave, painel.cena));
    return Column(key: ValueKey('banda-eq-bloco-${grupo.banda!.name}'), mainAxisSize: MainAxisSize.min, children: [
      if (chave != null)
        ChaveDaSecao(
            chave: chave, bloco: painel.bloco, definicao: painel.definicao, cena: painel.cena, empilhada: true),
      const SizedBox(height: Espacos.xs),
      if (noModo != null)
        Opacity(
          opacity: ligada ? 1 : Medidas.opacidadeBandaDesligada,
          child: ControleNoPainel(
            parametro: noModo.parametro,
            rotulo: outro == null ? noModo.rotulo : _texto(context, outro.parametro),
            bloco: painel.bloco,
            definicao: painel.definicao,
            cena: painel.cena,
            tamanho: Medidas.knobCompacto,
            forma: FormaControle.knob,
            corChip: context.cores.doModoEq(modo),
          ),
        ),
    ]);
  }

  String _texto(BuildContext context, DefinicaoParametro p) =>
      AppLocalizations.of(context).valorDe(p, ControleNoPainel.valorNaCena(painel.bloco, p, painel.cena));
}
