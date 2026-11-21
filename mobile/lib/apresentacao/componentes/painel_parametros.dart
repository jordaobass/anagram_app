// Parâmetros do bloco selecionado em knobs grandes, todos à vista: a tela
// rola, então esconder parâmetro atrás de página só custava toques. O
// paramétrico vem em bandas (ver arranjo_parametros.dart) e os blocos de 3
// bandas, no painel próprio (ver painel_multibanda.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../aplicacao/estado/controlador_editor.dart';
import '../../aplicacao/provedores.dart';
import '../../nucleo/catalogo/arranjo_multibanda.dart';
import '../../nucleo/catalogo/arranjo_parametros.dart';
import '../../nucleo/catalogo/definicao_bloco.dart';
import '../../nucleo/modelo/bloco_preset.dart';
import '../tema/tokens.dart';
import 'cabecalho_bloco.dart';
import 'cartao_banda.dart';
import 'controle_no_painel.dart';
import 'controle_parametro.dart';
import 'painel_multibanda.dart';
import 'seletor_gabinete.dart';
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
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CabecalhoBloco(bloco: bloco, definicao: definicao, cena: cena),
      const SizedBox(height: Espacos.m),
      SeletorGabinete(bloco: bloco, definicao: definicao),
      if (arranjoMultibanda(definicao.uri) case final arranjo?)
        PainelMultibanda(arranjo: arranjo, bloco: bloco, definicao: definicao, cena: cena, parametros: parametros)
      else
        LayoutBuilder(builder: (context, restricoes) {
        final grupos = agruparParametros(definicao, parametros);
        if (grupos.length > 1) {
          return Wrap(alignment: WrapAlignment.center, spacing: Espacos.m, runSpacing: Espacos.m, children: [
            for (final g in grupos) _grupo(context, ref, g, bloco, definicao, cena),
          ]);
        }
        final tamanho = _tamanhoQueCabe(restricoes.maxWidth, parametros.length);
        return Wrap(
          alignment: compacto ? WrapAlignment.spaceEvenly : WrapAlignment.center,
          spacing: _vao,
          runSpacing: Espacos.l,
          children: [
            if (parametros.isEmpty)
              Text(l.semParametros, style: Theme.of(context).textTheme.bodyMedium),
            for (final p in grupos.single.parametros) _controle(context, ref, p, bloco, definicao, cena, tamanho),
          ],
        );
      }),
    ]);
  }

  /// Uma banda do paramétrico: título com a chave dela e os knobs de nome
  /// curto; desligada, os knobs ficam apagados mas ainda se ajustam.
  Widget _grupo(BuildContext context, WidgetRef ref, GrupoParametros grupo, BlocoPreset bloco,
      DefinicaoBloco definicao, int cena) {
    final chave = grupo.chave;
    final ligada = chave == null || DefinicaoParametro.estaLigado(_valor(bloco, chave, cena));
    return CartaoBanda(
      key: ValueKey('banda-${grupo.banda?.name ?? 'outros'}'),
      titulo: grupo.banda == null ? null : AppLocalizations.of(context).nomeDaBanda(grupo.banda!),
      chave: chave == null ? null : _chaveDaBanda(context, ref, chave, bloco, definicao, cena),
      ligada: ligada,
      controles: [
        for (final p in grupo.parametros) _controle(context, ref, p, bloco, definicao, cena, Medidas.knobCompacto),
      ],
    );
  }

  Widget _chaveDaBanda(BuildContext context, WidgetRef ref, DefinicaoParametro chave, BlocoPreset bloco,
      DefinicaoBloco definicao, int cena) {
    final ligada = DefinicaoParametro.estaLigado(_valor(bloco, chave, cena));
    final l = AppLocalizations.of(context);
    return ChaveParametro(
      chave: ValueKey('chave-${chave.simbolo}'),
      nome: chave.nome,
      ligado: ligada,
      cor: Cores.daFamilia(definicao.familia),
      texto: ligada ? l.valorLigado : l.valorDesligado,
      aoMudar: (novo) => ControleNoPainel.alterar(ref, chave, bloco)(novo ? 1 : 0, arrastando: false),
    );
  }

  static num _valor(BlocoPreset bloco, DefinicaoParametro p, int cena) => ControleNoPainel.valorNaCena(bloco, p, cena);

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
    for (final simbolo in bloco.simbolosGuardados)
      DefinicaoParametro(
        simbolo: simbolo,
        nome: nomeEstimado(simbolo),
        minimo: 0,
        maximo: ((bloco.valorBase(simbolo) ?? 0).abs() * 2).clamp(10, 100000),
        padrao: bloco.valorBase(simbolo) ?? 0,
      ),
  ];
}

String _nomeEstimadoPadrao(String simbolo) => '$simbolo (faixa estimada)';
