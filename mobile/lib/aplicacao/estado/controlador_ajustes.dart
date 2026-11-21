// Ajustes globais da pedaleira (mixer, Global EQ, entrada): ler ao abrir,
// mudar ao vivo e conferir. O valor mexido aparece na hora; os envios saem
// juntos depois de uma pausa curta (o arraste de um fader não vira dezenas
// de `edit_settings`) e, gravado, o app relê para mostrar o que a pedaleira
// confirmou. Nada disso é do preset: não marca "não salvo" (DECISOES PD5).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dados/repositorio_pedaleira.dart';
import '../../nucleo/ajustes/ajustes_pedaleira.dart';
import '../../nucleo/ajustes/mapa_ajustes.dart';
import '../../nucleo/resultado.dart';
import 'controlador_conexao.dart';
import 'estado_conexao.dart';

final controladorAjustesProvider =
    NotifierProvider<ControladorAjustes, EstadoAjustes>(ControladorAjustes.new);

class EstadoAjustes {
  const EstadoAjustes({this.lidos, this.carregando = false, this.falhouLeitura = false,
      this.locais = const {}, this.comErro = const {}});

  /// O último `export_settings`; nulo = ainda não lido.
  final AjustesPedaleira? lidos;
  final bool carregando;
  final bool falhouLeitura;

  /// Valores mexidos que ainda não voltaram confirmados, por id do ajuste.
  final Map<String, num> locais;

  /// Ids cujo último envio a pedaleira recusou.
  final Set<String> comErro;

  num? valor(DefinicaoAjuste definicao) => locais[definicao.id] ?? lidos?.valor(definicao);

  /// A definição com a faixa que contém o valor lido da pedaleira.
  DefinicaoAjuste faixa(DefinicaoAjuste definicao) => definicao.abrangendo(lidos?.valor(definicao));

  EstadoAjustes copiar({AjustesPedaleira? lidos, bool? carregando, bool? falhouLeitura,
          Map<String, num>? locais, Set<String>? comErro}) =>
      EstadoAjustes(
        lidos: lidos ?? this.lidos,
        carregando: carregando ?? this.carregando,
        falhouLeitura: falhouLeitura ?? this.falhouLeitura,
        locais: locais ?? this.locais,
        comErro: comErro ?? this.comErro,
      );
}

class ControladorAjustes extends Notifier<EstadoAjustes> {
  /// Pausa antes de enviar: junta o arraste num pedido só.
  static const espera = Duration(milliseconds: 150);

  final Map<String, num> _aEnviar = {};
  Timer? _relogio;

  /// Cresce a cada troca de conexão: o que volta de um pedido feito antes
  /// dela é da pedaleira anterior e é descartado.
  int _geracao = 0;

  @override
  EstadoAjustes build() {
    ref.onDispose(() => _relogio?.cancel());
    // trocou de pedaleira ou desconectou: o que estava na tela não vale mais
    ref.listen(conexaoProvider, (_, _) => _esquecer());
    return const EstadoAjustes();
  }

  RepositorioPedaleira? get _repositorio =>
      ref.read(conexaoProvider) is Conectada ? ref.read(conexaoProvider.notifier).repositorio : null;

  Future<void> carregar() async {
    final repositorio = _repositorio;
    if (repositorio == null) return;
    final geracao = _geracao;
    state = state.copiar(carregando: true, falhouLeitura: false);
    final lido = await repositorio.lerAjustesGlobais();
    if (geracao != _geracao) return;
    state = switch (lido) {
      Sucesso(:final valor) => state.copiar(lidos: valor, carregando: false),
      Falha() => state.copiar(carregando: false, falhouLeitura: true),
    };
  }

  /// Mostra [valor] na hora e agenda o envio. Ajuste pendente (sem chave)
  /// não sai daqui: a pedaleira não o conhece por esse nome.
  void alterar(DefinicaoAjuste definicao, num valor) {
    if (!definicao.confirmado) return;
    final limitado = state.faixa(definicao).limitar(valor);
    state = state.copiar(
      locais: {...state.locais, definicao.id: limitado},
      comErro: {...state.comErro}..remove(definicao.id),
    );
    _aEnviar[definicao.id] = limitado;
    _relogio?.cancel();
    _relogio = Timer(espera, () => unawaited(enviarAgora()));
  }

  /// Envia o que está agendado e relê; devolve se a pedaleira aceitou.
  Future<bool> enviarAgora() async {
    _relogio?.cancel();
    final repositorio = _repositorio;
    if (_aEnviar.isEmpty || repositorio == null) return _aEnviar.isEmpty;
    final ids = Map.of(_aEnviar);
    _aEnviar.clear();
    final geracao = _geracao;
    final gravado = await repositorio.gravarAjustesGlobais(_porChave(ids));
    final aceito = gravado is Sucesso;
    if (geracao != _geracao) return aceito;
    if (!aceito) state = state.copiar(comErro: {...state.comErro, ...ids.keys});
    await _reler(ids.keys);
    return aceito;
  }

  /// Relê e solta os valores locais confirmados; o que voltou a ser mexido
  /// enquanto isso continua local, para o fader não pular.
  Future<void> _reler(Iterable<String> enviados) async {
    final geracao = _geracao;
    final lido = await _repositorio?.lerAjustesGlobais();
    if (geracao != _geracao) return;
    final locais = Map.of(state.locais);
    for (final id in enviados) {
      if (!_aEnviar.containsKey(id)) locais.remove(id);
    }
    state = state.copiar(lidos: lido is Sucesso<AjustesPedaleira> ? lido.valor : state.lidos, locais: locais);
  }

  static Map<String, num> _porChave(Map<String, num> porId) => {
        for (final e in porId.entries) ?ajustePorIdOuChave(e.key)?.chave: e.value,
      };

  void _esquecer() {
    _geracao++;
    _relogio?.cancel();
    _aEnviar.clear();
    state = const EstadoAjustes();
  }
}
