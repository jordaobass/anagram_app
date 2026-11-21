// Aviso de versão nova (DECISOES AV1–AV3): ao abrir, uma consulta à última
// release do GitHub; se for maior que a do app, a barra avisa até a pessoa
// baixar ou dispensar aquela versão.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dados/preferencias_versao.dart';
import '../nucleo/versao/release_publicada.dart';
import '../nucleo/versao/versao_semantica.dart';
import '../plataforma/abrir_link.dart';
import '../plataforma/consulta_http.dart';
import 'busca_ultima_release.dart';
import 'versao_app.dart';

sealed class SituacaoVersao {
  const SituacaoVersao();
}

final class VersaoNaoVerificada extends SituacaoVersao {
  const VersaoNaoVerificada();
}

final class VersaoEmDia extends SituacaoVersao {
  const VersaoEmDia();
}

final class VersaoDisponivel extends SituacaoVersao {
  const VersaoDisponivel(this.release);
  final ReleasePublicada release;
}

/// A consulta falhou (sem rede, limite da API, resposta estranha); a causa foi para o log.
final class VersaoSemResposta extends SituacaoVersao {
  const VersaoSemResposta();
}

class EstadoVersaoNova {
  const EstadoVersaoNova({this.configuracao = const ConfiguracaoVersao(), this.situacao = const VersaoNaoVerificada()});

  final ConfiguracaoVersao configuracao;
  final SituacaoVersao situacao;

  /// A release que a barra anuncia: a disponível, se não foi dispensada.
  ReleasePublicada? get avisoNaBarra {
    if (situacao case VersaoDisponivel(:final release)) {
      final dispensada = configuracao.dispensada;
      if (dispensada == null || ehMaisNova(release.versao, dispensada)) return release;
    }
    return null;
  }

  EstadoVersaoNova copiar({ConfiguracaoVersao? configuracao, SituacaoVersao? situacao}) =>
      EstadoVersaoNova(configuracao: configuracao ?? this.configuracao, situacao: situacao ?? this.situacao);
}

final preferenciasVersaoProvider = Provider<PreferenciasVersao>((ref) => PreferenciasVersaoLocais());

final consultaHttpProvider = Provider<ConsultaHttp>((ref) => criarConsultaHttp());

/// Desktop sim, celular e web não (os testes fixam).
final verificacaoVersaoDisponivelProvider = Provider<bool>((ref) => verificacaoVersaoDisponivel);

/// Abre a página da release no navegador (os testes trocam por um falso).
final abridorDeLinkProvider = Provider<AbridorDeLink>((ref) => abrirNoNavegador);

final versaoNovaProvider = NotifierProvider<ControladorVersaoNova, EstadoVersaoNova>(ControladorVersaoNova.new);

class ControladorVersaoNova extends Notifier<EstadoVersaoNova> {
  @override
  EstadoVersaoNova build() => const EstadoVersaoNova();

  /// Chamada uma vez, depois do primeiro quadro: nada aqui atrasa a abertura.
  Future<void> verificarAoAbrir() async {
    if (!ref.read(verificacaoVersaoDisponivelProvider)) return;
    final salva = await ref.read(preferenciasVersaoProvider).ler();
    if (!ref.mounted) return;
    state = state.copiar(configuracao: salva);
    if (salva.verificarAoAbrir) await _verificar();
  }

  /// Desligar não chama a rede; religar verifica na hora.
  Future<void> definirVerificacao(bool ligada) async {
    await _guardar(state.configuracao.copiar(verificarAoAbrir: ligada));
    ligada ? await _verificar() : state = state.copiar(situacao: const VersaoNaoVerificada());
  }

  /// "Lembrar depois": a versão anunciada só volta a avisar quando sair uma maior.
  Future<void> dispensar() async {
    if (state.avisoNaBarra case final release?) {
      await _guardar(state.configuracao.copiar(dispensada: release.versao));
    }
  }

  /// "Baixar": a página da release, onde estão os arquivos de cada sistema.
  Future<void> baixar(ReleasePublicada release) async {
    await ref.read(abridorDeLinkProvider)(release.pagina);
  }

  Future<void> _verificar() async {
    final atual = await ref.read(versaoAppProvider.future);
    final situacao = await BuscaUltimaRelease(ref.read(consultaHttpProvider)).verificar(atual);
    if (ref.mounted) state = state.copiar(situacao: situacao);
  }

  Future<void> _guardar(ConfiguracaoVersao configuracao) async {
    state = state.copiar(configuracao: configuracao);
    await ref.read(preferenciasVersaoProvider).gravar(configuracao);
  }
}
