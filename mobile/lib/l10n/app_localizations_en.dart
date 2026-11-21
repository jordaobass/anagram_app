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
  String get conexaoPermissaoNegada =>
      'The system denied access to the Anagram USB. On Android, tap Connect again and accept the request; on macOS, check Privacy & Security settings.';

  @override
  String get conexaoOcupada =>
      'The Anagram is plugged in, but another program is holding it. Close Darkglass Suite and any browser tab connected to the pedal.';

  @override
  String get conexaoSemAnagram =>
      'No Anagram found on USB. Check the cable and that the pedal is on.';

  @override
  String get conexaoSemResposta =>
      'The Anagram didn\'t answer. Unplug and replug the cable and try again.';

  @override
  String get conexaoRespostaInvalida => 'Unexpected reply from the pedal.';

  @override
  String get erroOcupada => 'Another program is holding the pedal.';

  @override
  String get erroDesconectado => 'The pedal is disconnected.';

  @override
  String get erroSemResposta => 'The pedal didn\'t answer in time.';

  @override
  String get erroRespostaInvalida =>
      'The pedal refused or sent an unexpected reply.';

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
  String get avisoPedaleiraDesconectada =>
      'The pedal was disconnected. Connect again to pick up where you left off.';

  @override
  String get avisoFormatoMaisNovo =>
      'This preset uses a newer format than this app: unknown fields are kept.';

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
  String get salvarDesconectada =>
      'the pedal is disconnected. Connect it and try again.';

  @override
  String get salvarSemResposta =>
      'the pedal didn\'t answer in time. The slot may not have been written; check it before trying again.';

  @override
  String get salvarRespostaInvalida =>
      'the pedal refused or sent an unexpected reply.';

  @override
  String get salvarOcupada => 'another program is holding the pedal.';

  @override
  String get indisponivelIos =>
      'iPhone and iPad don\'t let regular apps open the Anagram\'s USB control interface: that needs a DriverKit driver with special permission from Apple, which this app doesn\'t have yet. Use the demo here, or edit from a Mac, PC, Android or Chrome.';

  @override
  String get indisponivelNavegador =>
      'This browser doesn\'t have WebHID. Use Chrome or Edge on a computer, or the demo.';

  @override
  String get indisponivelSemUsb =>
      'This platform can\'t reach the pedal over USB.';

  @override
  String get importacaoIlegivel => 'Couldn\'t read the file.';

  @override
  String importacaoNaoEhPreset(String detalhe) {
    return 'This file is not an Anagram preset.';
  }

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
  String get conecteFecheSuite =>
      'Close Darkglass Suite first: only one program at a time can control the pedal.';

  @override
  String get abrirDemonstracao => 'OPEN DEMO';

  @override
  String get conectarPeloUsb => 'CONNECT OVER USB';

  @override
  String get cancelar => 'CANCEL';

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
  String get areaInativa =>
      'This area isn\'t active on the pedal: opening a preset only plays it, without switching the pedal\'s slot.';

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
  String get avisoAoVivoDesligado =>
      'LIVE OFF — edits stay in the app, the pedal doesn\'t change.';

  @override
  String get avisoAudicao =>
      'PREVIEW — the pedal stays on its own slot (no USB MIDI).';

  @override
  String get naoSalvo => 'NOT SAVED';

  @override
  String get escolhaUmPreset => 'Pick a preset';

  @override
  String slotEstaVazio(String slot) {
    return 'Slot $slot is empty';
  }

  @override
  String get escolhaUmPresetTexto =>
      'Opening it makes the pedal play it. Changes sound right away and are only stored when you save.';

  @override
  String get slotVazioTexto =>
      'Create a preset here. To bring blocks from another preset, use the copy icon in the block panel, then hold an empty position in the grid to paste.';

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
  String get dicaMontarCadeia =>
      'Tap a + in the grid to add an effect. Tap a block to adjust it; hold and drag it to move it.';

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
  String get creditoAutor =>
      'jordao_bass · free software, MIT license. Free of charge, no ads, no in-app purchases and no data collection.';

  @override
  String get creditoProtocoloTitulo => 'USB protocol and block catalog';

  @override
  String get creditoProtocolo =>
      'Ported from the anagram-tone-maker project by basster6 — MIT license (github.com/basster6/anagram-tone-maker).';

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
  String get creditoFontes =>
      'Barlow and Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).';

  @override
  String get creditoAvisoTitulo => 'Notice';

  @override
  String get creditoAviso =>
      'Unofficial app, not affiliated with Darkglass Electronics. Anagram is a trademark of its maker.';

  @override
  String get diagnosticoPausa => 'DIAGNOSTICS · PAUSE BETWEEN USB REPORTS';

  @override
  String get diagnosticoPausaTexto =>
      'Compare 0, 2 and 10 ms and watch the \"round trip\" in the bar and in the log.';

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
  String get txDicaMontarCadeiaMouse =>
      'Click a + in the grid to add an effect. Click a block to adjust it and drag it to move it.';

  @override
  String get txSlotVazioMouse =>
      'Create a preset here. To bring blocks from another preset, use the copy icon in the block panel, then right-click an empty position in the grid to paste.';

  @override
  String get txModoDemonstracaoTitulo => 'Demo mode';

  @override
  String get txSemUsbAquiCurto =>
      'Here the app can\'t reach the pedal over USB. Explore everything in demo mode.';

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
  String get lpCriar => 'ADD PARALLEL ROW';

  @override
  String get lpCriarDica =>
      'Splits the signal after the selected row 1 block: row 2 plays in parallel and the Merge joins both before the output.';

  @override
  String get lpRemover => 'REMOVE PARALLEL ROW';

  @override
  String get lpRemoverTitulo => 'Remove the parallel row?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'The Split, the Merge and the $quantidade row 2 blocks will be removed.';
  }

  @override
  String get lpRemoverConfirmar => 'REMOVE';

  @override
  String get lpSemEspaco =>
      'Row 1 needs two free positions for the Split and the Merge.';

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
}
