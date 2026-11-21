// Bancada da revisão 0.1.16: roda as camadas reais do app (conexão,
// biblioteca, editor, organizar) contra a Anagram REAL plugada no PC.
//   flutter test integration_test/bancada_revisao_test.dart -d windows \
//     --dart-define=BANCADA_ESCRITA=1 --dart-define=BANCADA_AREA=user \
//     --dart-define=BANCADA_RASCUNHOS=42A,42B --dart-define=BANCADA_ORIGEM=01A
// Sem os quatro dart-define nada roda. Só grava nos dois slots de rascunho, e
// só se os dois estiverem VAZIOS no início; no fim apaga os dois e confere que
// voltaram a vazio. O preset de origem é só lido. Faça backup da área antes.
import 'package:anagram_app/aplicacao/estado/controlador_biblioteca.dart';
import 'package:anagram_app/aplicacao/estado/controlador_conexao.dart';
import 'package:anagram_app/aplicacao/estado/controlador_editor.dart';
import 'package:anagram_app/aplicacao/estado/controlador_organizar.dart';
import 'package:anagram_app/aplicacao/estado/estado_conexao.dart';
import 'package:anagram_app/aplicacao/casos_de_uso/salvar_no_slot.dart';
import 'package:anagram_app/aplicacao/provedores.dart';
import 'package:anagram_app/apresentacao/componentes/passo_controle.dart';
import 'package:anagram_app/dados/repositorio_pedaleira.dart';
import 'package:anagram_app/nucleo/catalogo/catalogo_blocos.dart';
import 'package:anagram_app/nucleo/catalogo/definicao_bloco.dart';
import 'package:anagram_app/nucleo/catalogo/escala_parametro.dart';
import 'package:anagram_app/nucleo/modelo/bloco_preset.dart';
import 'package:anagram_app/nucleo/modelo/documento_preset.dart';
import 'package:anagram_app/nucleo/modelo/slot_preset.dart';
import 'package:anagram_app/nucleo/registro.dart';
import 'package:anagram_app/nucleo/resultado.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// bool.fromEnvironment só aceita "true": "=1" seria lido como falso
const _escrever = String.fromEnvironment('BANCADA_ESCRITA') == '1' || bool.fromEnvironment('BANCADA_ESCRITA');
const _area = String.fromEnvironment('BANCADA_AREA');
const _rascunhos = String.fromEnvironment('BANCADA_RASCUNHOS');
const _origem = String.fromEnvironment('BANCADA_ORIGEM');
const _uriPitch = 'urn:darkglass:PitchShifter';

final _configurado = _escrever && _area.isNotEmpty && _rascunhos.split(',').length == 2 && _origem.isNotEmpty;

void _log(String texto) => registro.i('BANCADA $texto');

Future<void> _esperar(bool Function() pronto, String oque, {Duration prazo = const Duration(seconds: 40)}) async {
  final limite = DateTime.now().add(prazo);
  while (!pronto()) {
    if (DateTime.now().isAfter(limite)) fail('não ficou pronto a tempo: $oque');
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<DocumentoPreset?> _ler(RepositorioPedaleira repositorio, SlotPreset slot) async =>
    switch (await repositorio.lerPreset(slot, area: _area)) {
      Sucesso(:final valor) => valor,
      Falha(:final erro) => fail('leitura de ${slot.rotulo} falhou: $erro'),
    };

/// Primeiro parâmetro contínuo guardado num bloco do catálogo.
({PosicaoBloco posicao, DefinicaoParametro parametro, num valor})? _knobContinuo(
    DocumentoPreset doc, CatalogoBlocos catalogo) {
  for (final linha in const [1, 2]) {
    for (final bloco in doc.blocosDaLinha(linha)) {
      for (final p in catalogo.definicao(bloco.uri).parametros) {
        final valor = bloco.valorNaCena(p.simbolo, doc.cenaAtiva);
        if (!p.ehDiscreto && valor != null && p.maximo > p.minimo) {
          return (posicao: bloco.posicao, parametro: p, valor: valor);
        }
      }
    }
  }
  return null;
}

PosicaoBloco _casaVazia(DocumentoPreset doc) {
  for (var casa = 1; casa <= PosicaoBloco.casasPorLinha; casa++) {
    final posicao = PosicaoBloco(1, casa);
    if (doc.bloco(posicao) == null) return posicao;
  }
  throw StateError('linha 1 cheia');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bancada 0.1.16: knob salvo, seta discreta ao vivo e clonar por cima', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final x = SlotPreset.doRotulo(_rascunhos.split(',')[0]);
    final y = SlotPreset.doRotulo(_rascunhos.split(',')[1]);
    final origem = SlotPreset.doRotulo(_origem);
    expect({x, y, origem}.length, 3, reason: 'rascunhos e origem precisam ser slots diferentes');

    container.read(bibliotecaProvider);
    final editor = container.read(editorProvider.notifier);
    final conexao = container.read(conexaoProvider.notifier);
    await conexao.conectarAparelho();
    await _esperar(() => container.read(conexaoProvider) is! Conectando, 'conexão');
    expect(container.read(conexaoProvider), isA<Conectada>());
    _log('conectada: ${container.read(conexaoProvider)}');
    final repositorio = conexao.repositorio!;
    await _esperar(() => container.read(bibliotecaProvider).areas.temAreas && !container.read(bibliotecaProvider).carregando,
        'áreas');
    await container.read(bibliotecaProvider.notifier).selecionarArea(_area);
    await _esperar(() => !container.read(bibliotecaProvider).carregando, 'lista da área');
    expect(container.read(bibliotecaProvider).areaSelecionada, _area);

    // trava de segurança: só grava se os dois rascunhos estão vazios AGORA
    final ocupados = container.read(bibliotecaProvider).ocupados;
    for (final slot in [x, y]) {
      expect(ocupados.containsKey(slot), isFalse, reason: '${slot.rotulo} está ocupado na lista: não gravo');
      expect(await _ler(repositorio, slot), isNull, reason: '${slot.rotulo} não está vazio: não gravo');
    }
    final fonte = (await _ler(repositorio, origem))!;
    expect(fonte.blocosDaLinha(1), isNotEmpty, reason: 'a origem precisa ter blocos');
    final catalogo = await container.read(catalogoProvider.future);
    await editor.definirAoVivo(false);

    try {
      // ---- 1. Salvar com mudança só de knob
      await editor.abrirSlot(x);
      expect(container.read(editorProvider).atual, isNull);
      await editor.carregarDocumento(fonte.comNome('BANCADA ${x.rotulo}').comUuid(novoUuidPreset()));
      final criado = await editor.salvar();
      expect(criado, isA<PresetSalvo>(), reason: 'rascunho em ${x.rotulo}: $criado');
      _log('1: rascunho gravado em ${x.rotulo} "${(criado as PresetSalvo).relido.nome}" uuid ${criado.relido.uuid}');

      final knob = _knobContinuo(container.read(editorProvider).atual!, catalogo);
      expect(knob, isNotNull, reason: 'a origem não tem parâmetro contínuo do catálogo');
      final p = knob!.parametro;
      var novo = p.valorDepoisDoPasso(knob.valor, fracaoPassoGrosso);
      if (novo == knob.valor) novo = p.valorDepoisDoPasso(knob.valor, -fracaoPassoGrosso);
      expect(novo, isNot(knob.valor));
      editor.alterarParametro(p.simbolo, novo, arrastando: false, nome: p.nome, posicao: knob.posicao);
      final salvoKnob = await editor.salvar();
      expect(salvoKnob, isA<PresetSalvo>(), reason: 'salvar só com knob: $salvoKnob');
      final relidoKnob = (await _ler(repositorio, x))!;
      final cena = relidoKnob.cenaAtiva;
      final gravado = relidoKnob.bloco(knob.posicao)!.valorNaCena(p.simbolo, cena)!;
      _log('1: ${p.nome} (${p.simbolo}) em ${knob.posicao}: antes ${knob.valor}, enviado $novo, relido $gravado');
      expect((gravado - novo).abs() < 1e-4 * (novo.abs() > 1 ? novo.abs() : 1), isTrue);
      expect(relidoKnob.uuid, criado.relido.uuid, reason: 'Salvar no mesmo slot mantém o uuid');

      // ---- 3. Passo de seta em parâmetro discreto, ao vivo e gravado
      final definicaoPitch = catalogo.definicao(_uriPitch);
      final semitom = definicaoPitch.parametro('Semitone')!;
      final casa = _casaVazia(container.read(editorProvider).atual!);
      expect(await editor.adicionarBloco(casa, definicaoPitch), isNull);
      final base = container.read(editorProvider).atual!.bloco(casa)!.valorNaCena('Semitone', cena) ?? semitom.padrao;
      final antigo = semitom.valorDe(semitom.fracaoDe(base) + fracaoPassoFino); // a conta de antes da K1
      final seta = semitom.valorDepoisDoPasso(base, fracaoPassoFino);
      final setaAbaixo = semitom.valorDepoisDoPasso(seta, -fracaoPassoFino);
      _log('3: Semitone base $base; seta pela conta antiga = $antigo; seta 0.1.16 = $seta; seta para baixo = $setaAbaixo');
      expect(seta, isNot(base));
      expect(setaAbaixo, base);
      await editor.definirAoVivo(true); // manda o preset com o Pitch Shifter ao vivo
      editor.alterarParametro('Semitone', seta, arrastando: false, nome: semitom.nome, posicao: casa);
      final aoVivo = await repositorio.tocarAoVivo(container.read(editorProvider).atual!);
      _log('3: try_anagram_preset com Semitone=$seta -> $aoVivo; aviso do editor: ${container.read(editorProvider).aviso}');
      expect(aoVivo, isA<Sucesso<void>>());
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(container.read(editorProvider).aviso, isNull, reason: 'a pedaleira recusou o envio ao vivo');
      await editor.definirAoVivo(false);
      final salvoPitch = await editor.salvar();
      expect(salvoPitch, isA<PresetSalvo>(), reason: 'salvar com Pitch Shifter: $salvoPitch');
      final relidoPitch = (await _ler(repositorio, x))!;
      final semitomGravado = relidoPitch.bloco(casa)?.valorNaCena('Semitone', cena);
      _log('3: relido ${x.rotulo} bloco ${relidoPitch.bloco(casa)?.uri} em $casa: Semitone $semitomGravado');
      expect(relidoPitch.bloco(casa)?.uri, _uriPitch);
      expect(semitomGravado, seta);

      // ---- 2. Clonar X por cima de Y (Y também é rascunho)
      await editor.abrirSlot(y);
      await editor.carregarDocumento(fonte.comNome('BANCADA ${y.rotulo}').comUuid(novoUuidPreset()));
      final criadoY = await editor.salvar();
      expect(criadoY, isA<PresetSalvo>(), reason: 'rascunho em ${y.rotulo}: $criadoY');
      final uuidYAntes = (criadoY as PresetSalvo).relido.uuid;
      await editor.abrirSlot(x); // o editor fica no X, como quem clona pela lista
      final organizar = container.read(organizarProvider.notifier)..iniciar(OperacaoPreset.clonar, x);
      final pergunta = await organizar.concluir(y);
      _log('2: clonar ${x.rotulo} -> ${y.rotulo} sem confirmar: $pergunta '
          '${pergunta is DestinoOcupado ? '"${pergunta.nomeAtual}"' : ''}');
      expect(pergunta, isA<DestinoOcupado>());
      expect((await _ler(repositorio, y))!.uuid, uuidYAntes, reason: 'sem confirmar nada pode ser gravado');
      final feito = await organizar.concluir(y, confirmado: true);
      expect(feito, isA<Organizado>(), reason: 'clonar confirmado: $feito');
      final relidoX = (await _ler(repositorio, x))!;
      final relidoY = (await _ler(repositorio, y))!;
      _log('2: ${y.rotulo} agora "${relidoY.nome}" uuid ${relidoY.uuid}; '
          '${x.rotulo} uuid ${relidoX.uuid}; ${y.rotulo} tinha uuid $uuidYAntes');
      expect(relidoY.nome, relidoX.nome);
      expect(relidoY.uuid, isNot(relidoX.uuid));
      expect(relidoY.uuid, isNot(uuidYAntes));
      expect(relidoY.comUuid(relidoX.uuid!).paraJson(), relidoX.paraJson(), reason: 'conteúdo do clone difere');
      expect(container.read(bibliotecaProvider).resumo(y)?.nome, relidoX.nome);
    } finally {
      // os dois estavam vazios no início (conferido acima): voltam a vazio
      for (final slot in [x, y]) {
        final limpeza = await repositorio.excluir(slot, area: _area);
        final depois = await repositorio.lerPreset(slot, area: _area);
        _log('limpeza ${slot.rotulo}: $limpeza; releitura: ${depois is Sucesso<DocumentoPreset?> && depois.valor == null ? 'VAZIO' : depois}');
      }
      await conexao.desconectar();
    }
    for (final slot in [x, y]) {
      expect(await _lerDeNovo(container, slot), isNull);
    }
  }, skip: !_configurado, timeout: const Timeout(Duration(minutes: 10)));
}

/// Depois de desconectar, confere de novo por uma conexão nova.
Future<DocumentoPreset?> _lerDeNovo(ProviderContainer container, SlotPreset slot) async {
  final conexao = container.read(conexaoProvider.notifier);
  if (conexao.repositorio == null) {
    await conexao.conectarAparelho();
    await _esperar(() => container.read(conexaoProvider) is! Conectando, 'reconexão');
  }
  final lido = await _ler(conexao.repositorio!, slot);
  return lido;
}
