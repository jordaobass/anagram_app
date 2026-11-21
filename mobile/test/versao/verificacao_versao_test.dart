// Ao abrir, o app pergunta ao GitHub qual é a última release: avisa só de
// versão estável e maior, cala diante de falha (que vai para o log com a
// causa e o endereço), não chama a rede com a opção desligada e respeita o
// "lembrar depois" até sair uma versão maior que a dispensada.
import 'package:anagram_app/aplicacao/versao_app.dart';
import 'package:anagram_app/aplicacao/versao_nova.dart';
import 'package:anagram_app/dados/preferencias_versao.dart';
import 'package:anagram_app/plataforma/consulta_http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoio/versao_falsa.dart';

const _ultimaRelease = 'https://api.github.com/repos/jordaobass/anagram_app/releases/latest';

ProviderContainer _app(GithubFalso github,
    {PreferenciasVersaoEmMemoria? preferencias, String versao = '0.1.17', bool disponivel = true}) {
  final container = ProviderContainer(overrides: [
    consultaHttpProvider.overrideWithValue(github),
    preferenciasVersaoProvider.overrideWithValue(preferencias ?? PreferenciasVersaoEmMemoria()),
    verificacaoVersaoDisponivelProvider.overrideWithValue(disponivel),
    versaoAppProvider.overrideWith((ref) async => versao),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<EstadoVersaoNova> _abrir(ProviderContainer app) async {
  await app.read(versaoNovaProvider.notifier).verificarAoAbrir();
  return app.read(versaoNovaProvider);
}

void main() {
  test('should_announce_the_release_when_github_has_a_newer_version', () async {
    final github = GithubFalso(tag: 'v0.1.18');

    final estado = await _abrir(_app(github));

    expect(estado.avisoNaBarra?.versao, '0.1.18');
    expect(estado.avisoNaBarra?.pagina, Uri.parse(GithubFalso.paginaDa('v0.1.18')));
    expect(github.pedidos.single.endereco, Uri.parse(_ultimaRelease));
  });

  test('should_ask_only_once_with_a_short_limit_and_no_user_data', () async {
    final github = GithubFalso(tag: 'v0.1.18');

    await _abrir(_app(github));

    final pedido = github.pedidos.single;
    expect(pedido.cabecalhos, {'Accept': 'application/vnd.github+json', 'User-Agent': 'AnagramApp/0.1.17'});
    expect(pedido.endereco.hasQuery, isFalse);
    expect(pedido.limite, lessThanOrEqualTo(const Duration(seconds: 5)));
  });

  test('should_not_announce_when_the_published_version_is_the_same_or_older', () async {
    for (final tag in ['v0.1.17', 'v0.1.9', '0.1.16']) {
      final estado = await _abrir(_app(GithubFalso(tag: tag)));

      expect(estado.avisoNaBarra, isNull, reason: tag);
      expect(estado.situacao, isA<VersaoEmDia>(), reason: tag);
    }
  });

  test('should_not_announce_a_prerelease_a_draft_or_an_invalid_tag', () async {
    for (final github in [
      GithubFalso(tag: 'v0.2.0', prerelease: true),
      GithubFalso(tag: 'v0.2.0', draft: true),
      GithubFalso(tag: 'nightly'),
    ]) {
      expect((await _abrir(_app(github))).avisoNaBarra, isNull, reason: github.tag);
    }
  });

  test('should_stay_silent_and_log_the_cause_and_address_when_the_request_fails', () async {
    final registro = RegistroCapturado.ligar();

    final estado = await _abrir(_app(GithubFalso(erro: const ErroConsultaHttp(403))));

    expect(estado.avisoNaBarra, isNull);
    expect(estado.situacao, isA<VersaoSemResposta>());
    expect(registro.texto, contains('resposta HTTP 403'));
    expect(registro.texto, contains(_ultimaRelease));
  });

  test('should_make_no_request_when_the_check_is_turned_off', () async {
    final github = GithubFalso(tag: 'v9.9.9');
    final preferencias = PreferenciasVersaoEmMemoria(const ConfiguracaoVersao(verificarAoAbrir: false));

    final estado = await _abrir(_app(github, preferencias: preferencias));

    expect(github.pedidos, isEmpty);
    expect(estado.avisoNaBarra, isNull);
  });

  test('should_make_no_request_on_a_platform_without_the_check', () async {
    final github = GithubFalso(tag: 'v9.9.9');

    await _abrir(_app(github, disponivel: false));

    expect(github.pedidos, isEmpty);
  });

  test('should_keep_quiet_about_a_dismissed_version_until_a_greater_one_comes_out', () async {
    final github = GithubFalso(tag: 'v0.1.18');
    final preferencias = PreferenciasVersaoEmMemoria();
    final app = _app(github, preferencias: preferencias);
    await _abrir(app);

    await app.read(versaoNovaProvider.notifier).dispensar();
    expect(app.read(versaoNovaProvider).avisoNaBarra, isNull);
    expect(preferencias.salvo.dispensada, '0.1.18');

    expect((await _abrir(_app(github, preferencias: preferencias))).avisoNaBarra, isNull,
        reason: 'reabrir com a mesma versão publicada não avisa de novo');
    github.tag = 'v0.1.19';
    expect((await _abrir(_app(github, preferencias: preferencias))).avisoNaBarra?.versao, '0.1.19');
  });

  test('should_check_right_away_when_the_option_is_turned_back_on', () async {
    final github = GithubFalso(tag: 'v0.1.18');
    final preferencias = PreferenciasVersaoEmMemoria(const ConfiguracaoVersao(verificarAoAbrir: false));
    final app = _app(github, preferencias: preferencias);
    await _abrir(app);

    await app.read(versaoNovaProvider.notifier).definirVerificacao(true);

    expect(preferencias.salvo.verificarAoAbrir, isTrue);
    expect(github.pedidos, hasLength(1));
    expect(app.read(versaoNovaProvider).avisoNaBarra?.versao, '0.1.18');
  });
}
