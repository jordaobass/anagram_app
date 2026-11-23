// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get desconectar => 'Disconnect';

  @override
  String get creditos => 'Credits';

  @override
  String get estadoSemConexao => 'Not connected';

  @override
  String estadoConectando(String meio) {
    return 'Connecting ($meio)…';
  }

  @override
  String get estadoDemonstracao => 'Demo · no pedal';

  @override
  String estadoConectada(String meio, String firmware) {
    return 'Anagram · $meio · $firmware';
  }

  @override
  String get estadoFalha => 'Connection failed';

  @override
  String conexaoSemantica(String texto) {
    return 'Connection: $texto';
  }

  @override
  String idaEVolta(int ms) {
    return 'round trip $ms ms';
  }

  @override
  String get aoVivo => 'LIVE';

  @override
  String get aoVivoDesligado => 'LIVE OFF';

  @override
  String get conexaoPermissaoNegada => 'The system denied access to the Anagram USB. On Android, tap Connect again and accept the request; on macOS, check Privacy & Security settings.';

  @override
  String get conexaoOcupada => 'The Anagram is plugged in, but another program is holding it. Close Darkglass Suite and any browser tab connected to the pedal.';

  @override
  String get conexaoSemAnagram => 'No Anagram found on USB. Check the cable and that the pedal is on.';

  @override
  String get conexaoSemResposta => 'The Anagram didn\'t answer. Unplug and replug the cable and try again.';

  @override
  String get conexaoRespostaInvalida => 'Unexpected reply from the pedal.';

  @override
  String get erroOcupada => 'Another program is holding the pedal.';

  @override
  String get erroDesconectado => 'The pedal is disconnected.';

  @override
  String get erroSemResposta => 'The pedal didn\'t answer in time.';

  @override
  String get erroRespostaInvalida => 'The pedal refused or sent an unexpected reply.';

  @override
  String erroOperacaoEmCurso(String detalhe) {
    return 'Wait for the current operation to finish.';
  }

  @override
  String get erroSemSuporte => 'This platform can\'t talk to the pedal.';

  @override
  String get avisoDemonstracaoFalhou => 'Couldn\'t open the demo.';

  @override
  String avisoFalhaInesperada(String meio) {
    return 'Couldn\'t open $meio. Try again; the details are in the log.';
  }

  @override
  String get avisoPedaleiraDesconectada => 'The pedal was disconnected. Connect again to pick up where you left off.';

  @override
  String get avisoFormatoMaisNovo => 'This preset uses a newer format than this app: unknown fields are kept.';

  @override
  String avisoPresetAtualizado(String slot) {
    return '$slot changed outside the app; the list was reloaded and the current version was opened.';
  }

  @override
  String avisoPresetTrocado(String slot) {
    return 'The pedal returned a different preset for $slot (id differs from the list). The list was reloaded; open it again.';
  }

  @override
  String get avisoAreaNaoTrocou => 'The pedal didn\'t switch area.';

  @override
  String naoSalvou(String motivo) {
    return 'Not saved: $motivo';
  }

  @override
  String get salvarDesconectada => 'the pedal is disconnected. Connect it and try again.';

  @override
  String get salvarSemResposta => 'the pedal didn\'t answer in time. The slot may not have been written; check it before trying again.';

  @override
  String get salvarRespostaInvalida => 'the pedal refused or sent an unexpected reply.';

  @override
  String get salvarOcupada => 'another program is holding the pedal.';

  @override
  String get indisponivelIos => 'iPhone and iPad don\'t let regular apps open the Anagram\'s USB control interface: that needs a DriverKit driver with special permission from Apple, which this app doesn\'t have yet. Use the demo here, or edit from a Mac, PC, Android or Chrome.';

  @override
  String get indisponivelNavegador => 'This browser doesn\'t have WebHID. Use Chrome or Edge on a computer, or the demo.';

  @override
  String get indisponivelSemUsb => 'This platform can\'t reach the pedal over USB.';

  @override
  String get importacaoIlegivel => 'Couldn\'t read the file.';

  @override
  String get importacaoNaoEhPreset => 'This file is not an Anagram preset.';

  @override
  String get exportacaoFalhou => 'Couldn\'t save the file.';

  @override
  String get nomeVazio => 'The name can\'t be empty.';

  @override
  String nomeComMarcador(String marcador) {
    return 'The name can\'t contain \"$marcador\".';
  }

  @override
  String get familiaDrive => 'Drive';

  @override
  String get familiaDinamica => 'Dynamics';

  @override
  String get familiaEq => 'EQ';

  @override
  String get familiaFiltro => 'Filter';

  @override
  String get familiaModulacao => 'Modulation';

  @override
  String get familiaDelay => 'Delay';

  @override
  String get familiaReverb => 'Reverb';

  @override
  String get familiaAmp => 'Amp';

  @override
  String get familiaGabinete => 'Cab';

  @override
  String get familiaUtilitario => 'Utility';

  @override
  String areaSemNome(int numero) {
    return 'Area $numero';
  }

  @override
  String get conecteTitulo => 'Connect the Anagram over USB';

  @override
  String get conecteFecheSuite => 'Close Darkglass Suite first: only one program at a time can control the pedal.';

  @override
  String get abrirDemonstracao => 'OPEN DEMO';

  @override
  String get conectarPeloUsb => 'CONNECT OVER USB';

  @override
  String get cancelar => 'CANCEL';

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
    return 'v$versao · pedal art';
  }

  @override
  String get fecharAviso => 'Dismiss';

  @override
  String get largarEdicoesTitulo => 'Discard edits?';

  @override
  String largarEdicoesTexto(String nome) {
    return '\"$nome\" has changes that were not saved to the slot.';
  }

  @override
  String get continuarEditando => 'KEEP EDITING';

  @override
  String get largar => 'DISCARD';

  @override
  String get origem => 'SOURCE';

  @override
  String get gravarAqui => 'Save here';

  @override
  String get pedaleiraNesteSlot => 'The pedal is on this slot';

  @override
  String get slotVazio => 'empty';

  @override
  String get area => 'AREA';

  @override
  String largarAoTrocarArea(String nome) {
    return '\"$nome\" has unsaved changes and will be closed when switching area.';
  }

  @override
  String get areaInativa => 'This area isn\'t active on the pedal: opening a preset only plays it, without switching the pedal\'s slot.';

  @override
  String get tornarAtiva => 'MAKE ACTIVE';

  @override
  String get salvar => 'SAVE';

  @override
  String get salvarComo => 'SAVE AS…';

  @override
  String get descartar => 'DISCARD';

  @override
  String get menuArquivo => 'Import or export JSON';

  @override
  String get importarPreset => 'Import preset (.json)';

  @override
  String get exportarPreset => 'Export preset (.json)';

  @override
  String presetImportado(String nome) {
    return '\"$nome\" imported. Save to a slot to keep it.';
  }

  @override
  String get presetExportado => 'Preset exported.';

  @override
  String get presetCopiado => 'Preset JSON copied to the clipboard.';

  @override
  String presetSalvoEm(String nome, String slot) {
    return '\"$nome\" saved to $slot.';
  }

  @override
  String substituirTitulo(String slot) {
    return 'Replace $slot?';
  }

  @override
  String substituirTexto(String slot, String nome) {
    return 'Slot $slot holds \"$nome\". It will be replaced by the edited preset.';
  }

  @override
  String get substituir => 'REPLACE';

  @override
  String get salvarComoEscolhaDestino => 'SAVE AS: TAP THE TARGET SLOT';

  @override
  String slotSemantica(String slot) {
    return 'Slot $slot';
  }

  @override
  String get slotNovo => 'new';

  @override
  String get abrirListaSemantica => ', open preset list';

  @override
  String renomearPresetSemantica(String nome) {
    return 'Rename preset $nome';
  }

  @override
  String get avisoAoVivoDesligado => 'LIVE OFF — edits stay in the app, the pedal doesn\'t change.';

  @override
  String get avisoAudicao => 'PREVIEW — the pedal stays on its own slot (no USB MIDI).';

  @override
  String get naoSalvo => 'NOT SAVED';

  @override
  String get escolhaUmPreset => 'Pick a preset';

  @override
  String slotEstaVazio(String slot) {
    return 'Slot $slot is empty';
  }

  @override
  String get escolhaUmPresetTexto => 'Opening it makes the pedal play it. Changes sound right away and are only stored when you save.';

  @override
  String get slotVazioTexto => 'Create a preset here. To bring blocks from another preset, use the copy icon in the block panel, then hold an empty position in the grid to paste.';

  @override
  String get criarPresetAqui => 'CREATE PRESET HERE';

  @override
  String get verPresets => 'VIEW PRESETS';

  @override
  String get nomeDoPreset => 'Preset name';

  @override
  String get nome => 'Name';

  @override
  String get renomear => 'RENAME';

  @override
  String blocoPosicao(String familia, int linha, int casa) {
    return '$familia · row $linha, position $casa';
  }

  @override
  String get arrasteComMouse => 'Drag in the grid to move it';

  @override
  String get arrasteNoToque => 'Hold and drag in the grid to move it';

  @override
  String ligadoSoNaCena(int cena) {
    return 'ON ONLY IN SCENE $cena';
  }

  @override
  String desligadoSoNaCena(int cena) {
    return 'OFF ONLY IN SCENE $cena';
  }

  @override
  String get copiarBloco => 'Copy block';

  @override
  String get maisAcoesBloco => 'More block actions';

  @override
  String get blocoLigadoSemantica => 'Block on';

  @override
  String get ligado => 'ON';

  @override
  String get desligado => 'OFF';

  @override
  String get adicionarEfeitoMenu => 'Add effect…';

  @override
  String get colarAqui => 'Paste here';

  @override
  String get ligarDesligar => 'Turn on / off';

  @override
  String get moverEsquerda => 'Move left';

  @override
  String get moverDireita => 'Move right';

  @override
  String moverParaLinha(int linha) {
    return 'Move to row $linha';
  }

  @override
  String get removerBloco => 'Remove block';

  @override
  String get semParametros => 'This block has no adjustable parameters.';

  @override
  String soNaCena(int cena) {
    return 'ONLY IN SCENE $cena';
  }

  @override
  String get dicaMontarCadeia => 'Tap a + in the grid to add an effect. Tap a block to adjust it; hold and drag it to move it.';

  @override
  String faixaEstimada(String simbolo) {
    return '$simbolo (estimated range)';
  }

  @override
  String get adicionarEfeito => 'Add effect';

  @override
  String linhaCasa(int linha, int casa) {
    return 'Row $linha, position $casa';
  }

  @override
  String get buscarPeloNome => 'Search by name';

  @override
  String get todos => 'All';

  @override
  String nenhumEfeito(String busca) {
    return 'No effect matching \"$busca\".';
  }

  @override
  String nenhumEfeitoNaFamilia(String busca, String familia) {
    return 'No effect matching \"$busca\" in $familia.';
  }

  @override
  String get sobreTitulo => 'About and diagnostics';

  @override
  String get creditoAutorTitulo => 'Author';

  @override
  String get creditoAutor => 'jordao_bass · free software, MIT license. Free of charge, no ads, no in-app purchases and no data collection.';

  @override
  String get creditoProtocoloTitulo => 'USB protocol and block catalog';

  @override
  String get creditoProtocolo => 'Ported from the anagram-tone-maker project by basster6 — MIT license (github.com/basster6/anagram-tone-maker).';

  @override
  String get creditoArteTitulo => 'Block art';

  @override
  String get creditoArtePropria => 'The app\'s own art, by block category.';

  @override
  String get creditoImagensTitulo => 'Block images';

  @override
  String creditoImagens(String credito) {
    return '$credito. Blocks without an image use the app\'s own art, by category.';
  }

  @override
  String get creditoFontesTitulo => 'Fonts';

  @override
  String get creditoFontes => 'Barlow and Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).';

  @override
  String get creditoAvisoTitulo => 'Notice';

  @override
  String get creditoAviso => 'Unofficial app, not affiliated with Darkglass Electronics. Anagram is a trademark of its maker.';

  @override
  String get diagnosticoPausa => 'DIAGNOSTICS · PAUSE BETWEEN USB REPORTS';

  @override
  String get diagnosticoPausaTexto => 'Compare 0, 2 and 10 ms and watch the \"round trip\" in the bar and in the log.';

  @override
  String get idioma => 'Language';

  @override
  String get idiomaDoSistema => 'System';

  @override
  String get separadorDecimal => '.';

  @override
  String get valorLigado => 'On';

  @override
  String get valorDesligado => 'Off';

  @override
  String get voltarAoPadrao => 'Reset to default';

  @override
  String voltouAoPadrao(String parametro) {
    return '$parametro was reset to default.';
  }

  @override
  String get desfazer => 'UNDO';

  @override
  String get pausaAuto => 'Auto';

  @override
  String get linha1 => 'ROW 1';

  @override
  String get linha2Paralela => 'ROW 2 · PARALLEL';

  @override
  String cenaSemantica(int numero, String nome) {
    return 'Scene $numero, $nome';
  }

  @override
  String cenaPadrao(int numero) {
    return 'Scene $numero';
  }

  @override
  String adicionarEfeitoNaCasa(int casa, int linha) {
    return 'Add effect at position $casa, row $linha';
  }

  @override
  String blocoLigado(String nome) {
    return '$nome, on';
  }

  @override
  String blocoDesligado(String nome) {
    return '$nome, off';
  }

  @override
  String get presets => 'Presets';

  @override
  String get txDicaMontarCadeiaMouse => 'Click a + in the grid to add an effect. Click a block to adjust it and drag it to move it.';

  @override
  String get txSlotVazioMouse => 'Create a preset here. To bring blocks from another preset, use the copy icon in the block panel, then right-click an empty position in the grid to paste.';

  @override
  String get txModoDemonstracaoTitulo => 'Demo mode';

  @override
  String get txSemUsbAquiCurto => 'Here the app can\'t reach the pedal over USB. Explore everything in demo mode.';

  @override
  String get txPorQue => 'WHY?';

  @override
  String get txEntendi => 'GOT IT';

  @override
  String get txAtiva => 'ACTIVE';

  @override
  String get txAtivaNaPedaleiraDica => 'Area active on the pedal';

  @override
  String get txEstadoAbrindoDemonstracao => 'Opening the demo…';

  @override
  String get cdNovoPreset => 'New preset';

  @override
  String get uiPresets => 'PRESETS';

  @override
  String get uiMaisAcoesPreset => 'More preset actions';

  @override
  String get uiMenuArquivo => 'Import or export the preset';

  @override
  String get uiDescartarEdicoes => 'Discard edits';

  @override
  String get uiFecharBiblioteca => 'Close';

  @override
  String get uiCena => 'SCENE';

  @override
  String get uiSeloDesligado => 'OFF';

  @override
  String get uiRenomear => 'Rename';

  @override
  String get uiDicaDuploClique => 'Double-click the pedal to turn it on or off';

  @override
  String get uiDicaToqueDuplo => 'Double-tap the pedal to turn it on or off';

  @override
  String get cdBlocoMono => 'Mono';

  @override
  String get cdBlocoEstereo => 'Stereo';

  @override
  String get cdBlocoMonoCurto => 'M';

  @override
  String get cdBlocoEstereoCurto => 'ST';

  @override
  String get kbDigitarDica => 'Click the number to type a value';

  @override
  String kbFaixa(String minimo, String maximo) {
    return 'From $minimo to $maximo';
  }

  @override
  String get kbNaoEhNumero => 'Type a number, like -12.5 or 1.5k.';

  @override
  String get kbAplicar => 'APPLY';

  @override
  String get lpRemoverTitulo => 'Remove the Split?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'Without the Split, row 2 gets no signal: the Merge and the $quantidade blocks on row 2 go too.';
  }

  @override
  String get lpRemoverConfirmar => 'REMOVE';

  @override
  String get cbGabinete => 'Cabinet';

  @override
  String get cbMicrofone => 'Microphone';

  @override
  String get cbPosicao => 'Position';

  @override
  String get cbEscolher => 'Choose';

  @override
  String cbIrDoUsuario(String arquivo) {
    return 'Own IR: $arquivo';
  }

  @override
  String get opMoverPara => 'Move to…';

  @override
  String get opClonarPara => 'Clone to…';

  @override
  String get opTrocarBanco => 'Swap bank with…';

  @override
  String get opAcoesPreset => 'Move, clone or swap bank';

  @override
  String opDestinoMover(String origem) {
    return 'Move $origem: tap the destination slot';
  }

  @override
  String opDestinoClonar(String origem) {
    return 'Clone $origem: tap the destination slot';
  }

  @override
  String opDestinoBanco(String banco) {
    return 'Swap bank $banco: tap a slot of the other bank';
  }

  @override
  String get opTrocarTitulo => 'Swap both presets?';

  @override
  String opTrocarTexto(String destino, String nome, String origem) {
    return '$destino has \"$nome\". It moves to $origem.';
  }

  @override
  String get opTrocar => 'SWAP';

  @override
  String opSubstituirTitulo(String destino) {
    return 'Replace $destino?';
  }

  @override
  String opSubstituirTexto(String nome, String origem) {
    return '\"$nome\" will be erased and replaced by the copy of $origem.';
  }

  @override
  String get opSubstituir => 'REPLACE';

  @override
  String opBancosTitulo(String a, String b) {
    return 'Swap banks $a and $b?';
  }

  @override
  String get opBancosTexto => 'The three presets of each bank swap places.';

  @override
  String opMovido(String origem, String destino) {
    return '$origem moved to $destino.';
  }

  @override
  String opClonado(String origem, String destino) {
    return 'Copy of $origem saved to $destino.';
  }

  @override
  String opBancosTrocados(String a, String b) {
    return 'Banks $a and $b swapped.';
  }

  @override
  String get fbAreaFabrica => 'Factory';

  @override
  String get fbSoLeitura => 'READ ONLY';

  @override
  String get fbAreaSoLeitura => 'Darkglass factory presets: opening one only plays it. To keep one, copy it to one of your areas.';

  @override
  String get fbAvisoPresetDeFabrica => 'FACTORY PRESET — plays only. Copy it to one of your areas to keep it.';

  @override
  String get fbCopiarParaMinhaArea => 'COPY TO MY AREA…';

  @override
  String get fbCopiarTitulo => 'Copy to which area?';

  @override
  String get fbCopiarPara => 'Copy to my area…';

  @override
  String get eqBandaGeral => 'Overall';

  @override
  String get eqPassaAltas => 'High-pass';

  @override
  String get eqPassaBaixas => 'Low-pass';

  @override
  String get eqShelfGraves => 'Low shelf';

  @override
  String eqBanda(int numero) {
    return 'Band $numero';
  }

  @override
  String get eqShelfAgudos => 'High shelf';

  @override
  String get mbGraves => 'Low';

  @override
  String get mbMedios => 'Mid';

  @override
  String get mbAgudos => 'High';

  @override
  String get mbBordaGraves => '20 Hz';

  @override
  String get mbBordaAgudos => '20 kHz';

  @override
  String get mbMudo => 'Mute';

  @override
  String get mbCompLigada => 'Comp on';

  @override
  String get mbCompDesligada => 'Comp off';

  @override
  String get mbSaida => 'Output';

  @override
  String get mbOutros => 'Others';

  @override
  String get mbExplicaMisturaLimpa => 'Comp Level is the volume of the three compressed bands. Clean Level blends the dry, uncompressed signal in parallel: at the minimum (−24 dB) you hear almost only the compressed sound; turning it up brings back the natural attack of the string.';

  @override
  String get mbBuscarOpcao => 'Search (e.g. turbo grunt)';

  @override
  String get smOrdemInvalida => 'The Split has to stay before the Merge on row 1.';

  @override
  String get smSoNaLinha1 => 'Split and Merge stay on row 1.';

  @override
  String gvAnterior(String rotulo) {
    return '$rotulo: previous option';
  }

  @override
  String gvProximo(String rotulo) {
    return '$rotulo: next option';
  }

  @override
  String gvAbrirLista(String rotulo, String nome) {
    return '$rotulo: $nome. Tap to see all';
  }

  @override
  String get gvBuscar => 'Type to search';

  @override
  String get gvNadaEncontrado => 'Nothing found';

  @override
  String get gxModeloAnterior => 'Previous cabinet';

  @override
  String get gxProximoModelo => 'Next cabinet';

  @override
  String get gxBuscarGabinete => 'Type to search';

  @override
  String get mcpConfiguracoes => 'Settings';

  @override
  String get mcpSecao => 'Local AI (MCP)';

  @override
  String get mcpPermitir => 'Allow AI via MCP';

  @override
  String get mcpPermitirTexto => 'An AI assistant on your computer (LM Studio, Claude Desktop…) can read the open preset and adjust the tone. Changes are heard right away and only go to the pedal if you save.';

  @override
  String get mcpEstadoDesligado => 'Off: no program can talk to the app.';

  @override
  String get mcpEstadoIniciando => 'Starting…';

  @override
  String mcpEstadoEscutando(String endereco) {
    return 'Listening on $endereco';
  }

  @override
  String mcpEstadoPortaOcupada(int porta) {
    return 'Port $porta is already used by another program (or another app window). Pick another port.';
  }

  @override
  String get mcpPorta => 'Port';

  @override
  String get mcpPortaInvalida => 'Use a number from 1024 to 65535.';

  @override
  String get mcpAplicarPorta => 'APPLY';

  @override
  String get mcpToken => 'Access token';

  @override
  String get mcpTokenTexto => 'The AI client sends this token with every request. Without it, the app does not obey.';

  @override
  String get mcpMostrarToken => 'Show token';

  @override
  String get mcpOcultarToken => 'Hide token';

  @override
  String get mcpCopiarToken => 'Copy token';

  @override
  String get mcpGerarNovoToken => 'NEW TOKEN';

  @override
  String get mcpGerarNovoTitulo => 'Generate a new token?';

  @override
  String get mcpGerarNovoTexto => 'The current token stops working right away: the AI client will need the new one.';

  @override
  String get mcpCopiarConfiguracao => 'Copy configuration for';

  @override
  String get mcpClienteLmStudio => 'LM Studio';

  @override
  String get mcpClienteClaudeDesktop => 'Claude Desktop';

  @override
  String get mcpClienteGenerico => 'Other client';

  @override
  String get mcpCopiado => 'Copied to the clipboard.';

  @override
  String get mcpLimitacoes => 'The AI cannot hear the sound: it adjusts from what you describe, and you tell it if it got better. Small models often describe what they would do instead of calling the tools; prefer a model with good tool support.';

  @override
  String get mcpAtivoNaBarra => 'AI';

  @override
  String get mcpAtivoDica => 'Local AI can adjust the tone (MCP on)';

  @override
  String mcpMudancaDaIa(String resumo) {
    return 'AI: $resumo';
  }

  @override
  String get mcpPedidoSalvarTitulo => 'Save what the AI adjusted?';

  @override
  String mcpPedidoSalvarTexto(String nome, String slot) {
    return 'The AI asked to write \"$nome\" to slot $slot on the pedal.';
  }

  @override
  String mcpPedidoSalvarSemSlot(String nome) {
    return 'The AI asked to write \"$nome\" to the pedal. You will pick the slot.';
  }

  @override
  String get mcpSalvar => 'SAVE';

  @override
  String get mcpAgoraNao => 'NOT NOW';

  @override
  String get ttDicaMouse => 'Rest the mouse on a control\'s name to see what it does to the sound';

  @override
  String get ttDicaToque => 'Tap a control\'s name to see what it does to the sound';

  @override
  String get smUmSplit => 'This preset already has a Split (one per preset).';

  @override
  String get smUmMerge => 'This preset already has a Merge (one per preset).';

  @override
  String get smMergeSemSplit => 'Add the Split first: the Merge joins row 2, which only exists with a Split.';

  @override
  String get smLinha2SemSplit => 'With no Split on row 1, this row gets no signal yet.';

  @override
  String get lpCriar => 'ADD PARALLEL ROW';

  @override
  String get lpCriarDica => 'Splits the signal after the selected row 1 block: row 2 plays in parallel and the Merge joins both before the output.';

  @override
  String get lpRemover => 'REMOVE PARALLEL ROW';

  @override
  String get lpSemEspaco => 'Row 1 needs two free positions for the Split and the Merge.';

  @override
  String get smFaixaCriar => '+ Add parallel row · Split, row 2 and Merge';

  @override
  String get smItemBiblioteca => 'Split + Merge (parallel row)';

  @override
  String get smItemBibliotecaDica => 'Splits the signal at this position: row 2 plays in parallel and the Merge joins both.';

  @override
  String get smJaTemLinhaParalela => 'This preset already has a parallel row (one Split and one Merge per preset).';

  @override
  String get smDividirDepois => 'Split the signal after this block';

  @override
  String get mpExportarJson => 'Export JSON…';

  @override
  String get mpLimpar => 'Clear preset…';

  @override
  String get mpLimparFabrica => 'Clear preset (Factory is read-only)';

  @override
  String mpLimparTitulo(String slot) {
    return 'Clear $slot?';
  }

  @override
  String mpLimparTexto(String nome, String slot) {
    return 'The preset \"$nome\" is removed from slot $slot on the pedal and the slot becomes empty. This can\'t be undone. To keep a copy, export the JSON first.';
  }

  @override
  String get mpExportarAntes => 'Export JSON';

  @override
  String get mpLimparConfirmar => 'Clear';

  @override
  String mpLimpo(String slot) {
    return '$slot cleared: the slot is now empty.';
  }

  @override
  String mpExportadoGravado(String slot) {
    return 'Exported the preset saved in $slot; unsaved edits were left out.';
  }

  @override
  String mpSlotVazio(String slot) {
    return '$slot is already empty on the pedal.';
  }

  @override
  String get axEntrada => 'Input';

  @override
  String get axOsciladores => 'Oscillators';

  @override
  String get axFiltro => 'Filter';

  @override
  String get axEnvelope => 'Envelope';

  @override
  String get axArpejador => 'Arpeggiator';

  @override
  String get axSaida => 'Output';

  @override
  String get axOutros => 'Other';

  @override
  String get ppTemplates => 'Templates';

  @override
  String get ppPersonalizado => 'Custom';

  @override
  String ppAplicado(String nome) {
    return 'Template $nome applied';
  }

  @override
  String get ppEscolherTemplate => 'Choose a template';

  @override
  String get ppDaDarkglass => 'From Darkglass (the pedal\'s own)';

  @override
  String get ppDoApp => 'From the app (our starting points)';

  @override
  String get ppAConfirmar => 'Values not read from the pedal yet';

  @override
  String get mbTipoDrive => 'Drive type';

  @override
  String get mbModoDrive => 'Drive mode';

  @override
  String get mbSolo => 'Solo';

  @override
  String mbSoloLigado(String banda) {
    return 'Only $banda playing';
  }

  @override
  String get mbSoloDesligado => 'Solo off: all three bands play';

  @override
  String mbCurvaCompressor(String limiar, String razao) {
    return 'Compressor curve: Threshold $limiar dB, Ratio $razao:1';
  }

  @override
  String get mbOff => 'OFF';

  @override
  String get pdSecao => 'Pedal';

  @override
  String get pdDica => 'Global Anagram settings: they apply to every preset and are not stored in the preset.';

  @override
  String get pdSaidas => 'Outputs';

  @override
  String get pdGlobalEq => 'Global EQ';

  @override
  String get pdEqModoGanho => 'Gain';

  @override
  String get pdEqModoFrequencia => 'Frequency';

  @override
  String get pdEqModoLargura => 'Width';

  @override
  String get pdEqInputGain => 'Input Gain';

  @override
  String get eqbResetTitulo => 'Reset the Parametric EQ?';

  @override
  String get eqbResetTexto => 'All bands, the cuts and the gain go back to the block defaults. You can undo it right after.';

  @override
  String get eqbResetFeito => 'Parametric EQ back to defaults.';

  @override
  String get pdEqReset => 'Reset';

  @override
  String get pdEqResetConfirmar => 'RESET';

  @override
  String get pdEqDica => 'The curve and the bands show the Global EQ the pedal has now; the mode picks what the bands show.';

  @override
  String get pdEntrada => 'Input';

  @override
  String get pdEntradaDica => 'Input gain for instrument 1 (−12 to +12 dB). The Anagram stores six instruments; the app only reads the first.';

  @override
  String get pdPlaca => 'Sound card';

  @override
  String get pdPlacaDica => 'Read only: the pedal does not accept changing these over USB.';

  @override
  String get pdAtualizar => 'Refresh';

  @override
  String get pdLendo => 'Reading the pedal settings…';

  @override
  String get pdFalhaLer => 'Could not read the pedal settings.';

  @override
  String get pdTentarDeNovo => 'Try again';

  @override
  String get registroSecao => 'Log for support';

  @override
  String get registroOnde => 'The app keeps a log of what happens in this file:';

  @override
  String get registroCopiar => 'Copy log';

  @override
  String get registroCopiado => 'Log copied. Paste it in the GitHub issue along with what happened.';

  @override
  String versaoNovaNaBarra(String versao) {
    return 'v$versao available';
  }

  @override
  String get versaoNovaBaixar => 'DOWNLOAD';

  @override
  String get versaoNovaLembrarDepois => 'Remind me later';

  @override
  String get versaoNovaSecao => 'Updates';

  @override
  String get versaoNovaVerificar => 'Check for a new version on launch';

  @override
  String get versaoNovaVerificarTexto => 'On launch the app asks only GitHub which version is the latest one published. None of your data is sent. When off, the app does not go online.';

  @override
  String get versaoNovaEmDia => 'You are on the latest version.';

  @override
  String versaoNovaDisponivel(String versao) {
    return 'Version $versao is available.';
  }

  @override
  String get versaoNovaSemResposta => 'Could not check right now; the app will try again next time it opens.';

  @override
  String get ctlTitulo => 'Pedal controls';

  @override
  String get ctlDicaMouse => 'Click a control to edit it. Right-click a knob to assign its parameter to a pot or the pedal; the block menu puts a footswitch on it.';

  @override
  String get ctlDicaToque => 'Tap a control to edit it or assign a parameter of the open block; the block menu puts a footswitch on it.';

  @override
  String get ctlSiglaFoot => 'FOOT';

  @override
  String get ctlSiglaPot => 'POT';

  @override
  String get ctlSiglaExp => 'EXP';

  @override
  String get ctlLivre => 'free';

  @override
  String get ctlLigaDesliga => 'On/off';

  @override
  String ctlAtribuirA(String controle) {
    return 'Assign to $controle';
  }

  @override
  String get ctlJaAqui => 'already here';

  @override
  String ctlFootswitchLigaBloco(int numero) {
    return 'Footswitch $numero turns this block on/off';
  }

  @override
  String get ctlNome => 'Name on the display';

  @override
  String ctlNomeLongo(int maximo) {
    return 'Factory presets use up to $maximo letters; a longer name may be cut on the display.';
  }

  @override
  String get ctlMinimo => 'MIN';

  @override
  String get ctlMaximo => 'MAX';

  @override
  String get ctlRemoverAlvo => 'Remove this parameter';

  @override
  String get ctlRemoverControle => 'CLEAR CONTROL';

  @override
  String get ctlAtribuirDoBloco => 'ASSIGN PARAMETER';

  @override
  String ctlEscolherParametro(String bloco) {
    return 'Parameter of $bloco';
  }

  @override
  String get ctlSemBlocoAberto => 'Open a block in the chain to assign one of its parameters.';

  @override
  String get ctlSemAlvos => 'No parameter on this control.';

  @override
  String get ctlFaixaIguais => 'Equal minimum and maximum leave the control without travel.';

  @override
  String get ctlFaixaFora => 'Outside the parameter range.';

  @override
  String ctlCasaVazia(int linha, int casa) {
    return 'empty slot $linha·$casa';
  }

  @override
  String ctlAtribuidoA(String controle) {
    return 'Assigned to $controle';
  }

  @override
  String get ctlAcaoAtribuir => 'Assign to a pedal control';

  @override
  String get ctlFechar => 'CLOSE';

  @override
  String get ctlDicaPedaleira => 'On the pedal, assigned pots only respond on the one-row preset screen; with the preset expanded, the knobs edit the selected block.';

  @override
  String get utTreino => 'Practice';

  @override
  String get utBater => 'Tap';

  @override
  String get utBaterSoNoFixo => 'Tap tempo works in Fixed Tempo mode only.';

  @override
  String slotAlteradoForaTitulo(String slot) {
    return '$slot changed on the pedal';
  }

  @override
  String slotAlteradoForaTexto(String slot) {
    return 'Slot $slot was changed on the pedal since you opened it. Overwrite saves your version over what is there; reload discards your edits and shows the pedal\'s version.';
  }

  @override
  String get sobrescreverMesmoAssim => 'OVERWRITE ANYWAY';

  @override
  String get recarregarDaPedaleira => 'RELOAD FROM PEDAL';

  @override
  String get uiRecarregarDaPedaleira => 'Reload from pedal';

  @override
  String recarregarTitulo(String slot) {
    return 'Reload $slot from the pedal?';
  }

  @override
  String recarregarTexto(String nome) {
    return 'The unsaved changes to \"$nome\" are lost and the editor shows what is saved in the slot.';
  }

  @override
  String get recarregar => 'RELOAD';

  @override
  String get pausaUsbTitulo => 'Pause between USB packets';

  @override
  String get pausaUsbTexto => 'Lower = faster live changes; raise it if the pedal stops responding. Auto uses this computer\'s default.';

  @override
  String get versaoNovaConsultaTexto => 'On launch the app asks only GitHub which version is the latest one published. The request sends only the app\'s version (in the User-Agent header); as with any connection, GitHub sees your IP address. When off, the app does not go online.';

  @override
  String get fmTitulo => 'Footswitches';

  @override
  String fmModo(String modo) {
    String _temp0 = intl.Intl.selectLogic(
      modo,
      {
        'preset': 'PRESET',
        'stomp': 'STOMP',
        'scene': 'SCENE',
        'other': '—',
      },
    );
    return '$_temp0';
  }

  @override
  String fmSemantica(String modo) {
    return 'Footswitches in $modo mode';
  }

  @override
  String get fmDica => 'In Stomp mode, the footswitches follow this preset\'s pedal controls. The mode applies to every preset.';

  @override
  String get fmErro => 'The pedal did not confirm the mode change. The mode shown is the one it has now.';

  @override
  String get fmIndisponivel => 'This pedal does not report the footswitch mode.';

  @override
  String fmAvisoControles(String modo) {
    return 'Assigned FOOTs only act in Stomp mode; the pedal is in $modo.';
  }

  @override
  String get fmDesconhecido => 'The pedal is in a mode this app does not know. Change the mode on the pedal itself.';

  @override
  String get t3kTom => 'Tone';

  @override
  String get t3kModelo => 'Model';

  @override
  String get t3kLendo => 'Reading the tones on the pedal…';

  @override
  String get t3kFalhou => 'The pedal did not send the tone list.';

  @override
  String get t3kTentarDeNovo => 'Try again';

  @override
  String t3kNaoEncontrado(String arquivo) {
    return 'Not found on the pedal: $arquivo';
  }

  @override
  String get t3kSoConsulta => 'Tone you uploaded: shown for reference only. The app cannot switch it yet.';

  @override
  String get t3kIrNaoConferido => 'The path of factory IRs has not been checked on a pedal yet: listen before saving.';

  @override
  String t3kResumo(int fabrica, int seus) {
    return 'On the pedal: $fabrica factory and $seus uploaded by you';
  }

  @override
  String t3kDetalheFabrica(String autor, String licenca) {
    return '$autor · $licenca license';
  }

  @override
  String t3kDetalheSeu(String autor, String licenca) {
    return '$autor · $licenca license · yours, reference only';
  }

  @override
  String get t3kSemAutor => 'no author';

  @override
  String get uiDicas => 'Tips';

  @override
  String ctlResumo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n assigned',
      one: '1 assigned',
      zero: 'none assigned',
    );
    return '$_temp0';
  }

  @override
  String get ctlMostrar => 'Show the pedal controls';

  @override
  String get ctlRecolher => 'Collapse the pedal controls';

  @override
  String sbSubstitui(String nome) {
    return 'replaces $nome';
  }

  @override
  String get sbSubstituirAqui => 'Replace the preset in this slot';

  @override
  String get salvarReleituraDiferente => 'the pedal confirmed, but the slot read back differs from what was sent. Your edit is still on screen; check the slot and save again.';

  @override
  String get pdSemAcesso => 'Output levels, Global EQ and input gain: the app has no access to these pedal features. The Anagram accepts a value sent to it, but does not apply it to the sound. Adjust them with the pedal\'s own knobs and screens; here you see the current values (tap Refresh after changing them).';

  @override
  String get utAcaoChave => 'In the app, this switch is the pedal\'s Action. Per the plugin\'s manual: turning it on starts the rhythm with an intro; while it plays, triggering again plays a fill; a double trigger stops; holding moves to the next part. What the drums play in each case is up to the plugin.';

  @override
  String get utSoNoVisor => 'Only on the pedal screen';

  @override
  String get caProcurando => 'Looking for the pedal…';

  @override
  String get caConectarAoAbrir => 'Connect on launch';

  @override
  String get caConectarAoAbrirTexto => 'On launch the app looks for the pedal on USB once. Connecting plays nothing; with no pedal, the connect screen stays as it is.';

  @override
  String get caConectarAoAbrirMac => 'On macOS, only after you allow Input Monitoring for Anagram App in System Settings › Privacy & Security.';

  @override
  String get caMonitoramentoNegado => 'macOS doesn\'t let Anagram App talk to the pedal yet. In System Settings › Privacy & Security › Input Monitoring, turn on Anagram App.';

  @override
  String get caAbrirAjustes => 'OPEN SYSTEM SETTINGS';

  @override
  String get caReabraDepois => 'After turning it on, quit and reopen Anagram App: macOS only applies it the next time the app opens.';
}
