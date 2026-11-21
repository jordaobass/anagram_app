// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get desconectar => 'Desconectar';

  @override
  String get creditos => 'Créditos';

  @override
  String get estadoSemConexao => 'Sem conexão';

  @override
  String estadoConectando(String meio) {
    return 'Conectando ($meio)…';
  }

  @override
  String get estadoDemonstracao => 'Demonstração · sem pedaleira';

  @override
  String estadoConectada(String meio, String firmware) {
    return 'Anagram · $meio · $firmware';
  }

  @override
  String get estadoFalha => 'Falha na conexão';

  @override
  String conexaoSemantica(String texto) {
    return 'Conexão: $texto';
  }

  @override
  String idaEVolta(int ms) {
    return 'ida e volta $ms ms';
  }

  @override
  String get aoVivo => 'AO VIVO';

  @override
  String get aoVivoDesligado => 'AO VIVO DESLIGADO';

  @override
  String get conexaoPermissaoNegada =>
      'O sistema negou a permissão de acesso ao USB da Anagram. No Android, toque em Conectar de novo e aceite o pedido; no macOS, confira os ajustes de Privacidade e Segurança.';

  @override
  String get conexaoOcupada =>
      'A Anagram está plugada, mas outro programa a segura. Feche o Darkglass Suite e qualquer aba do navegador conectada à pedaleira.';

  @override
  String get conexaoSemAnagram =>
      'Nenhuma Anagram encontrada no USB. Confira o cabo e se ela está ligada.';

  @override
  String get conexaoSemResposta =>
      'A Anagram não respondeu. Desligue e ligue o cabo e tente de novo.';

  @override
  String get conexaoRespostaInvalida => 'Resposta inesperada da pedaleira.';

  @override
  String get erroOcupada => 'Outro programa está segurando a pedaleira.';

  @override
  String get erroDesconectado => 'A pedaleira está desconectada.';

  @override
  String get erroSemResposta => 'A pedaleira não respondeu a tempo.';

  @override
  String get erroRespostaInvalida =>
      'A pedaleira recusou ou mandou uma resposta inesperada.';

  @override
  String erroOperacaoEmCurso(String detalhe) {
    return '$detalhe';
  }

  @override
  String get erroSemSuporte =>
      'Esta plataforma não consegue falar com a pedaleira.';

  @override
  String get avisoDemonstracaoFalhou =>
      'Não foi possível abrir a demonstração.';

  @override
  String avisoFalhaInesperada(String meio) {
    return 'Não foi possível abrir $meio. Tente de novo; o detalhe ficou no log.';
  }

  @override
  String get avisoPedaleiraDesconectada =>
      'A pedaleira foi desconectada. Conecte de novo para continuar de onde parou.';

  @override
  String get avisoFormatoMaisNovo =>
      'Preset de formato mais novo que o deste app: campos desconhecidos são preservados.';

  @override
  String avisoPresetTrocado(String slot) {
    return 'A pedaleira devolveu outro preset para $slot (id diferente da lista). A lista foi relida; abra de novo.';
  }

  @override
  String get avisoAreaNaoTrocou => 'A pedaleira não trocou de área.';

  @override
  String naoSalvou(String motivo) {
    return 'Não salvou: $motivo';
  }

  @override
  String get salvarDesconectada =>
      'a pedaleira está desconectada. Conecte e tente de novo.';

  @override
  String get salvarSemResposta =>
      'a pedaleira não respondeu a tempo. O slot pode não ter sido gravado; confira antes de tentar de novo.';

  @override
  String get salvarRespostaInvalida =>
      'a pedaleira recusou ou devolveu uma resposta inesperada.';

  @override
  String get salvarOcupada => 'outro programa está segurando a pedaleira.';

  @override
  String get indisponivelIos =>
      'iPhone e iPad não deixam apps comuns abrirem a interface USB de controle da Anagram: isso exige um driver DriverKit com permissão especial da Apple, que este app ainda não tem. Use o modo demonstração aqui, ou edite pelo Mac, PC, Android ou Chrome.';

  @override
  String get indisponivelNavegador =>
      'Este navegador não tem WebHID. Use Chrome ou Edge no computador, ou o modo demonstração.';

  @override
  String get indisponivelSemUsb =>
      'Esta plataforma não tem acesso USB à pedaleira.';

  @override
  String get importacaoIlegivel => 'Não foi possível ler o arquivo.';

  @override
  String importacaoNaoEhPreset(String detalhe) {
    return 'Arquivo não é um preset da Anagram: $detalhe';
  }

  @override
  String get exportacaoFalhou => 'Não foi possível gravar o arquivo.';

  @override
  String get nomeVazio => 'O nome não pode ficar vazio.';

  @override
  String nomeComMarcador(String marcador) {
    return 'O nome não pode conter \"$marcador\".';
  }

  @override
  String get familiaDrive => 'Drive';

  @override
  String get familiaDinamica => 'Dinâmica';

  @override
  String get familiaEq => 'EQ';

  @override
  String get familiaFiltro => 'Filtro';

  @override
  String get familiaModulacao => 'Modulação';

  @override
  String get familiaDelay => 'Delay';

  @override
  String get familiaReverb => 'Reverb';

  @override
  String get familiaAmp => 'Amp';

  @override
  String get familiaGabinete => 'Gabinete';

  @override
  String get familiaUtilitario => 'Utilitário';

  @override
  String areaSemNome(int numero) {
    return 'Área $numero';
  }

  @override
  String get conecteTitulo => 'Conecte a Anagram pelo USB';

  @override
  String get conecteFecheSuite =>
      'Feche o Darkglass Suite antes: só um programa por vez controla a pedaleira.';

  @override
  String get abrirDemonstracao => 'ABRIR DEMONSTRAÇÃO';

  @override
  String get conectarPeloUsb => 'CONECTAR PELO USB';

  @override
  String get cancelar => 'CANCELAR';

  @override
  String versaoApp(String versao) {
    return 'v$versao';
  }

  @override
  String versaoAppComArte(String versao) {
    return 'v$versao · arte da pedaleira';
  }

  @override
  String get fecharAviso => 'Fechar aviso';

  @override
  String get largarEdicoesTitulo => 'Descartar edições?';

  @override
  String largarEdicoesTexto(String nome) {
    return '\"$nome\" tem mudanças que não foram salvas no slot.';
  }

  @override
  String get continuarEditando => 'CONTINUAR EDITANDO';

  @override
  String get largar => 'DESCARTAR';

  @override
  String get origem => 'ORIGEM';

  @override
  String get gravarAqui => 'Gravar aqui';

  @override
  String get pedaleiraNesteSlot => 'A pedaleira está neste slot';

  @override
  String get slotVazio => 'vazio';

  @override
  String get area => 'ÁREA';

  @override
  String largarAoTrocarArea(String nome) {
    return '\"$nome\" tem mudanças que não foram salvas e será fechado ao trocar de área.';
  }

  @override
  String get areaInativa =>
      'Esta área não está ativa na pedaleira: abrir um preset só toca, sem trocar o slot nela.';

  @override
  String get tornarAtiva => 'TORNAR ATIVA';

  @override
  String get salvar => 'SALVAR';

  @override
  String get salvarComo => 'SALVAR COMO…';

  @override
  String get descartar => 'DESCARTAR';

  @override
  String get menuArquivo => 'Importar ou exportar JSON';

  @override
  String get importarPreset => 'Importar preset (.json)';

  @override
  String get exportarPreset => 'Exportar preset (.json)';

  @override
  String presetImportado(String nome) {
    return '\"$nome\" importado. Salve no slot para gravar.';
  }

  @override
  String get presetExportado => 'Preset exportado.';

  @override
  String get presetCopiado =>
      'JSON do preset copiado para a área de transferência.';

  @override
  String presetSalvoEm(String nome, String slot) {
    return '\"$nome\" salvo em $slot.';
  }

  @override
  String substituirTitulo(String slot) {
    return 'Substituir $slot?';
  }

  @override
  String substituirTexto(String slot, String nome) {
    return 'O slot $slot guarda \"$nome\". Ele será substituído pelo preset editado.';
  }

  @override
  String get substituir => 'SUBSTITUIR';

  @override
  String get salvarComoEscolhaDestino =>
      'SALVAR COMO: TOQUE NO SLOT DE DESTINO';

  @override
  String slotSemantica(String slot) {
    return 'Slot $slot';
  }

  @override
  String get slotNovo => 'novo';

  @override
  String get abrirListaSemantica => ', abrir lista de presets';

  @override
  String renomearPresetSemantica(String nome) {
    return 'Renomear preset $nome';
  }

  @override
  String get avisoAoVivoDesligado =>
      'AO VIVO DESLIGADO — as edições ficam só no app, a pedaleira não muda.';

  @override
  String get avisoAudicao =>
      'AUDIÇÃO — a pedaleira continua no slot dela (sem USB MIDI).';

  @override
  String get naoSalvo => 'NÃO SALVO';

  @override
  String get escolhaUmPreset => 'Escolha um preset';

  @override
  String slotEstaVazio(String slot) {
    return 'O slot $slot está vazio';
  }

  @override
  String get escolhaUmPresetTexto =>
      'Ao abrir, ele passa a tocar na pedaleira. As mudanças soam na hora e só ficam gravadas quando você salva.';

  @override
  String get slotVazioTexto =>
      'Crie um preset aqui. Para trazer blocos de outro preset, use o ícone de copiar no painel do bloco e depois segure uma casa vazia para colar.';

  @override
  String get criarPresetAqui => 'CRIAR PRESET AQUI';

  @override
  String get verPresets => 'VER PRESETS';

  @override
  String get nomeDoPreset => 'Nome do preset';

  @override
  String get nome => 'Nome';

  @override
  String get renomear => 'RENOMEAR';

  @override
  String blocoPosicao(String familia, int linha, int casa) {
    return '$familia · linha $linha, casa $casa';
  }

  @override
  String get arrasteComMouse => 'Arraste na grade para mudar de lugar';

  @override
  String get arrasteNoToque => 'Segure e arraste na grade para mudar de lugar';

  @override
  String ligadoSoNaCena(int cena) {
    return 'LIGADO SÓ NA CENA $cena';
  }

  @override
  String desligadoSoNaCena(int cena) {
    return 'DESLIGADO SÓ NA CENA $cena';
  }

  @override
  String get copiarBloco => 'Copiar bloco';

  @override
  String get maisAcoesBloco => 'Mais ações do bloco';

  @override
  String get blocoLigadoSemantica => 'Bloco ligado';

  @override
  String get ligado => 'LIGADO';

  @override
  String get desligado => 'DESLIGADO';

  @override
  String get adicionarEfeitoMenu => 'Adicionar efeito…';

  @override
  String get colarAqui => 'Colar aqui';

  @override
  String get ligarDesligar => 'Ligar / desligar';

  @override
  String get moverEsquerda => 'Mover para a esquerda';

  @override
  String get moverDireita => 'Mover para a direita';

  @override
  String moverParaLinha(int linha) {
    return 'Mover para a linha $linha';
  }

  @override
  String get removerBloco => 'Remover bloco';

  @override
  String get semParametros => 'Este bloco não tem parâmetros ajustáveis.';

  @override
  String soNaCena(int cena) {
    return 'SÓ NA CENA $cena';
  }

  @override
  String get dicaMontarCadeia =>
      'Toque num + da grade para adicionar um efeito. Toque num bloco para ajustar; segure e arraste para mudar de lugar.';

  @override
  String faixaEstimada(String simbolo) {
    return '$simbolo (faixa estimada)';
  }

  @override
  String get adicionarEfeito => 'Adicionar efeito';

  @override
  String linhaCasa(int linha, int casa) {
    return 'Linha $linha, casa $casa';
  }

  @override
  String get buscarPeloNome => 'Buscar pelo nome';

  @override
  String get todos => 'Todos';

  @override
  String nenhumEfeito(String busca) {
    return 'Nenhum efeito com \"$busca\".';
  }

  @override
  String nenhumEfeitoNaFamilia(String busca, String familia) {
    return 'Nenhum efeito com \"$busca\" em $familia.';
  }

  @override
  String get sobreTitulo => 'Sobre e diagnóstico';

  @override
  String get creditoAutorTitulo => 'Autor';

  @override
  String get creditoAutor =>
      'jordao_bass · software livre, licença MIT. Gratuito, sem anúncios, sem compras no app e sem coleta de dados.';

  @override
  String get creditoProtocoloTitulo => 'Protocolo USB e catálogo de blocos';

  @override
  String get creditoProtocolo =>
      'Portado do projeto anagram-tone-maker, de basster6 — licença MIT (github.com/basster6/anagram-tone-maker).';

  @override
  String get creditoArteTitulo => 'Arte dos blocos';

  @override
  String get creditoArtePropria =>
      'Arte própria do app, por categoria de bloco.';

  @override
  String get creditoImagensTitulo => 'Imagens dos blocos';

  @override
  String creditoImagens(String credito) {
    return '$credito. Blocos sem imagem usam arte própria, por categoria.';
  }

  @override
  String get creditoFontesTitulo => 'Fontes';

  @override
  String get creditoFontes =>
      'Barlow e Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).';

  @override
  String get creditoAvisoTitulo => 'Aviso';

  @override
  String get creditoAviso =>
      'App não oficial, sem vínculo com a Darkglass Electronics. Anagram é marca do fabricante.';

  @override
  String get diagnosticoPausa => 'DIAGNÓSTICO · PAUSA ENTRE RELATÓRIOS USB';

  @override
  String get diagnosticoPausaTexto =>
      'Compare 0, 2 e 10 ms e veja a \"ida e volta\" na barra e no log.';

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaDoSistema => 'Do sistema';

  @override
  String get separadorDecimal => ',';

  @override
  String get valorLigado => 'Ligado';

  @override
  String get valorDesligado => 'Desligado';

  @override
  String get voltarAoPadrao => 'Voltar ao padrão';

  @override
  String voltouAoPadrao(String parametro) {
    return '$parametro voltou ao padrão.';
  }

  @override
  String get desfazer => 'DESFAZER';

  @override
  String get pausaAuto => 'Auto';

  @override
  String get linha1 => 'LINHA 1';

  @override
  String get linha2Paralela => 'LINHA 2 · PARALELA';

  @override
  String cenaSemantica(int numero, String nome) {
    return 'Cena $numero, $nome';
  }

  @override
  String cenaPadrao(int numero) {
    return 'Cena $numero';
  }

  @override
  String adicionarEfeitoNaCasa(int casa, int linha) {
    return 'Adicionar efeito na casa $casa, linha $linha';
  }

  @override
  String blocoLigado(String nome) {
    return '$nome, ligado';
  }

  @override
  String blocoDesligado(String nome) {
    return '$nome, desligado';
  }

  @override
  String get presets => 'Presets';

  @override
  String get txDicaMontarCadeiaMouse =>
      'Clique num + da grade para adicionar um efeito. Clique num bloco para ajustar e arraste para mudar de lugar.';

  @override
  String get txSlotVazioMouse =>
      'Crie um preset aqui. Para trazer blocos de outro preset, use o ícone de copiar no painel do bloco e depois clique com o botão direito numa casa vazia para colar.';

  @override
  String get txModoDemonstracaoTitulo => 'Modo demonstração';

  @override
  String get txSemUsbAquiCurto =>
      'Aqui o app não alcança a pedaleira pelo USB. Explore tudo no modo demonstração.';

  @override
  String get txPorQue => 'POR QUÊ?';

  @override
  String get txEntendi => 'ENTENDI';

  @override
  String get txAtiva => 'ATIVA';

  @override
  String get txAtivaNaPedaleiraDica => 'Área ativa na pedaleira';

  @override
  String get txEstadoAbrindoDemonstracao => 'Abrindo a demonstração…';

  @override
  String get cdNovoPreset => 'Novo preset';

  @override
  String get uiPresets => 'PRESETS';

  @override
  String get uiMaisAcoesPreset => 'Mais ações do preset';

  @override
  String get uiMenuArquivo => 'Importar ou exportar o preset';

  @override
  String get uiDescartarEdicoes => 'Descartar edições';

  @override
  String get uiFecharBiblioteca => 'Fechar';

  @override
  String get uiCena => 'CENA';

  @override
  String get uiSeloDesligado => 'OFF';

  @override
  String get uiRenomear => 'Renomear';

  @override
  String get uiDicaDuploClique => 'Duplo clique no pedal liga e desliga';

  @override
  String get uiDicaToqueDuplo => 'Toque duplo no pedal liga e desliga';

  @override
  String get cdBlocoMono => 'Mono';

  @override
  String get cdBlocoEstereo => 'Estéreo';

  @override
  String get cdBlocoMonoCurto => 'M';

  @override
  String get cdBlocoEstereoCurto => 'ST';
}
