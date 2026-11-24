// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get desconectar => 'Déconnecter';

  @override
  String get creditos => 'Crédits';

  @override
  String get estadoSemConexao => 'Pas de connexion';

  @override
  String estadoConectando(String meio) {
    return 'Connexion ($meio)…';
  }

  @override
  String get estadoDemonstracao => 'Démo · sans pédale';

  @override
  String estadoConectada(String meio, String firmware) {
    return 'Anagram · $meio · $firmware';
  }

  @override
  String get estadoFalha => 'Échec de la connexion';

  @override
  String conexaoSemantica(String texto) {
    return 'Connexion : $texto';
  }

  @override
  String idaEVolta(int ms) {
    return 'aller-retour $ms ms';
  }

  @override
  String get aoVivo => 'EN DIRECT';

  @override
  String get aoVivoDesligado => 'DIRECT COUPÉ';

  @override
  String get conexaoPermissaoNegada =>
      'Le système a refusé l’accès à l’USB de l’Anagram. Sur Android, touchez de nouveau Connecter et acceptez la demande ; sur macOS, vérifiez les réglages Confidentialité et sécurité.';

  @override
  String get conexaoOcupada =>
      'L’Anagram est branchée, mais un autre programme l’occupe. Fermez Darkglass Suite et tout onglet du navigateur connecté à la pédale.';

  @override
  String get conexaoSemAnagram =>
      'Aucune Anagram trouvée en USB. Vérifiez le câble et que la pédale est allumée.';

  @override
  String get conexaoSemResposta =>
      'L’Anagram n’a pas répondu. Débranchez puis rebranchez le câble et réessayez.';

  @override
  String get conexaoRespostaInvalida => 'Réponse inattendue de la pédale.';

  @override
  String get erroOcupada => 'Un autre programme occupe la pédale.';

  @override
  String get erroDesconectado => 'La pédale est déconnectée.';

  @override
  String get erroSemResposta => 'La pédale n’a pas répondu à temps.';

  @override
  String get erroRespostaInvalida =>
      'La pédale a refusé ou envoyé une réponse inattendue.';

  @override
  String erroOperacaoEmCurso(String detalhe) {
    return 'Attendez la fin de l’opération en cours.';
  }

  @override
  String get erroSemSuporte =>
      'Cette plateforme ne peut pas communiquer avec la pédale.';

  @override
  String get avisoDemonstracaoFalhou => 'Impossible d’ouvrir la démo.';

  @override
  String avisoFalhaInesperada(String meio) {
    return 'Impossible d’ouvrir $meio. Réessayez ; les détails sont dans le journal.';
  }

  @override
  String get avisoPedaleiraDesconectada =>
      'La pédale a été déconnectée. Reconnectez-la pour reprendre là où vous en étiez.';

  @override
  String get avisoFormatoMaisNovo =>
      'Ce preset utilise un format plus récent que cette app : les champs inconnus sont conservés.';

  @override
  String avisoPresetAtualizado(String slot) {
    return '$slot a été modifié hors de l’app ; la liste a été rechargée et la version actuelle a été ouverte.';
  }

  @override
  String avisoPresetTrocado(String slot) {
    return 'La pédale a renvoyé un autre preset pour $slot (l’identifiant diffère de la liste). La liste a été rechargée ; ouvrez-le de nouveau.';
  }

  @override
  String get avisoAreaNaoTrocou => 'La pédale n’a pas changé de zone.';

  @override
  String naoSalvou(String motivo) {
    return 'Non enregistré : $motivo';
  }

  @override
  String get salvarDesconectada =>
      'la pédale est déconnectée. Connectez-la et réessayez.';

  @override
  String get salvarSemResposta =>
      'la pédale n’a pas répondu à temps. L’emplacement n’a peut-être pas été écrit ; vérifiez-le avant de réessayer.';

  @override
  String get salvarRespostaInvalida =>
      'la pédale a refusé ou envoyé une réponse inattendue.';

  @override
  String get salvarOcupada => 'un autre programme occupe la pédale.';

  @override
  String get indisponivelIos =>
      'L’iPhone et l’iPad ne laissent pas une app ordinaire ouvrir l’interface de contrôle USB de l’Anagram : il faut un pilote DriverKit avec une autorisation spéciale d’Apple, que cette app n’a pas encore. Utilisez la démo ici, ou éditez depuis un Mac, un PC, Android ou Chrome.';

  @override
  String get indisponivelNavegador =>
      'Ce navigateur n’a pas WebHID. Utilisez Chrome ou Edge sur un ordinateur, ou la démo.';

  @override
  String get indisponivelSemUsb =>
      'Cette plateforme ne peut pas joindre la pédale en USB.';

  @override
  String get importacaoIlegivel => 'Impossible de lire le fichier.';

  @override
  String get importacaoNaoEhPreset => 'Ce fichier n’est pas un preset Anagram.';

  @override
  String get exportacaoFalhou => 'Impossible d’enregistrer le fichier.';

  @override
  String get nomeVazio => 'Le nom ne peut pas être vide.';

  @override
  String nomeComMarcador(String marcador) {
    return 'Le nom ne peut pas contenir « $marcador ».';
  }

  @override
  String get familiaDrive => 'Drive';

  @override
  String get familiaDinamica => 'Dynamique';

  @override
  String get familiaEq => 'EQ';

  @override
  String get familiaFiltro => 'Filtre';

  @override
  String get familiaModulacao => 'Modulation';

  @override
  String get familiaDelay => 'Delay';

  @override
  String get familiaReverb => 'Reverb';

  @override
  String get familiaAmp => 'Ampli';

  @override
  String get familiaGabinete => 'Baffle';

  @override
  String get familiaUtilitario => 'Utilitaire';

  @override
  String areaSemNome(int numero) {
    return 'Zone $numero';
  }

  @override
  String get conecteTitulo => 'Connectez l’Anagram en USB';

  @override
  String get conecteFecheSuite =>
      'Fermez d’abord Darkglass Suite : un seul programme à la fois peut contrôler la pédale.';

  @override
  String get abrirDemonstracao => 'OUVRIR LA DÉMO';

  @override
  String get conectarPeloUsb => 'CONNECTER EN USB';

  @override
  String get cancelar => 'ANNULER';

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
    return 'v$versao · art de la pédale';
  }

  @override
  String get fecharAviso => 'Fermer';

  @override
  String get largarEdicoesTitulo => 'Abandonner les modifications ?';

  @override
  String largarEdicoesTexto(String nome) {
    return '« $nome » a des modifications non enregistrées dans l’emplacement.';
  }

  @override
  String get continuarEditando => 'CONTINUER';

  @override
  String get largar => 'ABANDONNER';

  @override
  String get origem => 'SOURCE';

  @override
  String get gravarAqui => 'Enregistrer ici';

  @override
  String get pedaleiraNesteSlot => 'La pédale est sur cet emplacement';

  @override
  String get slotVazio => 'vide';

  @override
  String get area => 'ZONE';

  @override
  String largarAoTrocarArea(String nome) {
    return '« $nome » a des modifications non enregistrées et sera fermé au changement de zone.';
  }

  @override
  String get areaInativa =>
      'Cette zone n’est pas active sur la pédale : ouvrir un preset le fait seulement jouer, sans changer l’emplacement de la pédale.';

  @override
  String get tornarAtiva => 'ACTIVER';

  @override
  String get salvar => 'ENREGISTRER';

  @override
  String get salvarComo => 'ENREGISTRER SOUS…';

  @override
  String get descartar => 'ABANDONNER';

  @override
  String get menuArquivo => 'Importer ou exporter en JSON';

  @override
  String get importarPreset => 'Importer un preset (.json)';

  @override
  String get exportarPreset => 'Exporter le preset (.json)';

  @override
  String presetImportado(String nome) {
    return '« $nome » importé. Enregistrez-le dans un emplacement pour le garder.';
  }

  @override
  String get presetExportado => 'Preset exporté.';

  @override
  String get presetCopiado => 'JSON du preset copié dans le presse-papiers.';

  @override
  String presetSalvoEm(String nome, String slot) {
    return '« $nome » enregistré dans $slot.';
  }

  @override
  String substituirTitulo(String slot) {
    return 'Remplacer $slot ?';
  }

  @override
  String substituirTexto(String slot, String nome) {
    return 'L’emplacement $slot contient « $nome ». Il sera remplacé par le preset modifié.';
  }

  @override
  String get substituir => 'REMPLACER';

  @override
  String get salvarComoEscolhaDestino =>
      'ENREGISTRER SOUS : TOUCHEZ L’EMPLACEMENT DE DESTINATION';

  @override
  String slotSemantica(String slot) {
    return 'Emplacement $slot';
  }

  @override
  String get slotNovo => 'nouveau';

  @override
  String get abrirListaSemantica => ', ouvrir la liste des presets';

  @override
  String renomearPresetSemantica(String nome) {
    return 'Renommer le preset $nome';
  }

  @override
  String get avisoAoVivoDesligado =>
      'DIRECT COUPÉ — les modifications restent dans l’app, la pédale ne change pas.';

  @override
  String get avisoAudicao =>
      'ÉCOUTE — la pédale reste sur son propre emplacement (pas de MIDI USB).';

  @override
  String get naoSalvo => 'NON ENREGISTRÉ';

  @override
  String get escolhaUmPreset => 'Choisissez un preset';

  @override
  String slotEstaVazio(String slot) {
    return 'L’emplacement $slot est vide';
  }

  @override
  String get escolhaUmPresetTexto =>
      'En l’ouvrant, la pédale le joue. Les changements s’entendent tout de suite et ne sont gardés que si vous enregistrez.';

  @override
  String get slotVazioTexto =>
      'Créez un preset ici. Pour reprendre des blocs d’un autre preset, utilisez l’icône de copie dans le panneau du bloc, puis maintenez une case vide de la grille pour coller.';

  @override
  String get criarPresetAqui => 'CRÉER UN PRESET ICI';

  @override
  String get verPresets => 'VOIR LES PRESETS';

  @override
  String get nomeDoPreset => 'Nom du preset';

  @override
  String get nome => 'Nom';

  @override
  String get renomear => 'RENOMMER';

  @override
  String blocoPosicao(String familia, int linha, int casa) {
    return '$familia · ligne $linha, case $casa';
  }

  @override
  String get arrasteComMouse =>
      'Faites-le glisser dans la grille pour le déplacer';

  @override
  String get arrasteNoToque =>
      'Maintenez et faites glisser dans la grille pour le déplacer';

  @override
  String ligadoSoNaCena(int cena) {
    return 'ACTIF SEULEMENT DANS LA SCÈNE $cena';
  }

  @override
  String desligadoSoNaCena(int cena) {
    return 'COUPÉ SEULEMENT DANS LA SCÈNE $cena';
  }

  @override
  String get copiarBloco => 'Copier le bloc';

  @override
  String get maisAcoesBloco => 'Plus d’actions sur le bloc';

  @override
  String get blocoLigadoSemantica => 'Bloc actif';

  @override
  String get ligado => 'ON';

  @override
  String get desligado => 'OFF';

  @override
  String get adicionarEfeitoMenu => 'Ajouter un effet…';

  @override
  String get colarAqui => 'Coller ici';

  @override
  String get ligarDesligar => 'Activer / couper';

  @override
  String get moverEsquerda => 'Déplacer à gauche';

  @override
  String get moverDireita => 'Déplacer à droite';

  @override
  String moverParaLinha(int linha) {
    return 'Déplacer vers la ligne $linha';
  }

  @override
  String get removerBloco => 'Retirer le bloc';

  @override
  String get semParametros => 'Ce bloc n’a aucun paramètre réglable.';

  @override
  String soNaCena(int cena) {
    return 'SEULEMENT DANS LA SCÈNE $cena';
  }

  @override
  String ligadoNasCenas(String cenas) {
    return 'ACTIF DANS LES SCÈNES $cenas';
  }

  @override
  String desligadoNasCenas(String cenas) {
    return 'COUPÉ DANS LES SCÈNES $cenas';
  }

  @override
  String get ligadoVariaEntreCenas =>
      'ACTIF DANS CETTE SCÈNE · VARIE ENTRE LES SCÈNES';

  @override
  String get desligadoVariaEntreCenas =>
      'COUPÉ DANS CETTE SCÈNE · VARIE ENTRE LES SCÈNES';

  @override
  String nasCenas(String cenas) {
    return 'DANS LES SCÈNES $cenas';
  }

  @override
  String get variaEntreCenas => 'VARIE ENTRE LES SCÈNES';

  @override
  String get dicaMontarCadeia =>
      'Touchez un + dans la grille pour ajouter un effet. Touchez un bloc pour le régler ; maintenez-le et faites-le glisser pour le déplacer.';

  @override
  String faixaEstimada(String simbolo) {
    return '$simbolo (plage estimée)';
  }

  @override
  String get adicionarEfeito => 'Ajouter un effet';

  @override
  String linhaCasa(int linha, int casa) {
    return 'Ligne $linha, case $casa';
  }

  @override
  String get buscarPeloNome => 'Rechercher par nom';

  @override
  String get todos => 'Tous';

  @override
  String nenhumEfeito(String busca) {
    return 'Aucun effet pour « $busca ».';
  }

  @override
  String nenhumEfeitoNaFamilia(String busca, String familia) {
    return 'Aucun effet pour « $busca » dans $familia.';
  }

  @override
  String get sobreTitulo => 'À propos et diagnostic';

  @override
  String get creditoAutorTitulo => 'Auteur';

  @override
  String get creditoAutor =>
      'jordao_bass · logiciel libre, licence MIT. Gratuit, sans publicité, sans achat intégré et sans collecte de données.';

  @override
  String get creditoProtocoloTitulo => 'Protocole USB et catalogue des blocs';

  @override
  String get creditoProtocolo =>
      'Porté du projet anagram-tone-maker de basster6 — licence MIT (github.com/basster6/anagram-tone-maker).';

  @override
  String get creditoArteTitulo => 'Art des blocs';

  @override
  String get creditoArtePropria =>
      'L’art propre de l’app, par catégorie de bloc.';

  @override
  String get creditoImagensTitulo => 'Images des blocs';

  @override
  String creditoImagens(String credito) {
    return '$credito. Les blocs sans image utilisent l’art propre de l’app, par catégorie.';
  }

  @override
  String get creditoFontesTitulo => 'Polices';

  @override
  String get creditoFontes =>
      'Barlow et Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).';

  @override
  String get creditoAvisoTitulo => 'Avertissement';

  @override
  String get creditoAviso =>
      'App non officielle, sans lien avec Darkglass Electronics. Anagram est une marque de son fabricant.';

  @override
  String get diagnosticoPausa => 'DIAGNOSTIC · PAUSE ENTRE LES RAPPORTS USB';

  @override
  String get diagnosticoPausaTexto =>
      'Comparez 0, 2 et 10 ms et surveillez l’« aller-retour » dans la barre et dans le journal.';

  @override
  String get idioma => 'Langue';

  @override
  String get idiomaDoSistema => 'Système';

  @override
  String get temaSecao => 'Apparence';

  @override
  String get temaSistema => 'Système';

  @override
  String get temaEscuro => 'Sombre';

  @override
  String get temaClaro => 'Clair';

  @override
  String get separadorDecimal => ',';

  @override
  String get valorLigado => 'Activé';

  @override
  String get valorDesligado => 'Désactivé';

  @override
  String get voltarAoPadrao => 'Rétablir la valeur par défaut';

  @override
  String voltouAoPadrao(String parametro) {
    return '$parametro est revenu à sa valeur par défaut.';
  }

  @override
  String get desfazer => 'ANNULER';

  @override
  String get pausaAuto => 'Auto';

  @override
  String get linha1 => 'LIGNE 1';

  @override
  String get linha2Paralela => 'LIGNE 2 · PARALLÈLE';

  @override
  String cenaSemantica(int numero, String nome) {
    return 'Scène $numero, $nome';
  }

  @override
  String cenaPadrao(int numero) {
    return 'Scène $numero';
  }

  @override
  String adicionarEfeitoNaCasa(int casa, int linha) {
    return 'Ajouter un effet à la case $casa, ligne $linha';
  }

  @override
  String blocoLigado(String nome) {
    return '$nome, actif';
  }

  @override
  String blocoDesligado(String nome) {
    return '$nome, coupé';
  }

  @override
  String get presets => 'Presets';

  @override
  String get txDicaMontarCadeiaMouse =>
      'Cliquez sur un + dans la grille pour ajouter un effet. Cliquez sur un bloc pour le régler et faites-le glisser pour le déplacer.';

  @override
  String get txSlotVazioMouse =>
      'Créez un preset ici. Pour reprendre des blocs d’un autre preset, utilisez l’icône de copie dans le panneau du bloc, puis faites un clic droit sur une case vide de la grille pour coller.';

  @override
  String get txModoDemonstracaoTitulo => 'Mode démo';

  @override
  String get txSemUsbAquiCurto =>
      'Ici, l’app ne peut pas joindre la pédale en USB. Explorez tout en mode démo.';

  @override
  String get txPorQue => 'POURQUOI ?';

  @override
  String get txEntendi => 'COMPRIS';

  @override
  String get txAtiva => 'ACTIVE';

  @override
  String get txAtivaNaPedaleiraDica => 'Zone active sur la pédale';

  @override
  String get txEstadoAbrindoDemonstracao => 'Ouverture de la démo…';

  @override
  String get cdNovoPreset => 'Nouveau preset';

  @override
  String get uiPresets => 'PRESETS';

  @override
  String get uiMaisAcoesPreset => 'Plus d’actions sur le preset';

  @override
  String get uiMenuArquivo => 'Importer ou exporter le preset';

  @override
  String get uiDescartarEdicoes => 'Annuler les modifications';

  @override
  String get uiFecharBiblioteca => 'Fermer';

  @override
  String get uiCena => 'SCÈNE';

  @override
  String get uiSeloDesligado => 'OFF';

  @override
  String get uiRenomear => 'Renommer';

  @override
  String get uiDicaDuploClique =>
      'Double-cliquez sur la pédale pour l’activer ou la couper';

  @override
  String get uiDicaToqueDuplo =>
      'Touchez deux fois la pédale pour l’activer ou la couper';

  @override
  String get cdBlocoMono => 'Mono';

  @override
  String get cdBlocoEstereo => 'Stéréo';

  @override
  String get cdBlocoMonoCurto => 'M';

  @override
  String get cdBlocoEstereoCurto => 'ST';

  @override
  String get kbDigitarDica => 'Cliquez sur le nombre pour saisir une valeur';

  @override
  String kbFaixa(String minimo, String maximo) {
    return 'De $minimo à $maximo';
  }

  @override
  String get kbNaoEhNumero => 'Saisissez un nombre, comme -12,5 ou 1,5k.';

  @override
  String get kbAplicar => 'APPLIQUER';

  @override
  String get lpRemoverTitulo => 'Retirer le Split ?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'Sans le Split, la ligne 2 ne reçoit plus de signal : le Merge et les $quantidade blocs de la ligne 2 partent aussi.';
  }

  @override
  String get lpRemoverConfirmar => 'RETIRER';

  @override
  String get cbGabinete => 'Baffle';

  @override
  String get cbMicrofone => 'Micro';

  @override
  String get cbPosicao => 'Position';

  @override
  String get cbEscolher => 'Choisir';

  @override
  String cbIrDoUsuario(String arquivo) {
    return 'IR perso : $arquivo';
  }

  @override
  String get opMoverPara => 'Déplacer vers…';

  @override
  String get opClonarPara => 'Dupliquer vers…';

  @override
  String get opTrocarBanco => 'Échanger la banque avec…';

  @override
  String get opAcoesPreset => 'Déplacer, dupliquer ou échanger de banque';

  @override
  String opDestinoMover(String origem) {
    return 'Déplacer $origem : touchez l’emplacement de destination';
  }

  @override
  String opDestinoClonar(String origem) {
    return 'Dupliquer $origem : touchez l’emplacement de destination';
  }

  @override
  String opDestinoBanco(String banco) {
    return 'Échanger la banque $banco : touchez un emplacement de l’autre banque';
  }

  @override
  String get opTrocarTitulo => 'Échanger les deux presets ?';

  @override
  String opTrocarTexto(String destino, String nome, String origem) {
    return '$destino contient « $nome ». Il passe en $origem.';
  }

  @override
  String get opTrocar => 'ÉCHANGER';

  @override
  String opSubstituirTitulo(String destino) {
    return 'Remplacer $destino ?';
  }

  @override
  String opSubstituirTexto(String nome, String origem) {
    return '« $nome » sera effacé et remplacé par la copie de $origem.';
  }

  @override
  String get opSubstituir => 'REMPLACER';

  @override
  String opBancosTitulo(String a, String b) {
    return 'Échanger les banques $a et $b ?';
  }

  @override
  String get opBancosTexto =>
      'Les trois presets de chaque banque échangent leur place.';

  @override
  String opMovido(String origem, String destino) {
    return '$origem déplacé vers $destino.';
  }

  @override
  String opClonado(String origem, String destino) {
    return 'Copie de $origem enregistrée dans $destino.';
  }

  @override
  String opBancosTrocados(String a, String b) {
    return 'Banques $a et $b échangées.';
  }

  @override
  String get fbAreaFabrica => 'Usine';

  @override
  String get fbSoLeitura => 'LECTURE SEULE';

  @override
  String get fbAreaSoLeitura =>
      'Presets d’usine Darkglass : en ouvrir un le fait seulement jouer. Pour en garder un, copiez-le dans une de vos zones.';

  @override
  String get fbAvisoPresetDeFabrica =>
      'PRESET D’USINE — lecture seule. Copiez-le dans une de vos zones pour le garder.';

  @override
  String get fbCopiarParaMinhaArea => 'COPIER DANS MA ZONE…';

  @override
  String get fbCopiarTitulo => 'Copier dans quelle zone ?';

  @override
  String get fbCopiarPara => 'Copier dans ma zone…';

  @override
  String get eqBandaGeral => 'Général';

  @override
  String get eqPassaAltas => 'Passe-haut';

  @override
  String get eqPassaBaixas => 'Passe-bas';

  @override
  String get eqShelfGraves => 'Shelf graves';

  @override
  String eqBanda(int numero) {
    return 'Bande $numero';
  }

  @override
  String get eqShelfAgudos => 'Shelf aigus';

  @override
  String get mbGraves => 'Graves';

  @override
  String get mbMedios => 'Médiums';

  @override
  String get mbAgudos => 'Aigus';

  @override
  String get mbBordaGraves => '20 Hz';

  @override
  String get mbBordaAgudos => '20 kHz';

  @override
  String get mbMudo => 'Muet';

  @override
  String get mbCompLigada => 'Comp actif';

  @override
  String get mbCompDesligada => 'Comp coupé';

  @override
  String get mbSaida => 'Sortie';

  @override
  String get mbOutros => 'Autres';

  @override
  String get mbExplicaMisturaLimpa =>
      'Comp Level est le volume des trois bandes compressées. Clean Level mélange en parallèle le signal sec, non compressé : au minimum (−24 dB) on entend presque seulement le son compressé ; en le montant, l’attaque naturelle de la corde revient.';

  @override
  String get mbBuscarOpcao => 'Rechercher (ex. : turbo grunt)';

  @override
  String get smOrdemInvalida =>
      'Le Split doit rester avant le Merge sur la ligne 1.';

  @override
  String get smSoNaLinha1 => 'Le Split et le Merge restent sur la ligne 1.';

  @override
  String gvAnterior(String rotulo) {
    return '$rotulo : option précédente';
  }

  @override
  String gvProximo(String rotulo) {
    return '$rotulo : option suivante';
  }

  @override
  String gvAbrirLista(String rotulo, String nome) {
    return '$rotulo : $nome. Touchez pour tout voir';
  }

  @override
  String get gvBuscar => 'Tapez pour rechercher';

  @override
  String get gvNadaEncontrado => 'Aucun résultat';

  @override
  String get gxModeloAnterior => 'Baffle précédent';

  @override
  String get gxProximoModelo => 'Baffle suivant';

  @override
  String get gxBuscarGabinete => 'Tapez pour rechercher';

  @override
  String get mcpConfiguracoes => 'Paramètres';

  @override
  String get mcpSecao => 'IA locale (MCP)';

  @override
  String get mcpPermitir => 'Autoriser l’IA via MCP';

  @override
  String get mcpPermitirTexto =>
      'Un assistant IA sur votre ordinateur (LM Studio, Claude Desktop…) peut lire le preset ouvert et ajuster le son. Les changements s’entendent tout de suite et ne vont dans la pédale que si vous enregistrez.';

  @override
  String get mcpEstadoDesligado =>
      'Désactivée : aucun programme ne peut parler à l’app.';

  @override
  String get mcpEstadoIniciando => 'Démarrage…';

  @override
  String mcpEstadoEscutando(String endereco) {
    return 'À l’écoute sur $endereco';
  }

  @override
  String mcpEstadoPortaOcupada(int porta) {
    return 'Le port $porta est déjà utilisé par un autre programme (ou une autre fenêtre de l’app). Choisissez un autre port.';
  }

  @override
  String get mcpPorta => 'Port';

  @override
  String get mcpPortaInvalida => 'Utilisez un nombre de 1024 à 65535.';

  @override
  String get mcpAplicarPorta => 'APPLIQUER';

  @override
  String get mcpToken => 'Jeton d’accès';

  @override
  String get mcpTokenTexto =>
      'Le client IA envoie ce jeton à chaque requête. Sans lui, l’app n’obéit pas.';

  @override
  String get mcpMostrarToken => 'Afficher le jeton';

  @override
  String get mcpOcultarToken => 'Masquer le jeton';

  @override
  String get mcpCopiarToken => 'Copier le jeton';

  @override
  String get mcpGerarNovoToken => 'NOUVEAU JETON';

  @override
  String get mcpGerarNovoTitulo => 'Générer un nouveau jeton ?';

  @override
  String get mcpGerarNovoTexto =>
      'Le jeton actuel cesse de fonctionner tout de suite : le client IA aura besoin du nouveau.';

  @override
  String get mcpCopiarConfiguracao => 'Copier la configuration pour';

  @override
  String get mcpClienteLmStudio => 'LM Studio';

  @override
  String get mcpClienteClaudeDesktop => 'Claude Desktop';

  @override
  String get mcpClienteGenerico => 'Autre client';

  @override
  String get mcpCopiado => 'Copié dans le presse-papiers.';

  @override
  String get mcpLimitacoes =>
      'L’IA n’entend pas le son : elle ajuste d’après ce que vous décrivez, et vous lui dites si c’est mieux. Les petits modèles décrivent souvent ce qu’ils feraient au lieu d’appeler les outils ; préférez un modèle qui gère bien les outils.';

  @override
  String get mcpAtivoNaBarra => 'IA';

  @override
  String get mcpAtivoDica => 'L’IA locale peut ajuster le son (MCP actif)';

  @override
  String mcpMudancaDaIa(String resumo) {
    return 'IA : $resumo';
  }

  @override
  String get mcpPedidoSalvarTitulo => 'Enregistrer ce que l’IA a réglé ?';

  @override
  String mcpPedidoSalvarTexto(String nome, String slot) {
    return 'L’IA demande d’écrire « $nome » dans l’emplacement $slot de la pédale.';
  }

  @override
  String mcpPedidoSalvarSemSlot(String nome) {
    return 'L’IA demande d’écrire « $nome » dans la pédale. C’est vous qui choisirez l’emplacement.';
  }

  @override
  String get mcpSalvar => 'ENREGISTRER';

  @override
  String get mcpAgoraNao => 'PAS MAINTENANT';

  @override
  String get ttDicaMouse =>
      'Passez la souris sur le nom d’un réglage pour voir ce qu’il fait au son';

  @override
  String get ttDicaToque =>
      'Touchez le nom d’un réglage pour voir ce qu’il fait au son';

  @override
  String get smUmSplit => 'Ce preset a déjà un Split (un par preset).';

  @override
  String get smUmMerge => 'Ce preset a déjà un Merge (un par preset).';

  @override
  String get smMergeSemSplit =>
      'Ajoutez d’abord le Split : le Merge rejoint la ligne 2, qui n’existe qu’avec un Split.';

  @override
  String get smLinha2SemSplit =>
      'Sans Split sur la ligne 1, cette ligne ne reçoit pas encore de signal.';

  @override
  String get lpCriar => 'AJOUTER UNE LIGNE PARALLÈLE';

  @override
  String get lpCriarDica =>
      'Divise le signal après le bloc choisi de la ligne 1 : la ligne 2 joue en parallèle et le Merge réunit les deux avant la sortie.';

  @override
  String get lpRemover => 'RETIRER LA LIGNE PARALLÈLE';

  @override
  String get lpSemEspaco =>
      'La ligne 1 a besoin de deux cases libres pour le Split et le Merge.';

  @override
  String get smFaixaCriar =>
      '+ Ajouter une ligne parallèle · Split, ligne 2 et Merge';

  @override
  String get smItemBiblioteca => 'Split + Merge (ligne parallèle)';

  @override
  String get smItemBibliotecaDica =>
      'Divise le signal à cette case : la ligne 2 joue en parallèle et le Merge réunit les deux.';

  @override
  String get smJaTemLinhaParalela =>
      'Ce preset a déjà une ligne parallèle (un Split et un Merge par preset).';

  @override
  String get smDividirDepois => 'Diviser le signal après ce bloc';

  @override
  String get mpExportarJson => 'Exporter en JSON…';

  @override
  String get mpLimpar => 'Vider le preset…';

  @override
  String get mpLimparFabrica => 'Vider le preset (Usine est en lecture seule)';

  @override
  String mpLimparTitulo(String slot) {
    return 'Vider $slot ?';
  }

  @override
  String mpLimparTexto(String nome, String slot) {
    return 'Le preset « $nome » est retiré de l’emplacement $slot de la pédale et l’emplacement devient vide. C’est irréversible. Pour garder une copie, exportez d’abord le JSON.';
  }

  @override
  String get mpExportarAntes => 'Exporter le JSON';

  @override
  String get mpLimparConfirmar => 'Vider';

  @override
  String mpLimpo(String slot) {
    return '$slot vidé : l’emplacement est maintenant vide.';
  }

  @override
  String mpExportadoGravado(String slot) {
    return 'Le preset enregistré dans $slot a été exporté ; les modifications non enregistrées n’y sont pas.';
  }

  @override
  String mpSlotVazio(String slot) {
    return '$slot est déjà vide sur la pédale.';
  }

  @override
  String get axEntrada => 'Entrée';

  @override
  String get axOsciladores => 'Oscillateurs';

  @override
  String get axFiltro => 'Filtre';

  @override
  String get axEnvelope => 'Enveloppe';

  @override
  String get axArpejador => 'Arpégiateur';

  @override
  String get axSaida => 'Sortie';

  @override
  String get axOutros => 'Autres';

  @override
  String get ppTemplates => 'Modèles';

  @override
  String get ppPersonalizado => 'Perso';

  @override
  String ppAplicado(String nome) {
    return 'Modèle $nome appliqué';
  }

  @override
  String get ppEscolherTemplate => 'Choisir un modèle';

  @override
  String get ppDaDarkglass => 'De Darkglass (ceux de la pédale)';

  @override
  String get ppDoApp => 'De l’app (nos points de départ)';

  @override
  String get ppAConfirmar => 'Valeurs pas encore lues sur la pédale';

  @override
  String get mbTipoDrive => 'Type de drive';

  @override
  String get mbModoDrive => 'Mode du drive';

  @override
  String get mbSolo => 'Solo';

  @override
  String mbSoloLigado(String banda) {
    return 'Seule la bande $banda joue';
  }

  @override
  String get mbSoloDesligado => 'Solo coupé : les trois bandes jouent';

  @override
  String mbCurvaCompressor(String limiar, String razao) {
    return 'Courbe du compresseur : Threshold $limiar dB, Ratio $razao:1';
  }

  @override
  String get mbOff => 'OFF';

  @override
  String get pdSecao => 'Pédale';

  @override
  String get pdDica =>
      'Réglages globaux de l’Anagram : ils valent pour tous les presets et ne sont pas gardés dans le preset.';

  @override
  String get pdSaidas => 'Sorties';

  @override
  String get pdGlobalEq => 'Global EQ';

  @override
  String get pdEqModoGanho => 'Gain';

  @override
  String get pdEqModoFrequencia => 'Fréquence';

  @override
  String get pdEqModoLargura => 'Largeur';

  @override
  String get pdEqInputGain => 'Input Gain';

  @override
  String get eqbResetTitulo => 'Réinitialiser le Parametric EQ ?';

  @override
  String get eqbResetTexto =>
      'Toutes les bandes, les filtres passe-haut et passe-bas et le gain reviennent aux valeurs par défaut du bloc. Vous pouvez annuler juste après.';

  @override
  String get eqbResetFeito => 'Parametric EQ revenu aux valeurs par défaut.';

  @override
  String get pdEqReset => 'Réinitialiser';

  @override
  String get pdEqResetConfirmar => 'RÉINITIALISER';

  @override
  String get pdEqDica =>
      'La courbe et les bandes montrent le Global EQ actuel de la pédale ; le mode choisit ce que montrent les bandes.';

  @override
  String get pdEntrada => 'Entrée';

  @override
  String get pdEntradaDica =>
      'Gain d’entrée de l’instrument 1 (−12 à +12 dB). L’Anagram garde six instruments ; l’app ne lit que le premier.';

  @override
  String get pdPlaca => 'Carte son';

  @override
  String get pdPlacaDica =>
      'Lecture seule : la pédale n’accepte pas de changer ces réglages en USB.';

  @override
  String get pdAtualizar => 'Actualiser';

  @override
  String get pdLendo => 'Lecture des réglages de la pédale…';

  @override
  String get pdFalhaLer => 'Impossible de lire les réglages de la pédale.';

  @override
  String get pdTentarDeNovo => 'Réessayer';

  @override
  String get registroSecao => 'Journal pour le support';

  @override
  String get registroOnde =>
      'L’app tient un journal de ce qui se passe dans ce fichier :';

  @override
  String get registroCopiar => 'Copier le journal';

  @override
  String get registroCopiado =>
      'Journal copié. Collez-le dans le ticket GitHub avec ce qui s’est passé.';

  @override
  String versaoNovaNaBarra(String versao) {
    return 'v$versao disponible';
  }

  @override
  String get versaoNovaBaixar => 'TÉLÉCHARGER';

  @override
  String get versaoNovaLembrarDepois => 'Me le rappeler plus tard';

  @override
  String get versaoNovaSecao => 'Mises à jour';

  @override
  String get versaoNovaVerificar =>
      'Chercher une nouvelle version au lancement';

  @override
  String get versaoNovaVerificarTexto =>
      'Au lancement, l’app demande seulement à GitHub quelle est la dernière version publiée. Aucune de vos données n’est envoyée. Si l’option est désactivée, l’app ne se connecte pas à Internet.';

  @override
  String get versaoNovaEmDia => 'Vous avez la dernière version.';

  @override
  String versaoNovaDisponivel(String versao) {
    return 'La version $versao est disponible.';
  }

  @override
  String get versaoNovaSemResposta =>
      'Vérification impossible pour l’instant ; l’app réessaiera à sa prochaine ouverture.';

  @override
  String get ctlTitulo => 'Contrôles de la pédale';

  @override
  String get ctlDicaMouse =>
      'Cliquez sur un contrôle pour le modifier. Faites un clic droit sur un potard pour assigner son paramètre à un pot ou à la pédale ; le menu du bloc lui attribue un footswitch.';

  @override
  String get ctlDicaToque =>
      'Touchez un contrôle pour le modifier ou lui assigner un paramètre du bloc ouvert ; le menu du bloc lui attribue un footswitch.';

  @override
  String get ctlSiglaFoot => 'FOOT';

  @override
  String get ctlSiglaPot => 'POT';

  @override
  String get ctlSiglaExp => 'EXP';

  @override
  String get ctlLivre => 'libre';

  @override
  String get ctlLigaDesliga => 'On/off';

  @override
  String ctlAtribuirA(String controle) {
    return 'Assigner à $controle';
  }

  @override
  String get ctlJaAqui => 'déjà ici';

  @override
  String ctlFootswitchLigaBloco(int numero) {
    return 'Le footswitch $numero active/coupe ce bloc';
  }

  @override
  String get ctlNome => 'Nom sur l’écran';

  @override
  String ctlNomeLongo(int maximo) {
    return 'Les presets d’usine utilisent jusqu’à $maximo lettres ; un nom plus long peut être coupé à l’écran.';
  }

  @override
  String get ctlMinimo => 'MIN';

  @override
  String get ctlMaximo => 'MAX';

  @override
  String get ctlRemoverAlvo => 'Retirer ce paramètre';

  @override
  String get ctlRemoverControle => 'VIDER LE CONTRÔLE';

  @override
  String get ctlAtribuirDoBloco => 'ASSIGNER UN PARAMÈTRE';

  @override
  String ctlEscolherParametro(String bloco) {
    return 'Paramètre de $bloco';
  }

  @override
  String get ctlSemBlocoAberto =>
      'Ouvrez un bloc de la chaîne pour assigner un de ses paramètres.';

  @override
  String get ctlSemAlvos => 'Aucun paramètre sur ce contrôle.';

  @override
  String get ctlFaixaIguais =>
      'Un minimum égal au maximum laisse le contrôle sans course.';

  @override
  String get ctlFaixaFora => 'Hors de la plage du paramètre.';

  @override
  String ctlCasaVazia(int linha, int casa) {
    return 'case vide $linha·$casa';
  }

  @override
  String ctlAtribuidoA(String controle) {
    return 'Assigné à $controle';
  }

  @override
  String get ctlAcaoAtribuir => 'Assigner à un contrôle de la pédale';

  @override
  String get ctlFechar => 'FERMER';

  @override
  String get ctlDicaPedaleira =>
      'Sur la pédale, les pots assignés ne répondent que sur l’écran du preset à une ligne ; avec le preset déplié, les potards modifient le bloc sélectionné.';

  @override
  String get utTreino => 'Entraînement';

  @override
  String get utBater => 'Tap';

  @override
  String get utBaterSoNoFixo =>
      'Le tap tempo ne marche qu’en mode Fixed Tempo.';

  @override
  String slotAlteradoForaTitulo(String slot) {
    return '$slot modifié sur la pédale';
  }

  @override
  String slotAlteradoForaTexto(String slot) {
    return 'L’emplacement $slot a été modifié sur la pédale depuis que vous l’avez ouvert. Écraser enregistre votre version par-dessus ce qui s’y trouve ; recharger abandonne vos modifications et affiche la version de la pédale.';
  }

  @override
  String get sobrescreverMesmoAssim => 'ÉCRASER QUAND MÊME';

  @override
  String get recarregarDaPedaleira => 'RECHARGER DEPUIS LA PÉDALE';

  @override
  String get uiRecarregarDaPedaleira => 'Recharger depuis la pédale';

  @override
  String recarregarTitulo(String slot) {
    return 'Recharger $slot depuis la pédale ?';
  }

  @override
  String recarregarTexto(String nome) {
    return 'Les modifications non enregistrées de « $nome » sont perdues et l’éditeur affiche ce qui est enregistré dans l’emplacement.';
  }

  @override
  String get recarregar => 'RECHARGER';

  @override
  String get pausaUsbTitulo => 'Pause entre les paquets USB';

  @override
  String get pausaUsbTexto =>
      'Plus bas = changements en direct plus rapides ; augmentez-la si la pédale ne répond plus. Auto utilise la valeur par défaut de cet ordinateur.';

  @override
  String get versaoNovaConsultaTexto =>
      'Au lancement, l’app demande seulement à GitHub quelle est la dernière version publiée. La requête n’envoie que la version de l’app (dans l’en-tête User-Agent) ; comme pour toute connexion, GitHub voit votre adresse IP. Si l’option est désactivée, l’app ne se connecte pas à Internet.';

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
    return 'Footswitches en mode $modo';
  }

  @override
  String get fmDica =>
      'En mode Stomp, les footswitches suivent les contrôles de pédale de ce preset. Le mode vaut pour tous les presets.';

  @override
  String get fmErro =>
      'La pédale n’a pas confirmé le changement de mode. Le mode affiché est celui qu’elle a maintenant.';

  @override
  String get fmIndisponivel =>
      'Cette pédale n’indique pas le mode des footswitches.';

  @override
  String fmAvisoControles(String modo) {
    return 'Les FOOT assignés n’agissent qu’en mode Stomp ; la pédale est en $modo.';
  }

  @override
  String get fmDesconhecido =>
      'La pédale est dans un mode que cette app ne connaît pas. Changez le mode sur la pédale elle-même.';

  @override
  String get t3kTom => 'Son';

  @override
  String get t3kModelo => 'Modèle';

  @override
  String get t3kLendo => 'Lecture des sons de la pédale…';

  @override
  String get t3kFalhou => 'La pédale n’a pas envoyé la liste des sons.';

  @override
  String get t3kTentarDeNovo => 'Réessayer';

  @override
  String t3kNaoEncontrado(String arquivo) {
    return 'Introuvable sur la pédale : $arquivo';
  }

  @override
  String get t3kSoConsulta =>
      'Son que vous avez chargé : affiché seulement pour référence. L’app ne peut pas encore le changer.';

  @override
  String get t3kIrNaoConferido =>
      'Le chemin des IR d’usine n’a pas encore été vérifié sur une pédale : écoutez avant d’enregistrer.';

  @override
  String t3kResumo(int fabrica, int seus) {
    return 'Sur la pédale : $fabrica d’usine et $seus chargés par vous';
  }

  @override
  String t3kDetalheFabrica(String autor, String licenca) {
    return '$autor · licence $licenca';
  }

  @override
  String t3kDetalheSeu(String autor, String licenca) {
    return '$autor · licence $licenca · le vôtre, pour référence';
  }

  @override
  String get t3kSemAutor => 'sans auteur';

  @override
  String get uiDicas => 'Astuces';

  @override
  String ctlResumo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n assignés',
      one: '1 assigné',
      zero: 'aucun assigné',
    );
    return '$_temp0';
  }

  @override
  String get ctlMostrar => 'Afficher les contrôles de la pédale';

  @override
  String get ctlRecolher => 'Replier les contrôles de la pédale';

  @override
  String sbSubstitui(String nome) {
    return 'remplace $nome';
  }

  @override
  String get sbSubstituirAqui => 'Remplacer le preset de cet emplacement';

  @override
  String get salvarReleituraDiferente =>
      'la pédale a confirmé, mais l’emplacement relu diffère de ce qui a été envoyé. Votre modification est toujours à l’écran ; vérifiez l’emplacement et enregistrez de nouveau.';

  @override
  String get pdSemAcesso =>
      'Niveaux de sortie, Global EQ et gain d’entrée : l’app n’a pas accès à ces fonctions de la pédale. L’Anagram accepte une valeur envoyée, mais ne l’applique pas au son. Réglez-les avec les potards et les écrans de la pédale ; ici, vous voyez les valeurs actuelles (touchez Actualiser après les avoir changées).';

  @override
  String get utAcaoChave =>
      'Dans l’app, cet interrupteur est l’Action de la pédale. D’après le manuel du plugin : l’activer lance le rythme avec une intro ; pendant qu’il joue, un nouveau déclenchement joue un break ; un double déclenchement l’arrête ; un appui maintenu passe à la partie suivante. Ce que joue la batterie dans chaque cas dépend du plugin.';

  @override
  String get utSoNoVisor => 'Seulement sur l’écran de la pédale';

  @override
  String get caProcurando => 'Recherche de la pédale…';

  @override
  String get caConectarAoAbrir => 'Connecter au lancement';

  @override
  String get caConectarAoAbrirTexto =>
      'Au lancement, l’app cherche la pédale en USB une seule fois. Se connecter ne joue rien ; sans pédale, l’écran de connexion reste tel quel.';

  @override
  String get caConectarAoAbrirMac =>
      'Sur macOS, seulement après avoir autorisé Anagram App dans Réglages Système › Confidentialité et sécurité › Surveillance de l’entrée.';

  @override
  String salvarCopiaFalhou(String pasta) {
    return 'la sauvegarde du preset de l’emplacement n’a pas été écrite dans $pasta, donc rien n’est parti vers la pédale. La cause est dans le journal ; si le disque ne peut pas être réparé, désactivez la sauvegarde automatique dans Paramètres.';
  }

  @override
  String bkErroCopia(String pasta) {
    return 'La sauvegarde du preset de l’emplacement n’a pas été écrite dans $pasta, donc rien n’a changé sur la pédale. La cause est dans le journal ; si le disque ne peut pas être réparé, désactivez la sauvegarde automatique dans Paramètres.';
  }

  @override
  String get bkPastaDesconhecida =>
      'le dossier de données de l’app (le système n’a pas dit lequel)';

  @override
  String get bkSecao => 'Sauvegardes des presets';

  @override
  String get bkAutomatico => 'Sauvegarde automatique avant d’écrire';

  @override
  String get bkAutomaticoTexto =>
      'Avant de remplacer, déplacer ou vider un preset sur la pédale, l’app garde ce qu’il y avait dans l’emplacement dans un fichier JSON qu’Importer sait ouvrir. Si la sauvegarde échoue, rien n’est écrit. Les 30 derniers jours sont gardés, jusqu’à 500 fichiers.';

  @override
  String get bkOnde =>
      'Les sauvegardes sont gardées dans ce dossier, sur cet ordinateur seulement :';

  @override
  String get bkAbrirPasta => 'Ouvrir le dossier des sauvegardes';

  @override
  String get bkPastaNaoAbriu =>
      'Le système n’a pas ouvert le dossier. Le chemin est ci-dessus, à copier.';

  @override
  String get bkCompleto => 'Sauvegarder tous les presets maintenant';

  @override
  String get bkCompletoTexto =>
      'Lit chaque zone et chaque emplacement utilisé, un par un, et garde chaque preset dans un dossier daté. L’app n’efface jamais les sauvegardes complètes.';

  @override
  String get bkSemPedaleira =>
      'Connectez la pédale (ou ouvrez la démo) pour faire une sauvegarde complète et pour ouvrir une sauvegarde dans l’éditeur.';

  @override
  String get bkCompletoTitulo => 'Sauvegarde de tous les presets';

  @override
  String get bkCompletoListando =>
      'Lecture de la liste des presets de chaque zone…';

  @override
  String bkCompletoProgresso(int feitos, int total) {
    return '$feitos presets sur $total sauvegardés';
  }

  @override
  String bkCompletoConcluido(int quantos, String pasta) {
    return 'Sauvegarde complète : $quantos presets enregistrés dans $pasta.';
  }

  @override
  String bkCompletoCancelado(int feitos, int total) {
    return 'Sauvegarde annulée : $feitos presets sur $total sauvegardés. Ce qui a déjà été écrit reste dans le dossier.';
  }

  @override
  String bkCompletoFalhou(int feitos, String motivo) {
    return 'Sauvegarde arrêtée après $feitos presets : $motivo';
  }

  @override
  String get bkRestaurar => 'Restaurer une sauvegarde…';

  @override
  String get bkRestaurarTexto =>
      'Ouvre le preset sauvegardé dans l’éditeur, sans emplacement, pour l’écouter d’abord. Pour le mettre dans la pédale, utilisez Enregistrer sous.';

  @override
  String get bkNenhum => 'Aucune sauvegarde pour l’instant.';

  @override
  String get bkAbrirNoEditor => 'Ouvrir dans l’éditeur';

  @override
  String bkAbertoNoEditor(String nome) {
    return '« $nome » ouvert dans l’éditeur, sans emplacement. Utilisez Enregistrer sous pour l’écrire.';
  }

  @override
  String bkCompletoGrupo(String hora, int quantos) {
    return 'Sauvegarde complète · $hora · $quantos presets';
  }

  @override
  String get bkAreaUnica => 'Zone unique';

  @override
  String get bkFechar => 'FERMER';

  @override
  String get bkRestaurarTitulo => 'Restaurer une sauvegarde';

  @override
  String get caMonitoramentoNegado =>
      'macOS ne laisse pas encore Anagram App parler à la pédale. Dans Réglages Système › Confidentialité et sécurité › Surveillance de l’entrée, activez Anagram App.';

  @override
  String get caAbrirAjustes => 'OUVRIR LES RÉGLAGES SYSTÈME';

  @override
  String get caReabraDepois =>
      'Après l’avoir activé, quittez puis rouvrez Anagram App : macOS ne l’applique qu’à la prochaine ouverture de l’app.';

  @override
  String get mcpClienteVsCode => 'VS Code + Copilot';

  @override
  String get mcpVsCodeOnde =>
      'VS Code + GitHub Copilot : collez dans ~/.copilot/mcp-config.json (ou Chat: Open Customizations › MCP Servers › Copilot Global) et demandez dans un chat Copilot.';

  @override
  String get mcpCopilotComum =>
      'L’app Copilot de Windows et Microsoft 365 Copilot n’ont pas d’endroit pour ajouter un serveur MCP local : utilisez GitHub Copilot dans VS Code.';

  @override
  String get mcpDocVsCode => 'Documentation de VS Code';

  @override
  String get ceControlar => 'CONTRÔLER';

  @override
  String get ceTodas => 'TOUTES LES SCÈNES';

  @override
  String get ceAtiva => 'SCÈNE ACTIVE SEULEMENT';

  @override
  String get ceTodasDica =>
      'Potard, valeur et on/off changent toutes les scènes : la valeur ne varie plus entre elles.';

  @override
  String get ceAtivaDica =>
      'Potard, valeur et on/off ne changent que la scène active ; les autres restent comme elles étaient.';
}
