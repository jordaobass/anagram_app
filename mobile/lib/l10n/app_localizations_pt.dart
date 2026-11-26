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
  String barraConectadaCurta(String firmware) {
    return 'Anagram · fw $firmware';
  }

  @override
  String get barraDemonstracaoCurta => 'Demonstração';

  @override
  String latenciaCurta(int ms) {
    return '$ms ms';
  }

  @override
  String latenciaDica(int ms) {
    return 'Ida e volta do último ajuste até a pedaleira: $ms ms. Acima de 500 ms ela responde devagar; acima de 1500 ms, muito devagar.';
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
  String avisoPresetAtualizado(String slot) {
    return 'O $slot mudou fora do app; a lista foi relida e a versão atual foi aberta.';
  }

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
  String get importacaoNaoEhPreset =>
      'Este arquivo não é um preset da Anagram.';

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
  String versaoAppNaBarra(String versao) {
    return 'App v$versao';
  }

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
  String ligadoNasCenas(String cenas) {
    return 'LIGADO NAS CENAS $cenas';
  }

  @override
  String desligadoNasCenas(String cenas) {
    return 'DESLIGADO NAS CENAS $cenas';
  }

  @override
  String get ligadoVariaEntreCenas =>
      'LIGADO NESTA CENA · VARIA ENTRE AS CENAS';

  @override
  String get desligadoVariaEntreCenas =>
      'DESLIGADO NESTA CENA · VARIA ENTRE AS CENAS';

  @override
  String nasCenas(String cenas) {
    return 'NAS CENAS $cenas';
  }

  @override
  String get variaEntreCenas => 'VARIA ENTRE AS CENAS';

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
      'Barlow, Saira Stencil, Share Tech Mono e Orbitron (SIL Open Font License) · Permanent Marker (Apache 2.0).';

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
  String get temaSecao => 'Aparência';

  @override
  String get temaSistema => 'Do sistema';

  @override
  String get temaEscuro => 'Escuro';

  @override
  String get temaClaro => 'Claro';

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

  @override
  String get kbDigitarDica => 'Clique no número para digitar o valor';

  @override
  String kbFaixa(String minimo, String maximo) {
    return 'De $minimo a $maximo';
  }

  @override
  String get kbNaoEhNumero => 'Digite um número, como -12,5 ou 1,5k.';

  @override
  String get kbAplicar => 'APLICAR';

  @override
  String get lpRemoverTitulo => 'Remover o Split?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'Sem o Split a linha 2 não recebe sinal: saem também o Merge e os $quantidade blocos da linha 2.';
  }

  @override
  String get lpRemoverConfirmar => 'REMOVER';

  @override
  String get cbGabinete => 'Gabinete';

  @override
  String get cbMicrofone => 'Microfone';

  @override
  String get cbPosicao => 'Posição';

  @override
  String get cbEscolher => 'Escolher';

  @override
  String cbIrDoUsuario(String arquivo) {
    return 'IR próprio: $arquivo';
  }

  @override
  String get opMoverPara => 'Mover para…';

  @override
  String get opClonarPara => 'Clonar para…';

  @override
  String get opTrocarBanco => 'Trocar de banco com…';

  @override
  String get opAcoesPreset => 'Mover, clonar ou trocar de banco';

  @override
  String opDestinoMover(String origem) {
    return 'Mover $origem: toque no slot de destino';
  }

  @override
  String opDestinoClonar(String origem) {
    return 'Clonar $origem: toque no slot de destino';
  }

  @override
  String opDestinoBanco(String banco) {
    return 'Trocar o banco $banco: toque num slot do outro banco';
  }

  @override
  String get opTrocarTitulo => 'Trocar os dois de lugar?';

  @override
  String opTrocarTexto(String destino, String nome, String origem) {
    return '$destino tem \"$nome\". Ele vai para $origem.';
  }

  @override
  String get opTrocar => 'TROCAR';

  @override
  String opSubstituirTitulo(String destino) {
    return 'Substituir $destino?';
  }

  @override
  String opSubstituirTexto(String nome, String origem) {
    return '\"$nome\" vai ser apagado e trocado pela cópia de $origem.';
  }

  @override
  String get opSubstituir => 'SUBSTITUIR';

  @override
  String opBancosTitulo(String a, String b) {
    return 'Trocar os bancos $a e $b?';
  }

  @override
  String get opBancosTexto => 'Os três presets de cada banco trocam de lugar.';

  @override
  String opMovido(String origem, String destino) {
    return '$origem foi para $destino.';
  }

  @override
  String opClonado(String origem, String destino) {
    return 'Cópia de $origem gravada em $destino.';
  }

  @override
  String opBancosTrocados(String a, String b) {
    return 'Bancos $a e $b trocados.';
  }

  @override
  String get fbAreaFabrica => 'Fábrica';

  @override
  String get fbSoLeitura => 'SÓ LEITURA';

  @override
  String get fbAreaSoLeitura =>
      'Presets de fábrica da Darkglass: abrir um só faz tocar. Para guardar, copie para uma área sua.';

  @override
  String get fbAvisoPresetDeFabrica =>
      'PRESET DE FÁBRICA — só toca. Copie para uma área sua para guardar.';

  @override
  String get fbCopiarParaMinhaArea => 'COPIAR PARA A MINHA ÁREA…';

  @override
  String get fbCopiarTitulo => 'Copiar para qual área?';

  @override
  String get fbCopiarPara => 'Copiar para a minha área…';

  @override
  String get bbModo => 'BIBLIOTECA';

  @override
  String get bbModoDica =>
      'Presets prontos por banda: toque para ouvir e aplique no slot que quiser.';

  @override
  String get bbTitulo => 'PRESETS PRONTOS';

  @override
  String get bbTexto =>
      'Tocar um preset só o faz soar. Aplicar grava num slot escolhido na lista da pedaleira; slot ocupado pergunta antes.';

  @override
  String get bbAplicar => 'Aplicar num slot…';

  @override
  String get bbVazia => 'Este build não traz a biblioteca de presets.';

  @override
  String get bbMenu => 'Arquivo da biblioteca';

  @override
  String bbIgnorados(int n) {
    return 'Ignorados (blocos que o app não conhece): $n.';
  }

  @override
  String get bbExportar => 'Exportar a biblioteca inteira…';

  @override
  String get bbImportar => 'Importar coleção…';

  @override
  String get bbBuscar => 'Buscar preset, banda ou coleção';

  @override
  String get bbLimparBusca => 'Limpar a busca';

  @override
  String get bbOrdem => 'Ordenar';

  @override
  String get bbOrdemArquivo => 'Ordem do arquivo';

  @override
  String get bbOrdemAZ => 'Nome A–Z';

  @override
  String get bbOrdemZA => 'Nome Z–A';

  @override
  String bbSemResultados(String busca) {
    return 'Nada encontrado para “$busca”.';
  }

  @override
  String get bbColecaoEmbutida => 'Presets do app';

  @override
  String get bbAcoesColecao => 'Ações da coleção';

  @override
  String get bbExportarColecao => 'Exportar coleção…';

  @override
  String get bbApagarColecao => 'Apagar coleção';

  @override
  String bbApagarTitulo(String nome) {
    return 'Apagar “$nome”?';
  }

  @override
  String get bbApagarTexto =>
      'A coleção sai da biblioteca. Os presets já gravados na pedaleira continuam como estão.';

  @override
  String get bbApagarConfirmar => 'Apagar';

  @override
  String bbApagada(String nome) {
    return 'Coleção “$nome” apagada.';
  }

  @override
  String bbColecaoImportada(String nome, int n) {
    return 'Coleção “$nome” adicionada com $n presets.';
  }

  @override
  String get bbMostrarPasta => 'Mostrar a pasta da biblioteca';

  @override
  String bbPastaNaoAbriu(String caminho) {
    return 'A pasta não abriu: $caminho';
  }

  @override
  String bbApagarFalhou(String nome) {
    return 'O arquivo de “$nome” não saiu da pasta.';
  }

  @override
  String get bbSoltarAqui =>
      'Solte o arquivo para acrescentá-lo à biblioteca de presets';

  @override
  String bbArquivoRecusado(String nome) {
    return '“$nome” não é uma biblioteca de presets nem um export do Anagram App.';
  }

  @override
  String get bbImportacaoRecusada =>
      'Este arquivo não é uma biblioteca de presets nem um export do Anagram App.';

  @override
  String get bbExportada => 'Biblioteca exportada.';

  @override
  String get bbCopiada => 'Biblioteca copiada para a área de transferência.';

  @override
  String get eqBandaGeral => 'Geral';

  @override
  String get eqPassaAltas => 'Passa-altas';

  @override
  String get eqPassaBaixas => 'Passa-baixas';

  @override
  String get eqShelfGraves => 'Shelf de graves';

  @override
  String eqBanda(int numero) {
    return 'Banda $numero';
  }

  @override
  String get eqShelfAgudos => 'Shelf de agudos';

  @override
  String get mbGraves => 'Graves';

  @override
  String get mbMedios => 'Médios';

  @override
  String get mbAgudos => 'Agudos';

  @override
  String get mbBordaGraves => '20 Hz';

  @override
  String get mbBordaAgudos => '20 kHz';

  @override
  String get mbMudo => 'Mudo';

  @override
  String get mbCompLigada => 'Comp ligado';

  @override
  String get mbCompDesligada => 'Comp desligado';

  @override
  String get mbSaida => 'Saída';

  @override
  String get mbOutros => 'Outros';

  @override
  String get mbExplicaMisturaLimpa =>
      'Comp Level é o volume das três bandas comprimidas. Clean Level mistura em paralelo o sinal seco, sem compressão: no mínimo (−24 dB) quase só se ouve o comprimido; subindo, volta o ataque natural da corda.';

  @override
  String get mbBuscarOpcao => 'Buscar (ex.: turbo grunt)';

  @override
  String get smOrdemInvalida =>
      'O Split precisa ficar antes do Merge na linha 1.';

  @override
  String get smSoNaLinha1 => 'Split e Merge ficam na linha 1.';

  @override
  String gvAnterior(String rotulo) {
    return '$rotulo: opção anterior';
  }

  @override
  String gvProximo(String rotulo) {
    return '$rotulo: próxima opção';
  }

  @override
  String gvAbrirLista(String rotulo, String nome) {
    return '$rotulo: $nome. Toque para ver todos';
  }

  @override
  String get gvBuscar => 'Escreva para buscar';

  @override
  String get gvNadaEncontrado => 'Nada encontrado';

  @override
  String get gxModeloAnterior => 'Gabinete anterior';

  @override
  String get gxProximoModelo => 'Próximo gabinete';

  @override
  String get gxBuscarGabinete => 'Escreva para buscar';

  @override
  String get mcpConfiguracoes => 'Configurações';

  @override
  String get mcpSecao => 'IA local (MCP)';

  @override
  String get mcpPermitir => 'Permitir IA via MCP';

  @override
  String get mcpPermitirTexto =>
      'Um assistente de IA no seu computador (LM Studio, Claude Desktop…) pode ler o preset aberto e ajustar o timbre. As mudanças soam na hora e só vão para a pedaleira se você salvar.';

  @override
  String get mcpEstadoDesligado =>
      'Desligado: nenhum programa consegue falar com o app.';

  @override
  String get mcpEstadoIniciando => 'Iniciando…';

  @override
  String mcpEstadoEscutando(String endereco) {
    return 'Escutando em $endereco';
  }

  @override
  String mcpEstadoPortaOcupada(int porta) {
    return 'A porta $porta já está em uso por outro programa (ou outra janela do app). Escolha outra porta.';
  }

  @override
  String get mcpPorta => 'Porta';

  @override
  String get mcpPortaInvalida => 'Use um número de 1024 a 65535.';

  @override
  String get mcpAplicarPorta => 'APLICAR';

  @override
  String get mcpToken => 'Token de acesso';

  @override
  String get mcpTokenTexto =>
      'O cliente de IA manda este token em cada pedido. Sem ele, o app não obedece.';

  @override
  String get mcpMostrarToken => 'Mostrar token';

  @override
  String get mcpOcultarToken => 'Ocultar token';

  @override
  String get mcpCopiarToken => 'Copiar token';

  @override
  String get mcpGerarNovoToken => 'GERAR NOVO';

  @override
  String get mcpGerarNovoTitulo => 'Gerar um token novo?';

  @override
  String get mcpGerarNovoTexto =>
      'O token atual deixa de valer na hora: o cliente de IA vai precisar do novo.';

  @override
  String get mcpCopiarConfiguracao => 'Copiar configuração para';

  @override
  String get mcpClienteLmStudio => 'LM Studio';

  @override
  String get mcpClienteClaudeDesktop => 'Claude Desktop';

  @override
  String get mcpClienteGenerico => 'Outro cliente';

  @override
  String get mcpCopiado => 'Copiado para a área de transferência.';

  @override
  String get mcpLimitacoes =>
      'A IA não ouve o som: ela ajusta pelo que você descreve, e você diz se melhorou. Modelos pequenos costumam descrever o que fariam em vez de chamar as ferramentas; prefira um modelo com bom suporte a ferramentas.';

  @override
  String get mcpAtivoNaBarra => 'IA';

  @override
  String mcpAtivoDicaPorta(int porta) {
    return 'IA local escutando na porta $porta (MCP ligado): ela pode ajustar o timbre';
  }

  @override
  String mcpMudancaDaIa(String resumo) {
    return 'IA: $resumo';
  }

  @override
  String get mcpPedidoSalvarTitulo => 'Salvar o que a IA ajustou?';

  @override
  String mcpPedidoSalvarTexto(String nome, String slot) {
    return 'A IA pediu para gravar \"$nome\" no slot $slot da pedaleira.';
  }

  @override
  String mcpPedidoSalvarSemSlot(String nome) {
    return 'A IA pediu para gravar \"$nome\" na pedaleira. Você vai escolher o slot.';
  }

  @override
  String get mcpSalvar => 'SALVAR';

  @override
  String get mcpAgoraNao => 'AGORA NÃO';

  @override
  String get ttDicaMouse =>
      'Pare o mouse sobre o nome de um controle para saber o que ele faz com o som';

  @override
  String get ttDicaToque =>
      'Toque no nome de um controle para saber o que ele faz com o som';

  @override
  String get smUmSplit => 'Este preset já tem um Split (um por preset).';

  @override
  String get smUmMerge => 'Este preset já tem um Merge (um por preset).';

  @override
  String get smMergeSemSplit =>
      'Coloque o Split antes: o Merge junta a linha 2, que só existe com o Split.';

  @override
  String get smLinha2SemSplit =>
      'Sem Split na linha 1, esta linha ainda não recebe sinal.';

  @override
  String get lpCriar => 'CRIAR LINHA PARALELA';

  @override
  String get lpCriarDica =>
      'Divide o sinal depois do bloco selecionado na linha 1: a linha 2 toca em paralelo e o Merge junta as duas antes da saída.';

  @override
  String get lpRemover => 'REMOVER LINHA PARALELA';

  @override
  String get lpSemEspaco =>
      'A linha 1 precisa de duas casas livres para o Split e o Merge.';

  @override
  String get smFaixaCriar => '+ Criar linha paralela · Split, linha 2 e Merge';

  @override
  String get smItemBiblioteca => 'Split + Merge (linha paralela)';

  @override
  String get smItemBibliotecaDica =>
      'Divide o sinal nesta casa: a linha 2 toca em paralelo e o Merge junta as duas.';

  @override
  String get smJaTemLinhaParalela =>
      'Este preset já tem linha paralela (um Split e um Merge por preset).';

  @override
  String get smDividirDepois => 'Dividir o sinal depois deste bloco';

  @override
  String get mpExportarJson => 'Exportar JSON…';

  @override
  String get mpLimpar => 'Limpar preset…';

  @override
  String get mpLimparFabrica => 'Limpar preset (a Fábrica é só leitura)';

  @override
  String mpLimparTitulo(String slot) {
    return 'Limpar o $slot?';
  }

  @override
  String mpLimparTexto(String nome, String slot) {
    return 'O preset \"$nome\" sai do slot $slot na pedaleira e o slot fica vazio. Não dá para desfazer. Para guardar uma cópia, exporte o JSON antes.';
  }

  @override
  String get mpExportarAntes => 'Exportar JSON';

  @override
  String get mpLimparConfirmar => 'Limpar';

  @override
  String mpLimpo(String slot) {
    return '$slot limpo: o slot ficou vazio.';
  }

  @override
  String mpExportadoGravado(String slot) {
    return 'Exportado o preset gravado no $slot; as edições não salvas ficaram de fora.';
  }

  @override
  String mpSlotVazio(String slot) {
    return 'O $slot já está vazio na pedaleira.';
  }

  @override
  String get axEntrada => 'Entrada';

  @override
  String get axOsciladores => 'Osciladores';

  @override
  String get axFiltro => 'Filtro';

  @override
  String get axEnvelope => 'Envelope';

  @override
  String get axArpejador => 'Arpejador';

  @override
  String get axSaida => 'Saída';

  @override
  String get axFecharPainel => 'Fechar o painel do bloco';

  @override
  String get axSemTemplates => 'O Axioma ainda não tem templates no app';

  @override
  String get axVisorSlot => 'Preset aberto';

  @override
  String get axOutros => 'Outros';

  @override
  String get ppTemplates => 'Templates';

  @override
  String get ppPersonalizado => 'Personalizado';

  @override
  String ppAplicado(String nome) {
    return 'Template $nome aplicado';
  }

  @override
  String get ppEscolherTemplate => 'Escolher template';

  @override
  String get ppDaDarkglass => 'Da Darkglass (os da pedaleira)';

  @override
  String get ppDoApp => 'Do app (pontos de partida nossos)';

  @override
  String get ppAConfirmar => 'Valores ainda não lidos da pedaleira';

  @override
  String get mbTipoDrive => 'Drive type';

  @override
  String get mbModoDrive => 'Drive mode';

  @override
  String get mbSolo => 'Solo';

  @override
  String mbSoloLigado(String banda) {
    return 'Só $banda soando';
  }

  @override
  String get mbSoloDesligado => 'Solo desligado: as três bandas soam';

  @override
  String mbCurvaCompressor(String limiar, String razao) {
    return 'Curva do compressor: Threshold $limiar dB, Ratio $razao:1';
  }

  @override
  String get mbOff => 'OFF';

  @override
  String get pdSecao => 'Pedaleira';

  @override
  String get pdDica =>
      'Ajustes globais da Anagram: valem para todos os presets e não entram no preset.';

  @override
  String get pdSaidas => 'Saídas';

  @override
  String get pdGlobalEq => 'Global EQ';

  @override
  String get pdEqModoGanho => 'Ganho';

  @override
  String get pdEqModoFrequencia => 'Frequência';

  @override
  String get pdEqModoLargura => 'Largura';

  @override
  String get pdEqInputGain => 'Input Gain';

  @override
  String get eqbResetTitulo => 'Voltar o Parametric EQ ao padrão?';

  @override
  String get eqbResetTexto =>
      'Todas as bandas, os cortes e o ganho voltam ao padrão do bloco. Dá para desfazer logo depois.';

  @override
  String get eqbResetFeito => 'Parametric EQ de volta ao padrão.';

  @override
  String get pdEqReset => 'Reset';

  @override
  String get pdEqResetConfirmar => 'VOLTAR AO PADRÃO';

  @override
  String get pdEqDica =>
      'A curva e as bandas mostram o Global EQ que a pedaleira tem agora; o modo escolhe o que as bandas mostram.';

  @override
  String get pdEntrada => 'Entrada';

  @override
  String get pdEntradaDica =>
      'Ganho de entrada do instrumento 1 (−12 a +12 dB). A Anagram guarda seis instrumentos; o app só lê o primeiro.';

  @override
  String get pdPlaca => 'Placa de som';

  @override
  String get pdPlacaDica =>
      'Só leitura: a pedaleira não aceita mudar estes pelo USB.';

  @override
  String get pdAtualizar => 'Atualizar';

  @override
  String get pdLendo => 'Lendo os ajustes da pedaleira…';

  @override
  String get pdFalhaLer => 'Não deu para ler os ajustes da pedaleira.';

  @override
  String get pdTentarDeNovo => 'Tentar de novo';

  @override
  String get registroSecao => 'Registro para suporte';

  @override
  String get registroOnde => 'O app guarda o que acontece neste arquivo:';

  @override
  String get registroCopiar => 'Copiar registro';

  @override
  String get registroCopiado =>
      'Registro copiado. Cole na issue do GitHub junto com o que aconteceu.';

  @override
  String versaoNovaNaBarra(String versao) {
    return 'v$versao disponível';
  }

  @override
  String get versaoNovaBaixar => 'BAIXAR';

  @override
  String get versaoNovaLembrarDepois => 'Lembrar depois';

  @override
  String get versaoNovaSecao => 'Atualizações';

  @override
  String get versaoNovaVerificar => 'Verificar versão nova ao abrir';

  @override
  String get versaoNovaVerificarTexto =>
      'Ao abrir, o app consulta só o GitHub para saber qual é a última versão publicada. Nenhum dado seu é enviado. Desligado, o app não acessa a internet.';

  @override
  String get versaoNovaEmDia => 'Você está na versão mais recente.';

  @override
  String versaoNovaDisponivel(String versao) {
    return 'Versão $versao disponível.';
  }

  @override
  String get versaoNovaSemResposta =>
      'Não deu para verificar agora; o app tenta de novo na próxima abertura.';

  @override
  String get ctlTitulo => 'Controles da pedaleira';

  @override
  String get ctlDicaMouse =>
      'Clique num controle para editar. Botão direito num knob atribui o parâmetro a um pot ou ao pedal; o menu do bloco põe um footswitch nele.';

  @override
  String get ctlDicaToque =>
      'Toque num controle para editar ou atribuir um parâmetro do bloco aberto; o menu do bloco põe um footswitch nele.';

  @override
  String get ctlSiglaFoot => 'FOOT';

  @override
  String get ctlSiglaPot => 'POT';

  @override
  String get ctlSiglaExp => 'EXP';

  @override
  String get ctlLivre => 'livre';

  @override
  String get ctlLigaDesliga => 'Liga/desliga';

  @override
  String ctlAtribuirA(String controle) {
    return 'Atribuir a $controle';
  }

  @override
  String get ctlJaAqui => 'já está aqui';

  @override
  String ctlFootswitchLigaBloco(int numero) {
    return 'Footswitch $numero liga/desliga este bloco';
  }

  @override
  String get ctlNome => 'Nome no visor';

  @override
  String ctlNomeLongo(int maximo) {
    return 'Os presets de fábrica usam até $maximo letras; um nome maior pode ser cortado no visor.';
  }

  @override
  String get ctlMinimo => 'MÍN';

  @override
  String get ctlMaximo => 'MÁX';

  @override
  String get ctlRemoverAlvo => 'Tirar este parâmetro';

  @override
  String get ctlRemoverControle => 'SOLTAR CONTROLE';

  @override
  String get ctlAtribuirDoBloco => 'ATRIBUIR PARÂMETRO';

  @override
  String ctlEscolherParametro(String bloco) {
    return 'Parâmetro de $bloco';
  }

  @override
  String get ctlSemBlocoAberto =>
      'Abra um bloco na cadeia para atribuir um parâmetro dele.';

  @override
  String get ctlSemAlvos => 'Nenhum parâmetro neste controle.';

  @override
  String get ctlFaixaIguais =>
      'Mínimo e máximo iguais deixam o controle sem curso.';

  @override
  String get ctlFaixaFora => 'Fora da faixa do parâmetro.';

  @override
  String ctlCasaVazia(int linha, int casa) {
    return 'casa $linha·$casa vazia';
  }

  @override
  String ctlAtribuidoA(String controle) {
    return 'Atribuído a $controle';
  }

  @override
  String get ctlAcaoAtribuir => 'Atribuir a um controle da pedaleira';

  @override
  String get ctlFechar => 'FECHAR';

  @override
  String get ctlDicaPedaleira =>
      'Na pedaleira, os pots atribuídos só respondem na tela do preset em uma linha; com o preset expandido, os knobs mexem no bloco selecionado.';

  @override
  String get utTreino => 'Treino';

  @override
  String get utBater => 'Bater';

  @override
  String get utBaterSoNoFixo => 'Bater o tempo só vale no modo Fixed Tempo.';

  @override
  String slotAlteradoForaTitulo(String slot) {
    return '$slot mudou na pedaleira';
  }

  @override
  String slotAlteradoForaTexto(String slot) {
    return 'O slot $slot foi alterado na pedaleira desde que você abriu. Sobrescrever grava a sua versão por cima do que está lá; recarregar descarta as suas edições e mostra a versão da pedaleira.';
  }

  @override
  String get sobrescreverMesmoAssim => 'SOBRESCREVER MESMO ASSIM';

  @override
  String get recarregarDaPedaleira => 'RECARREGAR DA PEDALEIRA';

  @override
  String get uiRecarregarDaPedaleira => 'Recarregar da pedaleira';

  @override
  String recarregarTitulo(String slot) {
    return 'Recarregar $slot da pedaleira?';
  }

  @override
  String recarregarTexto(String nome) {
    return 'As mudanças não salvas de \"$nome\" se perdem e o editor passa a mostrar o que está gravado no slot.';
  }

  @override
  String get recarregar => 'RECARREGAR';

  @override
  String get pausaUsbTitulo => 'Pausa entre pacotes USB';

  @override
  String get pausaUsbTexto =>
      'Menor = ao vivo mais rápido; aumente se a pedaleira deixar de responder. Auto usa o padrão deste computador.';

  @override
  String get versaoNovaConsultaTexto =>
      'Ao abrir, o app consulta só o GitHub para saber qual é a última versão publicada. A consulta envia apenas a versão do app (no cabeçalho User-Agent); como em toda conexão, o GitHub vê o seu endereço IP. Desligado, o app não acessa a internet.';

  @override
  String get fmTitulo => 'Footswitches';

  @override
  String fmModo(String modo) {
    String _temp0 = intl.Intl.selectLogic(modo, {
      'preset': 'PRESET',
      'stomp': 'STOMP',
      'scene': 'SCENE',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String fmSemantica(String modo) {
    return 'Footswitches no modo $modo';
  }

  @override
  String get fmDica =>
      'No modo Stomp, os footswitches seguem os controles da pedaleira deste preset. O modo vale para todos os presets.';

  @override
  String get fmErro =>
      'A pedaleira não confirmou a troca de modo. O modo mostrado é o que ela tem agora.';

  @override
  String get fmIndisponivel =>
      'Esta pedaleira não informa o modo dos footswitches.';

  @override
  String fmAvisoControles(String modo) {
    return 'Os FOOT atribuídos só agem no modo Stomp; a pedaleira está em $modo.';
  }

  @override
  String get fmDesconhecido =>
      'A pedaleira está num modo que o app não conhece. Troque o modo na própria pedaleira.';

  @override
  String get t3kTom => 'Tom';

  @override
  String get t3kModelo => 'Modelo';

  @override
  String get t3kLendo => 'Lendo os tons da pedaleira…';

  @override
  String get t3kFalhou => 'A pedaleira não mandou a lista de tons.';

  @override
  String get t3kTentarDeNovo => 'Tentar de novo';

  @override
  String t3kNaoEncontrado(String arquivo) {
    return 'Não encontrado na pedaleira: $arquivo';
  }

  @override
  String get t3kSoConsulta =>
      'Tom enviado por você: aparece só para consulta. Trocá-lo ainda não é possível pelo app.';

  @override
  String get t3kIrNaoConferido =>
      'O caminho dos IRs de fábrica ainda não foi conferido numa pedaleira: ouça antes de salvar.';

  @override
  String t3kResumo(int fabrica, int seus) {
    return 'Na pedaleira: $fabrica de fábrica e $seus enviados por você';
  }

  @override
  String t3kDetalheFabrica(String autor, String licenca) {
    return '$autor · licença $licenca';
  }

  @override
  String t3kDetalheSeu(String autor, String licenca) {
    return '$autor · licença $licenca · seu, só para consulta';
  }

  @override
  String get t3kSemAutor => 'sem autor';

  @override
  String get uiDicas => 'Dicas';

  @override
  String ctlResumo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n atribuídos',
      one: '1 atribuído',
      zero: 'nenhum atribuído',
    );
    return '$_temp0';
  }

  @override
  String get ctlMostrar => 'Mostrar os controles da pedaleira';

  @override
  String get ctlRecolher => 'Recolher os controles da pedaleira';

  @override
  String sbSubstitui(String nome) {
    return 'substitui $nome';
  }

  @override
  String get sbSubstituirAqui => 'Substituir o preset deste slot';

  @override
  String get salvarReleituraDiferente =>
      'a pedaleira confirmou, mas o slot relido é diferente do enviado. A edição continua na tela; confira o slot e salve de novo.';

  @override
  String get pdSemAcesso =>
      'Volume das saídas, Global EQ e ganho de entrada: o app não tem acesso a esses recursos da pedaleira. A Anagram aceita o valor enviado, mas não o aplica ao som. Ajuste nos knobs e telas da própria pedaleira; aqui você vê os valores atuais (toque em Atualizar depois de mudar).';

  @override
  String get utAcaoChave =>
      'No app, esta chave é o Action da pedaleira. Pelo manual do plugin: ativar começa o ritmo com introdução; com o ritmo tocando, um novo acionamento faz uma virada; acionamento duplo para; segurar passa para a próxima parte. O que a bateria toca em cada caso é do plugin.';

  @override
  String get utSoNoVisor => 'Só no visor da pedaleira';

  @override
  String get caProcurando => 'Procurando a pedaleira…';

  @override
  String get caConectarAoAbrir => 'Conectar ao abrir';

  @override
  String get caConectarAoAbrirTexto =>
      'Ao abrir, o app procura a pedaleira no USB uma vez. Conectar não toca nada; sem pedaleira, a tela de conectar fica como está.';

  @override
  String get caConectarAoAbrirMac =>
      'No macOS, só depois de liberar o Monitoramento de Entrada para o Anagram App em Ajustes do Sistema › Privacidade e Segurança.';

  @override
  String salvarCopiaFalhou(String pasta) {
    return 'o backup do preset que está no slot não foi gravado em $pasta, então nada foi para a pedaleira. A causa está no registro; se o disco não tiver jeito, desligue o backup automático nas Configurações.';
  }

  @override
  String bkErroCopia(String pasta) {
    return 'O backup do preset que está no slot não foi gravado em $pasta, então nada mudou na pedaleira. A causa está no registro; se o disco não tiver jeito, desligue o backup automático nas Configurações.';
  }

  @override
  String get bkPastaDesconhecida =>
      'a pasta de dados do app (o sistema não informou qual é)';

  @override
  String get bkSecao => 'Backup dos presets';

  @override
  String get bkAutomatico => 'Backup automático antes de gravar';

  @override
  String get bkAutomaticoTexto =>
      'Antes de substituir, mover ou limpar um preset na pedaleira, o app guarda o que estava no slot, como um JSON que o Importar abre. Se o backup falhar, nada é gravado. Ficam os últimos 30 dias, até 500 arquivos.';

  @override
  String get bkOnde => 'Os backups ficam nesta pasta, só neste computador:';

  @override
  String get bkAbrirPasta => 'Abrir pasta de backups';

  @override
  String get bkPastaNaoAbriu =>
      'O sistema não abriu a pasta. O caminho está acima, para copiar.';

  @override
  String get bkCompleto => 'Fazer backup de todos os presets agora';

  @override
  String get bkCompletoTexto =>
      'Lê todas as áreas e todos os slots ocupados, um de cada vez, e guarda cada preset numa pasta com a data. O app não apaga os backups completos.';

  @override
  String get bkSemPedaleira =>
      'Conecte a pedaleira (ou abra a demonstração) para fazer o backup completo e abrir um backup no editor.';

  @override
  String get bkCompletoTitulo => 'Backup de todos os presets';

  @override
  String get bkCompletoListando => 'Lendo a lista de presets de cada área…';

  @override
  String bkCompletoProgresso(int feitos, int total) {
    return '$feitos de $total presets guardados';
  }

  @override
  String bkCompletoConcluido(int quantos, String pasta) {
    return 'Backup completo: $quantos presets guardados em $pasta.';
  }

  @override
  String bkCompletoCancelado(int feitos, int total) {
    return 'Backup cancelado: $feitos de $total presets guardados. O que já foi gravado fica na pasta.';
  }

  @override
  String bkCompletoFalhou(int feitos, String motivo) {
    return 'Backup interrompido depois de $feitos presets: $motivo';
  }

  @override
  String get bkRestaurar => 'Restaurar de um backup…';

  @override
  String get bkRestaurarTexto =>
      'Abre o preset guardado no editor, sem slot, para ouvir antes. Para pôr na pedaleira, use Salvar como.';

  @override
  String get bkNenhum => 'Nenhum backup ainda.';

  @override
  String get bkAbrirNoEditor => 'Abrir no editor';

  @override
  String bkAbertoNoEditor(String nome) {
    return '\"$nome\" aberto no editor, sem slot. Use Salvar como para gravar.';
  }

  @override
  String bkCompletoGrupo(String hora, int quantos) {
    return 'Backup completo · $hora · $quantos presets';
  }

  @override
  String get bkAreaUnica => 'Área única';

  @override
  String get bkFechar => 'FECHAR';

  @override
  String get bkRestaurarTitulo => 'Restaurar de um backup';

  @override
  String get caMonitoramentoNegado =>
      'O macOS ainda não deixa o Anagram App falar com a pedaleira. Em Ajustes do Sistema › Privacidade e Segurança › Monitoramento de Entrada, ligue o Anagram App.';

  @override
  String get caAbrirAjustes => 'ABRIR AJUSTES';

  @override
  String get caReabraDepois =>
      'Depois de ligar, feche e reabra o Anagram App: o macOS só libera na próxima abertura.';

  @override
  String get mcpClienteVsCode => 'VS Code + Copilot';

  @override
  String get mcpVsCodeOnde =>
      'VS Code + GitHub Copilot: cole em ~/.copilot/mcp-config.json (ou em Chat: Open Customizations › MCP Servers › Copilot Global) e peça numa conversa do Copilot.';

  @override
  String get mcpCopilotComum =>
      'O app Copilot do Windows e o Microsoft 365 Copilot não têm onde colar um servidor MCP local: use o GitHub Copilot dentro do VS Code.';

  @override
  String get mcpDocVsCode => 'Documentação do VS Code';

  @override
  String get ceControlar => 'CONTROLAR';

  @override
  String get ceTodas => 'TODAS AS CENAS';

  @override
  String get ceAtiva => 'SÓ A CENA ATIVA';

  @override
  String get ceTodasDica =>
      'Knob, valor e liga/desliga mudam todas as cenas: o valor deixa de variar entre elas.';

  @override
  String get ceAtivaDica =>
      'Knob, valor e liga/desliga mudam só a cena ativa; as outras ficam como estavam.';
}
