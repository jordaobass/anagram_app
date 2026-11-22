// Ajustes globais da pedaleira (mixer, Global EQ, entrada): SÓ LEITURA. Na
// bancada de 2026-11-22 a Anagram aceitou `edit_settings` nessas chaves e a
// releitura mostrou o valor, mas o som não mudou (DECISOES AJ1): elas são o
// estado da interface do aparelho, não o que ele toca. Por isso este
// controlador só lê `export_settings` — ao abrir e no "Atualizar" — e não tem
// caminho de envio. O modo dos footswitches, que funciona, tem controlador
// próprio e reaproveita esta leitura (DECISOES FM2).
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
  const EstadoAjustes({this.lidos, this.carregando = false, this.falhouLeitura = false});

  /// O último `export_settings`; nulo = ainda não lido.
  final AjustesPedaleira? lidos;
  final bool carregando;
  final bool falhouLeitura;

  num? valor(DefinicaoAjuste definicao) => lidos?.valor(definicao);

  /// A definição com a faixa que contém o valor lido da pedaleira.
  DefinicaoAjuste faixa(DefinicaoAjuste definicao) => definicao.abrangendo(lidos?.valor(definicao));

  EstadoAjustes copiar({AjustesPedaleira? lidos, bool? carregando, bool? falhouLeitura}) => EstadoAjustes(
        lidos: lidos ?? this.lidos,
        carregando: carregando ?? this.carregando,
        falhouLeitura: falhouLeitura ?? this.falhouLeitura,
      );
}

class ControladorAjustes extends Notifier<EstadoAjustes> {
  /// Cresce a cada troca de conexão: o que volta de um pedido feito antes
  /// dela é da pedaleira anterior e é descartado.
  int _geracao = 0;

  @override
  EstadoAjustes build() {
    // trocou de pedaleira ou desconectou: o que estava na tela não vale mais
    ref.listen(conexaoProvider, (_, _) {
      _geracao++;
      state = const EstadoAjustes();
    });
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
}
