// Parâmetros do bloco selecionado em knobs grandes, todos à vista: a tela
// rola, então esconder parâmetro atrás de página só custava toques. O
// Parametric EQ tem a tela do Global EQ (ver painel_eq_parametrico.dart) e
// os blocos de 3 bandas, o painel próprio (ver painel_multibanda.dart).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/arranjo_sintetizador.dart';
import '../../nucleo/catalogo/arranjo_utilitario.dart';
import '../../nucleo/catalogo/curva_eq_parametrico.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/catalogo/explicacoes_parametros.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cabecalho_bloco.dart';
import 'controle_no_painel.dart';
import 'explicacao_parametro.dart';
import 'painel_eq_parametrico.dart';
import 'painel_multibanda.dart';
import 'painel_sintetizador.dart';
import 'painel_utilitario.dart';
import 'seletor_gabinete.dart';
import 'seletor_tone3000.dart';
import '../../l10n/app_localizations.dart';
import '../textos.dart';
import 'casa_arrastavel.dart' show arrastoComMouse;

class PainelParametros extends ConsumerWidget {
  const PainelParametros({super.key, required this.tamanhoKnob, this.compacto = false});

  final double tamanhoKnob;

  /// No celular os knobs se espalham pela fileira; no amplo ficam agrupados no centro.
  final bool compacto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(editorProvider);
    final bloco = estado.blocoSelecionado;
    if (bloco == null) return const SizedBox.shrink();
    // sem o catálogo, faixas seriam chutadas: espera em vez de editar errado
    if (!ref.watch(catalogoProvider).hasValue) return const Center(child: CircularProgressIndicator());
    final definicao = ref.watch(definicaoBlocoProvider(bloco.uri));
    final l = AppLocalizations.of(context);
    final parametros = parametrosVisiveis(definicao, bloco, nomeEstimado: l.faixaEstimada);
    final cena = estado.atual!.cenaAtiva;
    final explicacoes = ref.watch(explicacoesProvider).value ?? ExplicacoesParametros.vazio;
    // o bloco aberto, para cada controle explicar o parâmetro DESTE pedal
    return ContextoExplicacao(
      uri: definicao.uri,
      explicacoes: explicacoes,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CabecalhoBloco(bloco: bloco, definicao: definicao, cena: cena),
        const SizedBox(height: Espacos.m),
        SeletorGabinete(bloco: bloco, definicao: definicao),
        SeletorTone3000(bloco: bloco, definicao: definicao),
        _painelDoBloco(ref, parametros, bloco, definicao, cena),
      ]),
    );
  }

  /// Os blocos com tela própria (multibanda, paramétrico, synth, bateria e
  /// metrônomo); o resto, knobs.
  Widget _painelDoBloco(
      WidgetRef ref, List<DefinicaoParametro> parametros, BlocoPreset bloco, DefinicaoBloco definicao, int cena) {
    if (arranjoMultibanda(definicao.uri) case final arranjo?) {
      return PainelMultibanda(arranjo: arranjo, bloco: bloco, definicao: definicao, cena: cena, parametros: parametros);
    }
    if (ehEqParametrico(definicao.uri)) {
      return PainelEqParametrico(bloco: bloco, definicao: definicao, cena: cena, parametros: parametros);
    }
    if (arranjoSintetizador(definicao.uri) case final arranjo?) {
      return PainelSintetizador(arranjo: arranjo, bloco: bloco, definicao: definicao, cena: cena, parametros: parametros);
    }
    if (arranjoUtilitario(definicao.uri) case final arranjo?) {
      return PainelUtilitario(
          arranjo: arranjo, bloco: bloco, definicao: definicao, cena: cena, parametros: parametros, tamanhoKnob: tamanhoKnob);
    }
    return LayoutBuilder(
        builder: (context, restricoes) => _controles(context, ref, restricoes.maxWidth, parametros, bloco, definicao, cena));
  }

  Widget _controles(BuildContext context, WidgetRef ref, double largura, List<DefinicaoParametro> parametros,
      BlocoPreset bloco, DefinicaoBloco definicao, int cena) {
    final controles = agruparParametros(definicao, parametros).expand((g) => g.parametros).toList();
    final tamanho = _tamanhoQueCabe(largura, controles.length);
    return Wrap(
      alignment: compacto ? WrapAlignment.spaceEvenly : WrapAlignment.center,
      spacing: _vao,
      runSpacing: Espacos.l,
      children: [
        if (parametros.isEmpty)
          Text(AppLocalizations.of(context).semParametros, style: Theme.of(context).textTheme.bodyMedium),
        for (final p in controles) _controle(context, ref, p, bloco, definicao, cena, tamanho),
      ],
    );
  }

  double get _vao => compacto ? Espacos.m : Espacos.xl;

  /// No amplo, encolhe o knob (até o tamanho do celular) para não deixar
  /// um parâmetro sozinho numa segunda fileira.
  double _tamanhoQueCabe(double largura, int quantidade) {
    if (compacto || quantidade == 0) return tamanhoKnob;
    final porControle = (largura + _vao) / quantidade - _vao - Espacos.l;
    return porControle.clamp(Medidas.knobCompacto, tamanhoKnob);
  }

  Widget _controle(BuildContext context, WidgetRef ref, ParametroNoPainel noPainel, BlocoPreset bloco,
          DefinicaoBloco definicao, int cena, double tamanho) =>
      ControleNoPainel(
        parametro: noPainel.parametro,
        rotulo: noPainel.rotulo,
        bloco: bloco,
        definicao: definicao,
        cena: cena,
        tamanho: tamanho,
      );
}

/// No lugar do painel quando nenhum bloco está selecionado (preset novo,
/// cadeia vazia): como pôr e mudar efeitos de lugar, já que nenhum dos dois
/// gestos se descobre olhando a grade.
class DicaMontarCadeia extends StatelessWidget {
  const DicaMontarCadeia({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Espacos.l),
        child: Text(
          AppLocalizations.of(context).dicaMontarCadeiaPara(mouse: arrastoComMouse),
          key: const ValueKey('dica-montar-cadeia'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Cores.textoSecundario),
        ),
      );
}

/// Parâmetros do catálogo; para bloco desconhecido, os que o preset guarda,
/// com faixa estimada (marcada no nome por [nomeEstimado], no idioma da tela).
const _papeisSemControle = {'bypass', 'reset', 'hostTempo'};

/// Sem papel no catálogo, mas também ação e não ajuste: o "Reset Peak Hold"
/// do paramétrico zera o medidor de pico, que pelo USB não chega ao app.
const _simbolosSemControle = {'peakreset'};

List<DefinicaoParametro> parametrosVisiveis(DefinicaoBloco definicao, BlocoPreset bloco,
    {String Function(String simbolo) nomeEstimado = _nomeEstimadoPadrao}) {
  // "bypass" é o próprio liga/desliga do bloco (o botão LIGADO do cabeçalho);
  // "reset" e "hostTempo" são ações do aparelho, que o preset nem guarda.
  // Mostrados como controle, seriam botões que não fazem o que dizem
  if (definicao.parametros.isNotEmpty) {
    return [for (final p in definicao.parametros) if (!_papeisSemControle.contains(p.papel) && !_simbolosSemControle.contains(p.simbolo)) p];
  }
  return [
    for (final simbolo in bloco.simbolosGuardados) _parametroEstimado(simbolo, bloco.valorBase(simbolo) ?? 0, nomeEstimado),
  ];
}

/// A faixa sai do valor guardado e sempre o contém: positivo vai de 0 ao
/// dobro; negativo (um Level em −6 dB) fica simétrica em torno do zero.
/// Cortar o valor faria o knob mostrar o limite e o 1º movimento saltar (RV3).
DefinicaoParametro _parametroEstimado(String simbolo, num valor, String Function(String) nomeEstimado) {
  final amplitude = max((valor.abs() * 2).clamp(10, 100000), valor.abs());
  return DefinicaoParametro(
    simbolo: simbolo,
    nome: nomeEstimado(simbolo),
    minimo: valor < 0 ? -amplitude : 0,
    maximo: amplitude,
    padrao: valor,
  );
}

String _nomeEstimadoPadrao(String simbolo) => '$simbolo (faixa estimada)';
