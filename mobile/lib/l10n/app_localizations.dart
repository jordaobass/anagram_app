import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @desconectar.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get desconectar;

  /// No description provided for @creditos.
  ///
  /// In pt, this message translates to:
  /// **'Créditos'**
  String get creditos;

  /// No description provided for @estadoSemConexao.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão'**
  String get estadoSemConexao;

  /// No description provided for @estadoConectando.
  ///
  /// In pt, this message translates to:
  /// **'Conectando ({meio})…'**
  String estadoConectando(String meio);

  /// No description provided for @estadoDemonstracao.
  ///
  /// In pt, this message translates to:
  /// **'Demonstração · sem pedaleira'**
  String get estadoDemonstracao;

  /// No description provided for @estadoConectada.
  ///
  /// In pt, this message translates to:
  /// **'Anagram · {meio} · {firmware}'**
  String estadoConectada(String meio, String firmware);

  /// No description provided for @estadoFalha.
  ///
  /// In pt, this message translates to:
  /// **'Falha na conexão'**
  String get estadoFalha;

  /// No description provided for @conexaoSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Conexão: {texto}'**
  String conexaoSemantica(String texto);

  /// No description provided for @idaEVolta.
  ///
  /// In pt, this message translates to:
  /// **'ida e volta {ms} ms'**
  String idaEVolta(int ms);

  /// No description provided for @aoVivo.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO'**
  String get aoVivo;

  /// No description provided for @aoVivoDesligado.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO DESLIGADO'**
  String get aoVivoDesligado;

  /// No description provided for @conexaoPermissaoNegada.
  ///
  /// In pt, this message translates to:
  /// **'O sistema negou a permissão de acesso ao USB da Anagram. No Android, toque em Conectar de novo e aceite o pedido; no macOS, confira os ajustes de Privacidade e Segurança.'**
  String get conexaoPermissaoNegada;

  /// No description provided for @conexaoOcupada.
  ///
  /// In pt, this message translates to:
  /// **'A Anagram está plugada, mas outro programa a segura. Feche o Darkglass Suite e qualquer aba do navegador conectada à pedaleira.'**
  String get conexaoOcupada;

  /// No description provided for @conexaoSemAnagram.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma Anagram encontrada no USB. Confira o cabo e se ela está ligada.'**
  String get conexaoSemAnagram;

  /// No description provided for @conexaoSemResposta.
  ///
  /// In pt, this message translates to:
  /// **'A Anagram não respondeu. Desligue e ligue o cabo e tente de novo.'**
  String get conexaoSemResposta;

  /// No description provided for @conexaoRespostaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Resposta inesperada da pedaleira.'**
  String get conexaoRespostaInvalida;

  /// No description provided for @erroOcupada.
  ///
  /// In pt, this message translates to:
  /// **'Outro programa está segurando a pedaleira.'**
  String get erroOcupada;

  /// No description provided for @erroDesconectado.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira está desconectada.'**
  String get erroDesconectado;

  /// No description provided for @erroSemResposta.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira não respondeu a tempo.'**
  String get erroSemResposta;

  /// No description provided for @erroRespostaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira recusou ou mandou uma resposta inesperada.'**
  String get erroRespostaInvalida;

  /// Recusa do próprio app (ex. "Espere a gravação em curso terminar."): já é uma frase para a pessoa, não detalhe do protocolo.
  ///
  /// In pt, this message translates to:
  /// **'{detalhe}'**
  String erroOperacaoEmCurso(String detalhe);

  /// No description provided for @erroSemSuporte.
  ///
  /// In pt, this message translates to:
  /// **'Esta plataforma não consegue falar com a pedaleira.'**
  String get erroSemSuporte;

  /// No description provided for @avisoDemonstracaoFalhou.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a demonstração.'**
  String get avisoDemonstracaoFalhou;

  /// No description provided for @avisoFalhaInesperada.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir {meio}. Tente de novo; o detalhe ficou no log.'**
  String avisoFalhaInesperada(String meio);

  /// No description provided for @avisoPedaleiraDesconectada.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira foi desconectada. Conecte de novo para continuar de onde parou.'**
  String get avisoPedaleiraDesconectada;

  /// No description provided for @avisoFormatoMaisNovo.
  ///
  /// In pt, this message translates to:
  /// **'Preset de formato mais novo que o deste app: campos desconhecidos são preservados.'**
  String get avisoFormatoMaisNovo;

  /// Slot alterado fora do app e reaberto depois de reler a lista
  ///
  /// In pt, this message translates to:
  /// **'O {slot} mudou fora do app; a lista foi relida e a versão atual foi aberta.'**
  String avisoPresetAtualizado(String slot);

  /// No description provided for @avisoPresetTrocado.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira devolveu outro preset para {slot} (id diferente da lista). A lista foi relida; abra de novo.'**
  String avisoPresetTrocado(String slot);

  /// No description provided for @avisoAreaNaoTrocou.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira não trocou de área.'**
  String get avisoAreaNaoTrocou;

  /// No description provided for @naoSalvou.
  ///
  /// In pt, this message translates to:
  /// **'Não salvou: {motivo}'**
  String naoSalvou(String motivo);

  /// No description provided for @salvarDesconectada.
  ///
  /// In pt, this message translates to:
  /// **'a pedaleira está desconectada. Conecte e tente de novo.'**
  String get salvarDesconectada;

  /// No description provided for @salvarSemResposta.
  ///
  /// In pt, this message translates to:
  /// **'a pedaleira não respondeu a tempo. O slot pode não ter sido gravado; confira antes de tentar de novo.'**
  String get salvarSemResposta;

  /// No description provided for @salvarRespostaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'a pedaleira recusou ou devolveu uma resposta inesperada.'**
  String get salvarRespostaInvalida;

  /// No description provided for @salvarOcupada.
  ///
  /// In pt, this message translates to:
  /// **'outro programa está segurando a pedaleira.'**
  String get salvarOcupada;

  /// No description provided for @indisponivelIos.
  ///
  /// In pt, this message translates to:
  /// **'iPhone e iPad não deixam apps comuns abrirem a interface USB de controle da Anagram: isso exige um driver DriverKit com permissão especial da Apple, que este app ainda não tem. Use o modo demonstração aqui, ou edite pelo Mac, PC, Android ou Chrome.'**
  String get indisponivelIos;

  /// No description provided for @indisponivelNavegador.
  ///
  /// In pt, this message translates to:
  /// **'Este navegador não tem WebHID. Use Chrome ou Edge no computador, ou o modo demonstração.'**
  String get indisponivelNavegador;

  /// No description provided for @indisponivelSemUsb.
  ///
  /// In pt, this message translates to:
  /// **'Esta plataforma não tem acesso USB à pedaleira.'**
  String get indisponivelSemUsb;

  /// No description provided for @importacaoIlegivel.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o arquivo.'**
  String get importacaoIlegivel;

  /// No description provided for @importacaoNaoEhPreset.
  ///
  /// In pt, this message translates to:
  /// **'Este arquivo não é um preset da Anagram.'**
  String get importacaoNaoEhPreset;

  /// No description provided for @exportacaoFalhou.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gravar o arquivo.'**
  String get exportacaoFalhou;

  /// No description provided for @nomeVazio.
  ///
  /// In pt, this message translates to:
  /// **'O nome não pode ficar vazio.'**
  String get nomeVazio;

  /// No description provided for @nomeComMarcador.
  ///
  /// In pt, this message translates to:
  /// **'O nome não pode conter \"{marcador}\".'**
  String nomeComMarcador(String marcador);

  /// No description provided for @familiaDrive.
  ///
  /// In pt, this message translates to:
  /// **'Drive'**
  String get familiaDrive;

  /// No description provided for @familiaDinamica.
  ///
  /// In pt, this message translates to:
  /// **'Dinâmica'**
  String get familiaDinamica;

  /// No description provided for @familiaEq.
  ///
  /// In pt, this message translates to:
  /// **'EQ'**
  String get familiaEq;

  /// No description provided for @familiaFiltro.
  ///
  /// In pt, this message translates to:
  /// **'Filtro'**
  String get familiaFiltro;

  /// No description provided for @familiaModulacao.
  ///
  /// In pt, this message translates to:
  /// **'Modulação'**
  String get familiaModulacao;

  /// No description provided for @familiaDelay.
  ///
  /// In pt, this message translates to:
  /// **'Delay'**
  String get familiaDelay;

  /// No description provided for @familiaReverb.
  ///
  /// In pt, this message translates to:
  /// **'Reverb'**
  String get familiaReverb;

  /// No description provided for @familiaAmp.
  ///
  /// In pt, this message translates to:
  /// **'Amp'**
  String get familiaAmp;

  /// No description provided for @familiaGabinete.
  ///
  /// In pt, this message translates to:
  /// **'Gabinete'**
  String get familiaGabinete;

  /// No description provided for @familiaUtilitario.
  ///
  /// In pt, this message translates to:
  /// **'Utilitário'**
  String get familiaUtilitario;

  /// No description provided for @areaSemNome.
  ///
  /// In pt, this message translates to:
  /// **'Área {numero}'**
  String areaSemNome(int numero);

  /// No description provided for @conecteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Conecte a Anagram pelo USB'**
  String get conecteTitulo;

  /// No description provided for @conecteFecheSuite.
  ///
  /// In pt, this message translates to:
  /// **'Feche o Darkglass Suite antes: só um programa por vez controla a pedaleira.'**
  String get conecteFecheSuite;

  /// No description provided for @abrirDemonstracao.
  ///
  /// In pt, this message translates to:
  /// **'ABRIR DEMONSTRAÇÃO'**
  String get abrirDemonstracao;

  /// No description provided for @conectarPeloUsb.
  ///
  /// In pt, this message translates to:
  /// **'CONECTAR PELO USB'**
  String get conectarPeloUsb;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'CANCELAR'**
  String get cancelar;

  /// Versão do app na barra de cima, ao lado do firmware
  ///
  /// In pt, this message translates to:
  /// **'App v{versao}'**
  String versaoAppNaBarra(String versao);

  /// No description provided for @versaoApp.
  ///
  /// In pt, this message translates to:
  /// **'v{versao}'**
  String versaoApp(String versao);

  /// No description provided for @versaoAppComArte.
  ///
  /// In pt, this message translates to:
  /// **'v{versao} · arte da pedaleira'**
  String versaoAppComArte(String versao);

  /// No description provided for @fecharAviso.
  ///
  /// In pt, this message translates to:
  /// **'Fechar aviso'**
  String get fecharAviso;

  /// No description provided for @largarEdicoesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Descartar edições?'**
  String get largarEdicoesTitulo;

  /// No description provided for @largarEdicoesTexto.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" tem mudanças que não foram salvas no slot.'**
  String largarEdicoesTexto(String nome);

  /// No description provided for @continuarEditando.
  ///
  /// In pt, this message translates to:
  /// **'CONTINUAR EDITANDO'**
  String get continuarEditando;

  /// No description provided for @largar.
  ///
  /// In pt, this message translates to:
  /// **'DESCARTAR'**
  String get largar;

  /// No description provided for @origem.
  ///
  /// In pt, this message translates to:
  /// **'ORIGEM'**
  String get origem;

  /// No description provided for @gravarAqui.
  ///
  /// In pt, this message translates to:
  /// **'Gravar aqui'**
  String get gravarAqui;

  /// No description provided for @pedaleiraNesteSlot.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira está neste slot'**
  String get pedaleiraNesteSlot;

  /// No description provided for @slotVazio.
  ///
  /// In pt, this message translates to:
  /// **'vazio'**
  String get slotVazio;

  /// No description provided for @area.
  ///
  /// In pt, this message translates to:
  /// **'ÁREA'**
  String get area;

  /// No description provided for @largarAoTrocarArea.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" tem mudanças que não foram salvas e será fechado ao trocar de área.'**
  String largarAoTrocarArea(String nome);

  /// No description provided for @areaInativa.
  ///
  /// In pt, this message translates to:
  /// **'Esta área não está ativa na pedaleira: abrir um preset só toca, sem trocar o slot nela.'**
  String get areaInativa;

  /// No description provided for @tornarAtiva.
  ///
  /// In pt, this message translates to:
  /// **'TORNAR ATIVA'**
  String get tornarAtiva;

  /// No description provided for @salvar.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get salvar;

  /// No description provided for @salvarComo.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR COMO…'**
  String get salvarComo;

  /// No description provided for @descartar.
  ///
  /// In pt, this message translates to:
  /// **'DESCARTAR'**
  String get descartar;

  /// No description provided for @menuArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Importar ou exportar JSON'**
  String get menuArquivo;

  /// No description provided for @importarPreset.
  ///
  /// In pt, this message translates to:
  /// **'Importar preset (.json)'**
  String get importarPreset;

  /// No description provided for @exportarPreset.
  ///
  /// In pt, this message translates to:
  /// **'Exportar preset (.json)'**
  String get exportarPreset;

  /// No description provided for @presetImportado.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" importado. Salve no slot para gravar.'**
  String presetImportado(String nome);

  /// No description provided for @presetExportado.
  ///
  /// In pt, this message translates to:
  /// **'Preset exportado.'**
  String get presetExportado;

  /// No description provided for @presetCopiado.
  ///
  /// In pt, this message translates to:
  /// **'JSON do preset copiado para a área de transferência.'**
  String get presetCopiado;

  /// No description provided for @presetSalvoEm.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" salvo em {slot}.'**
  String presetSalvoEm(String nome, String slot);

  /// No description provided for @substituirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Substituir {slot}?'**
  String substituirTitulo(String slot);

  /// No description provided for @substituirTexto.
  ///
  /// In pt, this message translates to:
  /// **'O slot {slot} guarda \"{nome}\". Ele será substituído pelo preset editado.'**
  String substituirTexto(String slot, String nome);

  /// No description provided for @substituir.
  ///
  /// In pt, this message translates to:
  /// **'SUBSTITUIR'**
  String get substituir;

  /// No description provided for @salvarComoEscolhaDestino.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR COMO: TOQUE NO SLOT DE DESTINO'**
  String get salvarComoEscolhaDestino;

  /// No description provided for @slotSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Slot {slot}'**
  String slotSemantica(String slot);

  /// No description provided for @slotNovo.
  ///
  /// In pt, this message translates to:
  /// **'novo'**
  String get slotNovo;

  /// No description provided for @abrirListaSemantica.
  ///
  /// In pt, this message translates to:
  /// **', abrir lista de presets'**
  String get abrirListaSemantica;

  /// No description provided for @renomearPresetSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Renomear preset {nome}'**
  String renomearPresetSemantica(String nome);

  /// No description provided for @avisoAoVivoDesligado.
  ///
  /// In pt, this message translates to:
  /// **'AO VIVO DESLIGADO — as edições ficam só no app, a pedaleira não muda.'**
  String get avisoAoVivoDesligado;

  /// No description provided for @avisoAudicao.
  ///
  /// In pt, this message translates to:
  /// **'AUDIÇÃO — a pedaleira continua no slot dela (sem USB MIDI).'**
  String get avisoAudicao;

  /// No description provided for @naoSalvo.
  ///
  /// In pt, this message translates to:
  /// **'NÃO SALVO'**
  String get naoSalvo;

  /// No description provided for @escolhaUmPreset.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um preset'**
  String get escolhaUmPreset;

  /// No description provided for @slotEstaVazio.
  ///
  /// In pt, this message translates to:
  /// **'O slot {slot} está vazio'**
  String slotEstaVazio(String slot);

  /// No description provided for @escolhaUmPresetTexto.
  ///
  /// In pt, this message translates to:
  /// **'Ao abrir, ele passa a tocar na pedaleira. As mudanças soam na hora e só ficam gravadas quando você salva.'**
  String get escolhaUmPresetTexto;

  /// No description provided for @slotVazioTexto.
  ///
  /// In pt, this message translates to:
  /// **'Crie um preset aqui. Para trazer blocos de outro preset, use o ícone de copiar no painel do bloco e depois segure uma casa vazia para colar.'**
  String get slotVazioTexto;

  /// No description provided for @criarPresetAqui.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR PRESET AQUI'**
  String get criarPresetAqui;

  /// No description provided for @verPresets.
  ///
  /// In pt, this message translates to:
  /// **'VER PRESETS'**
  String get verPresets;

  /// No description provided for @nomeDoPreset.
  ///
  /// In pt, this message translates to:
  /// **'Nome do preset'**
  String get nomeDoPreset;

  /// No description provided for @nome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nome;

  /// No description provided for @renomear.
  ///
  /// In pt, this message translates to:
  /// **'RENOMEAR'**
  String get renomear;

  /// No description provided for @blocoPosicao.
  ///
  /// In pt, this message translates to:
  /// **'{familia} · linha {linha}, casa {casa}'**
  String blocoPosicao(String familia, int linha, int casa);

  /// No description provided for @arrasteComMouse.
  ///
  /// In pt, this message translates to:
  /// **'Arraste na grade para mudar de lugar'**
  String get arrasteComMouse;

  /// No description provided for @arrasteNoToque.
  ///
  /// In pt, this message translates to:
  /// **'Segure e arraste na grade para mudar de lugar'**
  String get arrasteNoToque;

  /// No description provided for @ligadoSoNaCena.
  ///
  /// In pt, this message translates to:
  /// **'LIGADO SÓ NA CENA {cena}'**
  String ligadoSoNaCena(int cena);

  /// No description provided for @desligadoSoNaCena.
  ///
  /// In pt, this message translates to:
  /// **'DESLIGADO SÓ NA CENA {cena}'**
  String desligadoSoNaCena(int cena);

  /// No description provided for @copiarBloco.
  ///
  /// In pt, this message translates to:
  /// **'Copiar bloco'**
  String get copiarBloco;

  /// No description provided for @maisAcoesBloco.
  ///
  /// In pt, this message translates to:
  /// **'Mais ações do bloco'**
  String get maisAcoesBloco;

  /// No description provided for @blocoLigadoSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Bloco ligado'**
  String get blocoLigadoSemantica;

  /// No description provided for @ligado.
  ///
  /// In pt, this message translates to:
  /// **'LIGADO'**
  String get ligado;

  /// No description provided for @desligado.
  ///
  /// In pt, this message translates to:
  /// **'DESLIGADO'**
  String get desligado;

  /// No description provided for @adicionarEfeitoMenu.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar efeito…'**
  String get adicionarEfeitoMenu;

  /// No description provided for @colarAqui.
  ///
  /// In pt, this message translates to:
  /// **'Colar aqui'**
  String get colarAqui;

  /// No description provided for @ligarDesligar.
  ///
  /// In pt, this message translates to:
  /// **'Ligar / desligar'**
  String get ligarDesligar;

  /// No description provided for @moverEsquerda.
  ///
  /// In pt, this message translates to:
  /// **'Mover para a esquerda'**
  String get moverEsquerda;

  /// No description provided for @moverDireita.
  ///
  /// In pt, this message translates to:
  /// **'Mover para a direita'**
  String get moverDireita;

  /// No description provided for @moverParaLinha.
  ///
  /// In pt, this message translates to:
  /// **'Mover para a linha {linha}'**
  String moverParaLinha(int linha);

  /// No description provided for @removerBloco.
  ///
  /// In pt, this message translates to:
  /// **'Remover bloco'**
  String get removerBloco;

  /// No description provided for @semParametros.
  ///
  /// In pt, this message translates to:
  /// **'Este bloco não tem parâmetros ajustáveis.'**
  String get semParametros;

  /// No description provided for @soNaCena.
  ///
  /// In pt, this message translates to:
  /// **'SÓ NA CENA {cena}'**
  String soNaCena(int cena);

  /// No description provided for @dicaMontarCadeia.
  ///
  /// In pt, this message translates to:
  /// **'Toque num + da grade para adicionar um efeito. Toque num bloco para ajustar; segure e arraste para mudar de lugar.'**
  String get dicaMontarCadeia;

  /// No description provided for @faixaEstimada.
  ///
  /// In pt, this message translates to:
  /// **'{simbolo} (faixa estimada)'**
  String faixaEstimada(String simbolo);

  /// No description provided for @adicionarEfeito.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar efeito'**
  String get adicionarEfeito;

  /// No description provided for @linhaCasa.
  ///
  /// In pt, this message translates to:
  /// **'Linha {linha}, casa {casa}'**
  String linhaCasa(int linha, int casa);

  /// No description provided for @buscarPeloNome.
  ///
  /// In pt, this message translates to:
  /// **'Buscar pelo nome'**
  String get buscarPeloNome;

  /// No description provided for @todos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get todos;

  /// No description provided for @nenhumEfeito.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum efeito com \"{busca}\".'**
  String nenhumEfeito(String busca);

  /// No description provided for @nenhumEfeitoNaFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum efeito com \"{busca}\" em {familia}.'**
  String nenhumEfeitoNaFamilia(String busca, String familia);

  /// No description provided for @sobreTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sobre e diagnóstico'**
  String get sobreTitulo;

  /// No description provided for @creditoAutorTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Autor'**
  String get creditoAutorTitulo;

  /// No description provided for @creditoAutor.
  ///
  /// In pt, this message translates to:
  /// **'jordao_bass · software livre, licença MIT. Gratuito, sem anúncios, sem compras no app e sem coleta de dados.'**
  String get creditoAutor;

  /// No description provided for @creditoProtocoloTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Protocolo USB e catálogo de blocos'**
  String get creditoProtocoloTitulo;

  /// No description provided for @creditoProtocolo.
  ///
  /// In pt, this message translates to:
  /// **'Portado do projeto anagram-tone-maker, de basster6 — licença MIT (github.com/basster6/anagram-tone-maker).'**
  String get creditoProtocolo;

  /// No description provided for @creditoArteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Arte dos blocos'**
  String get creditoArteTitulo;

  /// No description provided for @creditoArtePropria.
  ///
  /// In pt, this message translates to:
  /// **'Arte própria do app, por categoria de bloco.'**
  String get creditoArtePropria;

  /// No description provided for @creditoImagensTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Imagens dos blocos'**
  String get creditoImagensTitulo;

  /// No description provided for @creditoImagens.
  ///
  /// In pt, this message translates to:
  /// **'{credito}. Blocos sem imagem usam arte própria, por categoria.'**
  String creditoImagens(String credito);

  /// No description provided for @creditoFontesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Fontes'**
  String get creditoFontesTitulo;

  /// No description provided for @creditoFontes.
  ///
  /// In pt, this message translates to:
  /// **'Barlow e Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).'**
  String get creditoFontes;

  /// No description provided for @creditoAvisoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Aviso'**
  String get creditoAvisoTitulo;

  /// No description provided for @creditoAviso.
  ///
  /// In pt, this message translates to:
  /// **'App não oficial, sem vínculo com a Darkglass Electronics. Anagram é marca do fabricante.'**
  String get creditoAviso;

  /// No description provided for @diagnosticoPausa.
  ///
  /// In pt, this message translates to:
  /// **'DIAGNÓSTICO · PAUSA ENTRE RELATÓRIOS USB'**
  String get diagnosticoPausa;

  /// No description provided for @diagnosticoPausaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Compare 0, 2 e 10 ms e veja a \"ida e volta\" na barra e no log.'**
  String get diagnosticoPausaTexto;

  /// No description provided for @idioma.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @idiomaDoSistema.
  ///
  /// In pt, this message translates to:
  /// **'Do sistema'**
  String get idiomaDoSistema;

  /// No description provided for @separadorDecimal.
  ///
  /// In pt, this message translates to:
  /// **','**
  String get separadorDecimal;

  /// No description provided for @valorLigado.
  ///
  /// In pt, this message translates to:
  /// **'Ligado'**
  String get valorLigado;

  /// No description provided for @valorDesligado.
  ///
  /// In pt, this message translates to:
  /// **'Desligado'**
  String get valorDesligado;

  /// No description provided for @voltarAoPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao padrão'**
  String get voltarAoPadrao;

  /// No description provided for @voltouAoPadrao.
  ///
  /// In pt, this message translates to:
  /// **'{parametro} voltou ao padrão.'**
  String voltouAoPadrao(String parametro);

  /// No description provided for @desfazer.
  ///
  /// In pt, this message translates to:
  /// **'DESFAZER'**
  String get desfazer;

  /// No description provided for @pausaAuto.
  ///
  /// In pt, this message translates to:
  /// **'Auto'**
  String get pausaAuto;

  /// No description provided for @linha1.
  ///
  /// In pt, this message translates to:
  /// **'LINHA 1'**
  String get linha1;

  /// No description provided for @linha2Paralela.
  ///
  /// In pt, this message translates to:
  /// **'LINHA 2 · PARALELA'**
  String get linha2Paralela;

  /// No description provided for @cenaSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Cena {numero}, {nome}'**
  String cenaSemantica(int numero, String nome);

  /// No description provided for @cenaPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Cena {numero}'**
  String cenaPadrao(int numero);

  /// No description provided for @adicionarEfeitoNaCasa.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar efeito na casa {casa}, linha {linha}'**
  String adicionarEfeitoNaCasa(int casa, int linha);

  /// No description provided for @blocoLigado.
  ///
  /// In pt, this message translates to:
  /// **'{nome}, ligado'**
  String blocoLigado(String nome);

  /// No description provided for @blocoDesligado.
  ///
  /// In pt, this message translates to:
  /// **'{nome}, desligado'**
  String blocoDesligado(String nome);

  /// No description provided for @presets.
  ///
  /// In pt, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @txDicaMontarCadeiaMouse.
  ///
  /// In pt, this message translates to:
  /// **'Clique num + da grade para adicionar um efeito. Clique num bloco para ajustar e arraste para mudar de lugar.'**
  String get txDicaMontarCadeiaMouse;

  /// No description provided for @txSlotVazioMouse.
  ///
  /// In pt, this message translates to:
  /// **'Crie um preset aqui. Para trazer blocos de outro preset, use o ícone de copiar no painel do bloco e depois clique com o botão direito numa casa vazia para colar.'**
  String get txSlotVazioMouse;

  /// No description provided for @txModoDemonstracaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Modo demonstração'**
  String get txModoDemonstracaoTitulo;

  /// No description provided for @txSemUsbAquiCurto.
  ///
  /// In pt, this message translates to:
  /// **'Aqui o app não alcança a pedaleira pelo USB. Explore tudo no modo demonstração.'**
  String get txSemUsbAquiCurto;

  /// No description provided for @txPorQue.
  ///
  /// In pt, this message translates to:
  /// **'POR QUÊ?'**
  String get txPorQue;

  /// No description provided for @txEntendi.
  ///
  /// In pt, this message translates to:
  /// **'ENTENDI'**
  String get txEntendi;

  /// No description provided for @txAtiva.
  ///
  /// In pt, this message translates to:
  /// **'ATIVA'**
  String get txAtiva;

  /// No description provided for @txAtivaNaPedaleiraDica.
  ///
  /// In pt, this message translates to:
  /// **'Área ativa na pedaleira'**
  String get txAtivaNaPedaleiraDica;

  /// No description provided for @txEstadoAbrindoDemonstracao.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo a demonstração…'**
  String get txEstadoAbrindoDemonstracao;

  /// Nome do preset criado num slot vazio; vai gravado na pedaleira.
  ///
  /// In pt, this message translates to:
  /// **'Novo preset'**
  String get cdNovoPreset;

  /// No description provided for @uiPresets.
  ///
  /// In pt, this message translates to:
  /// **'PRESETS'**
  String get uiPresets;

  /// No description provided for @uiMaisAcoesPreset.
  ///
  /// In pt, this message translates to:
  /// **'Mais ações do preset'**
  String get uiMaisAcoesPreset;

  /// No description provided for @uiMenuArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Importar ou exportar o preset'**
  String get uiMenuArquivo;

  /// No description provided for @uiDescartarEdicoes.
  ///
  /// In pt, this message translates to:
  /// **'Descartar edições'**
  String get uiDescartarEdicoes;

  /// No description provided for @uiFecharBiblioteca.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get uiFecharBiblioteca;

  /// No description provided for @uiCena.
  ///
  /// In pt, this message translates to:
  /// **'CENA'**
  String get uiCena;

  /// No description provided for @uiSeloDesligado.
  ///
  /// In pt, this message translates to:
  /// **'OFF'**
  String get uiSeloDesligado;

  /// No description provided for @uiRenomear.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get uiRenomear;

  /// No description provided for @uiDicaDuploClique.
  ///
  /// In pt, this message translates to:
  /// **'Duplo clique no pedal liga e desliga'**
  String get uiDicaDuploClique;

  /// No description provided for @uiDicaToqueDuplo.
  ///
  /// In pt, this message translates to:
  /// **'Toque duplo no pedal liga e desliga'**
  String get uiDicaToqueDuplo;

  /// Sufixo do nome de um bloco que tem versão estéreo com o mesmo nome
  ///
  /// In pt, this message translates to:
  /// **'Mono'**
  String get cdBlocoMono;

  /// Sufixo do nome de um bloco que tem versão mono com o mesmo nome
  ///
  /// In pt, this message translates to:
  /// **'Estéreo'**
  String get cdBlocoEstereo;

  /// Canal mono abreviado na casa da cadeia
  ///
  /// In pt, this message translates to:
  /// **'M'**
  String get cdBlocoMonoCurto;

  /// Canal estéreo abreviado na casa da cadeia
  ///
  /// In pt, this message translates to:
  /// **'ST'**
  String get cdBlocoEstereoCurto;

  /// No description provided for @kbDigitarDica.
  ///
  /// In pt, this message translates to:
  /// **'Clique no número para digitar o valor'**
  String get kbDigitarDica;

  /// Faixa do parâmetro no diálogo de digitar o valor
  ///
  /// In pt, this message translates to:
  /// **'De {minimo} a {maximo}'**
  String kbFaixa(String minimo, String maximo);

  /// No description provided for @kbNaoEhNumero.
  ///
  /// In pt, this message translates to:
  /// **'Digite um número, como -12,5 ou 1,5k.'**
  String get kbNaoEhNumero;

  /// No description provided for @kbAplicar.
  ///
  /// In pt, this message translates to:
  /// **'APLICAR'**
  String get kbAplicar;

  /// No description provided for @lpRemoverTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Remover o Split?'**
  String get lpRemoverTitulo;

  /// Confirmação ao remover o Split com blocos na linha 2
  ///
  /// In pt, this message translates to:
  /// **'Sem o Split a linha 2 não recebe sinal: saem também o Merge e os {quantidade} blocos da linha 2.'**
  String lpRemoverTexto(int quantidade);

  /// No description provided for @lpRemoverConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'REMOVER'**
  String get lpRemoverConfirmar;

  /// No description provided for @cbGabinete.
  ///
  /// In pt, this message translates to:
  /// **'Gabinete'**
  String get cbGabinete;

  /// No description provided for @cbMicrofone.
  ///
  /// In pt, this message translates to:
  /// **'Microfone'**
  String get cbMicrofone;

  /// No description provided for @cbPosicao.
  ///
  /// In pt, this message translates to:
  /// **'Posição'**
  String get cbPosicao;

  /// No description provided for @cbEscolher.
  ///
  /// In pt, this message translates to:
  /// **'Escolher'**
  String get cbEscolher;

  /// IR de gabinete que não está na tabela da Darkglass (do usuário)
  ///
  /// In pt, this message translates to:
  /// **'IR próprio: {arquivo}'**
  String cbIrDoUsuario(String arquivo);

  /// No description provided for @opMoverPara.
  ///
  /// In pt, this message translates to:
  /// **'Mover para…'**
  String get opMoverPara;

  /// No description provided for @opClonarPara.
  ///
  /// In pt, this message translates to:
  /// **'Clonar para…'**
  String get opClonarPara;

  /// No description provided for @opTrocarBanco.
  ///
  /// In pt, this message translates to:
  /// **'Trocar de banco com…'**
  String get opTrocarBanco;

  /// No description provided for @opAcoesPreset.
  ///
  /// In pt, this message translates to:
  /// **'Mover, clonar ou trocar de banco'**
  String get opAcoesPreset;

  /// No description provided for @opDestinoMover.
  ///
  /// In pt, this message translates to:
  /// **'Mover {origem}: toque no slot de destino'**
  String opDestinoMover(String origem);

  /// No description provided for @opDestinoClonar.
  ///
  /// In pt, this message translates to:
  /// **'Clonar {origem}: toque no slot de destino'**
  String opDestinoClonar(String origem);

  /// No description provided for @opDestinoBanco.
  ///
  /// In pt, this message translates to:
  /// **'Trocar o banco {banco}: toque num slot do outro banco'**
  String opDestinoBanco(String banco);

  /// No description provided for @opTrocarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Trocar os dois de lugar?'**
  String get opTrocarTitulo;

  /// No description provided for @opTrocarTexto.
  ///
  /// In pt, this message translates to:
  /// **'{destino} tem \"{nome}\". Ele vai para {origem}.'**
  String opTrocarTexto(String destino, String nome, String origem);

  /// No description provided for @opTrocar.
  ///
  /// In pt, this message translates to:
  /// **'TROCAR'**
  String get opTrocar;

  /// No description provided for @opSubstituirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Substituir {destino}?'**
  String opSubstituirTitulo(String destino);

  /// No description provided for @opSubstituirTexto.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" vai ser apagado e trocado pela cópia de {origem}.'**
  String opSubstituirTexto(String nome, String origem);

  /// No description provided for @opSubstituir.
  ///
  /// In pt, this message translates to:
  /// **'SUBSTITUIR'**
  String get opSubstituir;

  /// No description provided for @opBancosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Trocar os bancos {a} e {b}?'**
  String opBancosTitulo(String a, String b);

  /// No description provided for @opBancosTexto.
  ///
  /// In pt, this message translates to:
  /// **'Os três presets de cada banco trocam de lugar.'**
  String get opBancosTexto;

  /// No description provided for @opMovido.
  ///
  /// In pt, this message translates to:
  /// **'{origem} foi para {destino}.'**
  String opMovido(String origem, String destino);

  /// No description provided for @opClonado.
  ///
  /// In pt, this message translates to:
  /// **'Cópia de {origem} gravada em {destino}.'**
  String opClonado(String origem, String destino);

  /// No description provided for @opBancosTrocados.
  ///
  /// In pt, this message translates to:
  /// **'Bancos {a} e {b} trocados.'**
  String opBancosTrocados(String a, String b);

  /// Nome da área dos presets de fábrica no seletor de área
  ///
  /// In pt, this message translates to:
  /// **'Fábrica'**
  String get fbAreaFabrica;

  /// Selo ao lado da área Fábrica: dali nada é gravado
  ///
  /// In pt, this message translates to:
  /// **'SÓ LEITURA'**
  String get fbSoLeitura;

  /// Explicação sob o seletor quando a área Fábrica está na tela
  ///
  /// In pt, this message translates to:
  /// **'Presets de fábrica da Darkglass: abrir um só faz tocar. Para guardar, copie para uma área sua.'**
  String get fbAreaSoLeitura;

  /// Aviso na faixa do preset aberto quando ele é de fábrica
  ///
  /// In pt, this message translates to:
  /// **'PRESET DE FÁBRICA — só toca. Copie para uma área sua para guardar.'**
  String get fbAvisoPresetDeFabrica;

  /// Botão que substitui SALVAR quando a fábrica está na tela
  ///
  /// In pt, this message translates to:
  /// **'COPIAR PARA A MINHA ÁREA…'**
  String get fbCopiarParaMinhaArea;

  /// Título do diálogo que pergunta a área de destino da cópia
  ///
  /// In pt, this message translates to:
  /// **'Copiar para qual área?'**
  String get fbCopiarTitulo;

  /// Item do menu de um preset da fábrica
  ///
  /// In pt, this message translates to:
  /// **'Copiar para a minha área…'**
  String get fbCopiarPara;

  /// Título do grupo com o ganho geral do equalizador paramétrico
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get eqBandaGeral;

  /// No description provided for @eqPassaAltas.
  ///
  /// In pt, this message translates to:
  /// **'Passa-altas'**
  String get eqPassaAltas;

  /// No description provided for @eqPassaBaixas.
  ///
  /// In pt, this message translates to:
  /// **'Passa-baixas'**
  String get eqPassaBaixas;

  /// No description provided for @eqShelfGraves.
  ///
  /// In pt, this message translates to:
  /// **'Shelf de graves'**
  String get eqShelfGraves;

  /// Título de uma banda do equalizador paramétrico
  ///
  /// In pt, this message translates to:
  /// **'Banda {numero}'**
  String eqBanda(int numero);

  /// No description provided for @eqShelfAgudos.
  ///
  /// In pt, this message translates to:
  /// **'Shelf de agudos'**
  String get eqShelfAgudos;

  /// Banda de graves do multibanda (Ignissor, Entropia)
  ///
  /// In pt, this message translates to:
  /// **'Graves'**
  String get mbGraves;

  /// No description provided for @mbMedios.
  ///
  /// In pt, this message translates to:
  /// **'Médios'**
  String get mbMedios;

  /// No description provided for @mbAgudos.
  ///
  /// In pt, this message translates to:
  /// **'Agudos'**
  String get mbAgudos;

  /// Borda de baixo da faixa de áudio, que nenhum corte move
  ///
  /// In pt, this message translates to:
  /// **'20 Hz'**
  String get mbBordaGraves;

  /// No description provided for @mbBordaAgudos.
  ///
  /// In pt, this message translates to:
  /// **'20 kHz'**
  String get mbBordaAgudos;

  /// Botão que silencia uma banda do multibanda
  ///
  /// In pt, this message translates to:
  /// **'Mudo'**
  String get mbMudo;

  /// No description provided for @mbCompLigada.
  ///
  /// In pt, this message translates to:
  /// **'Comp ligado'**
  String get mbCompLigada;

  /// No description provided for @mbCompDesligada.
  ///
  /// In pt, this message translates to:
  /// **'Comp desligado'**
  String get mbCompDesligada;

  /// No description provided for @mbSaida.
  ///
  /// In pt, this message translates to:
  /// **'Saída'**
  String get mbSaida;

  /// No description provided for @mbOutros.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get mbOutros;

  /// Explica os níveis de saída do Ignissor
  ///
  /// In pt, this message translates to:
  /// **'Comp Level é o volume das três bandas comprimidas. Clean Level mistura em paralelo o sinal seco, sem compressão: no mínimo (−24 dB) quase só se ouve o comprimido; subindo, volta o ataque natural da corda.'**
  String get mbExplicaMisturaLimpa;

  /// Dica do campo de busca na lista de opções longas (tipos de drive)
  ///
  /// In pt, this message translates to:
  /// **'Buscar (ex.: turbo grunt)'**
  String get mbBuscarOpcao;

  /// No description provided for @smOrdemInvalida.
  ///
  /// In pt, this message translates to:
  /// **'O Split precisa ficar antes do Merge na linha 1.'**
  String get smOrdemInvalida;

  /// No description provided for @smSoNaLinha1.
  ///
  /// In pt, this message translates to:
  /// **'Split e Merge ficam na linha 1.'**
  String get smSoNaLinha1;

  /// No description provided for @gvAnterior.
  ///
  /// In pt, this message translates to:
  /// **'{rotulo}: opção anterior'**
  String gvAnterior(String rotulo);

  /// No description provided for @gvProximo.
  ///
  /// In pt, this message translates to:
  /// **'{rotulo}: próxima opção'**
  String gvProximo(String rotulo);

  /// No description provided for @gvAbrirLista.
  ///
  /// In pt, this message translates to:
  /// **'{rotulo}: {nome}. Toque para ver todos'**
  String gvAbrirLista(String rotulo, String nome);

  /// No description provided for @gvBuscar.
  ///
  /// In pt, this message translates to:
  /// **'Escreva para buscar'**
  String get gvBuscar;

  /// No description provided for @gvNadaEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Nada encontrado'**
  String get gvNadaEncontrado;

  /// No description provided for @gxModeloAnterior.
  ///
  /// In pt, this message translates to:
  /// **'Gabinete anterior'**
  String get gxModeloAnterior;

  /// No description provided for @gxProximoModelo.
  ///
  /// In pt, this message translates to:
  /// **'Próximo gabinete'**
  String get gxProximoModelo;

  /// Dica do campo de busca do modelo de gabinete
  ///
  /// In pt, this message translates to:
  /// **'Escreva para buscar'**
  String get gxBuscarGabinete;

  /// No description provided for @mcpConfiguracoes.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get mcpConfiguracoes;

  /// No description provided for @mcpSecao.
  ///
  /// In pt, this message translates to:
  /// **'IA local (MCP)'**
  String get mcpSecao;

  /// No description provided for @mcpPermitir.
  ///
  /// In pt, this message translates to:
  /// **'Permitir IA via MCP'**
  String get mcpPermitir;

  /// No description provided for @mcpPermitirTexto.
  ///
  /// In pt, this message translates to:
  /// **'Um assistente de IA no seu computador (LM Studio, Claude Desktop…) pode ler o preset aberto e ajustar o timbre. As mudanças soam na hora e só vão para a pedaleira se você salvar.'**
  String get mcpPermitirTexto;

  /// No description provided for @mcpEstadoDesligado.
  ///
  /// In pt, this message translates to:
  /// **'Desligado: nenhum programa consegue falar com o app.'**
  String get mcpEstadoDesligado;

  /// No description provided for @mcpEstadoIniciando.
  ///
  /// In pt, this message translates to:
  /// **'Iniciando…'**
  String get mcpEstadoIniciando;

  /// No description provided for @mcpEstadoEscutando.
  ///
  /// In pt, this message translates to:
  /// **'Escutando em {endereco}'**
  String mcpEstadoEscutando(String endereco);

  /// No description provided for @mcpEstadoPortaOcupada.
  ///
  /// In pt, this message translates to:
  /// **'A porta {porta} já está em uso por outro programa (ou outra janela do app). Escolha outra porta.'**
  String mcpEstadoPortaOcupada(int porta);

  /// No description provided for @mcpPorta.
  ///
  /// In pt, this message translates to:
  /// **'Porta'**
  String get mcpPorta;

  /// No description provided for @mcpPortaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Use um número de 1024 a 65535.'**
  String get mcpPortaInvalida;

  /// No description provided for @mcpAplicarPorta.
  ///
  /// In pt, this message translates to:
  /// **'APLICAR'**
  String get mcpAplicarPorta;

  /// No description provided for @mcpToken.
  ///
  /// In pt, this message translates to:
  /// **'Token de acesso'**
  String get mcpToken;

  /// No description provided for @mcpTokenTexto.
  ///
  /// In pt, this message translates to:
  /// **'O cliente de IA manda este token em cada pedido. Sem ele, o app não obedece.'**
  String get mcpTokenTexto;

  /// No description provided for @mcpMostrarToken.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar token'**
  String get mcpMostrarToken;

  /// No description provided for @mcpOcultarToken.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar token'**
  String get mcpOcultarToken;

  /// No description provided for @mcpCopiarToken.
  ///
  /// In pt, this message translates to:
  /// **'Copiar token'**
  String get mcpCopiarToken;

  /// No description provided for @mcpGerarNovoToken.
  ///
  /// In pt, this message translates to:
  /// **'GERAR NOVO'**
  String get mcpGerarNovoToken;

  /// No description provided for @mcpGerarNovoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Gerar um token novo?'**
  String get mcpGerarNovoTitulo;

  /// No description provided for @mcpGerarNovoTexto.
  ///
  /// In pt, this message translates to:
  /// **'O token atual deixa de valer na hora: o cliente de IA vai precisar do novo.'**
  String get mcpGerarNovoTexto;

  /// No description provided for @mcpCopiarConfiguracao.
  ///
  /// In pt, this message translates to:
  /// **'Copiar configuração para'**
  String get mcpCopiarConfiguracao;

  /// No description provided for @mcpClienteLmStudio.
  ///
  /// In pt, this message translates to:
  /// **'LM Studio'**
  String get mcpClienteLmStudio;

  /// No description provided for @mcpClienteClaudeDesktop.
  ///
  /// In pt, this message translates to:
  /// **'Claude Desktop'**
  String get mcpClienteClaudeDesktop;

  /// No description provided for @mcpClienteGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Outro cliente'**
  String get mcpClienteGenerico;

  /// No description provided for @mcpCopiado.
  ///
  /// In pt, this message translates to:
  /// **'Copiado para a área de transferência.'**
  String get mcpCopiado;

  /// No description provided for @mcpLimitacoes.
  ///
  /// In pt, this message translates to:
  /// **'A IA não ouve o som: ela ajusta pelo que você descreve, e você diz se melhorou. Modelos pequenos costumam descrever o que fariam em vez de chamar as ferramentas; prefira um modelo com bom suporte a ferramentas.'**
  String get mcpLimitacoes;

  /// No description provided for @mcpAtivoNaBarra.
  ///
  /// In pt, this message translates to:
  /// **'IA'**
  String get mcpAtivoNaBarra;

  /// No description provided for @mcpAtivoDica.
  ///
  /// In pt, this message translates to:
  /// **'IA local pode ajustar o timbre (MCP ligado)'**
  String get mcpAtivoDica;

  /// No description provided for @mcpMudancaDaIa.
  ///
  /// In pt, this message translates to:
  /// **'IA: {resumo}'**
  String mcpMudancaDaIa(String resumo);

  /// No description provided for @mcpPedidoSalvarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Salvar o que a IA ajustou?'**
  String get mcpPedidoSalvarTitulo;

  /// No description provided for @mcpPedidoSalvarTexto.
  ///
  /// In pt, this message translates to:
  /// **'A IA pediu para gravar \"{nome}\" no slot {slot} da pedaleira.'**
  String mcpPedidoSalvarTexto(String nome, String slot);

  /// No description provided for @mcpPedidoSalvarSemSlot.
  ///
  /// In pt, this message translates to:
  /// **'A IA pediu para gravar \"{nome}\" na pedaleira. Você vai escolher o slot.'**
  String mcpPedidoSalvarSemSlot(String nome);

  /// No description provided for @mcpSalvar.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get mcpSalvar;

  /// No description provided for @mcpAgoraNao.
  ///
  /// In pt, this message translates to:
  /// **'AGORA NÃO'**
  String get mcpAgoraNao;

  /// No description provided for @ttDicaMouse.
  ///
  /// In pt, this message translates to:
  /// **'Pare o mouse sobre o nome de um controle para saber o que ele faz com o som'**
  String get ttDicaMouse;

  /// No description provided for @ttDicaToque.
  ///
  /// In pt, this message translates to:
  /// **'Toque no nome de um controle para saber o que ele faz com o som'**
  String get ttDicaToque;

  /// No description provided for @smUmSplit.
  ///
  /// In pt, this message translates to:
  /// **'Este preset já tem um Split (um por preset).'**
  String get smUmSplit;

  /// No description provided for @smUmMerge.
  ///
  /// In pt, this message translates to:
  /// **'Este preset já tem um Merge (um por preset).'**
  String get smUmMerge;

  /// No description provided for @smMergeSemSplit.
  ///
  /// In pt, this message translates to:
  /// **'Coloque o Split antes: o Merge junta a linha 2, que só existe com o Split.'**
  String get smMergeSemSplit;

  /// Na biblioteca aberta numa casa da linha 2 de um preset sem Split
  ///
  /// In pt, this message translates to:
  /// **'Sem Split na linha 1, esta linha ainda não recebe sinal.'**
  String get smLinha2SemSplit;

  /// No description provided for @lpCriar.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR LINHA PARALELA'**
  String get lpCriar;

  /// No description provided for @lpCriarDica.
  ///
  /// In pt, this message translates to:
  /// **'Divide o sinal depois do bloco selecionado na linha 1: a linha 2 toca em paralelo e o Merge junta as duas antes da saída.'**
  String get lpCriarDica;

  /// No description provided for @lpRemover.
  ///
  /// In pt, this message translates to:
  /// **'REMOVER LINHA PARALELA'**
  String get lpRemover;

  /// No description provided for @lpSemEspaco.
  ///
  /// In pt, this message translates to:
  /// **'A linha 1 precisa de duas casas livres para o Split e o Merge.'**
  String get lpSemEspaco;

  /// No description provided for @smFaixaCriar.
  ///
  /// In pt, this message translates to:
  /// **'+ Criar linha paralela · Split, linha 2 e Merge'**
  String get smFaixaCriar;

  /// No description provided for @smItemBiblioteca.
  ///
  /// In pt, this message translates to:
  /// **'Split + Merge (linha paralela)'**
  String get smItemBiblioteca;

  /// No description provided for @smItemBibliotecaDica.
  ///
  /// In pt, this message translates to:
  /// **'Divide o sinal nesta casa: a linha 2 toca em paralelo e o Merge junta as duas.'**
  String get smItemBibliotecaDica;

  /// No description provided for @smJaTemLinhaParalela.
  ///
  /// In pt, this message translates to:
  /// **'Este preset já tem linha paralela (um Split e um Merge por preset).'**
  String get smJaTemLinhaParalela;

  /// No description provided for @smDividirDepois.
  ///
  /// In pt, this message translates to:
  /// **'Dividir o sinal depois deste bloco'**
  String get smDividirDepois;

  /// No description provided for @mpExportarJson.
  ///
  /// In pt, this message translates to:
  /// **'Exportar JSON…'**
  String get mpExportarJson;

  /// No description provided for @mpLimpar.
  ///
  /// In pt, this message translates to:
  /// **'Limpar preset…'**
  String get mpLimpar;

  /// No description provided for @mpLimparFabrica.
  ///
  /// In pt, this message translates to:
  /// **'Limpar preset (a Fábrica é só leitura)'**
  String get mpLimparFabrica;

  /// No description provided for @mpLimparTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Limpar o {slot}?'**
  String mpLimparTitulo(String slot);

  /// No description provided for @mpLimparTexto.
  ///
  /// In pt, this message translates to:
  /// **'O preset \"{nome}\" sai do slot {slot} na pedaleira e o slot fica vazio. Não dá para desfazer. Para guardar uma cópia, exporte o JSON antes.'**
  String mpLimparTexto(String nome, String slot);

  /// No description provided for @mpExportarAntes.
  ///
  /// In pt, this message translates to:
  /// **'Exportar JSON'**
  String get mpExportarAntes;

  /// No description provided for @mpLimparConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get mpLimparConfirmar;

  /// No description provided for @mpLimpo.
  ///
  /// In pt, this message translates to:
  /// **'{slot} limpo: o slot ficou vazio.'**
  String mpLimpo(String slot);

  /// No description provided for @mpExportadoGravado.
  ///
  /// In pt, this message translates to:
  /// **'Exportado o preset gravado no {slot}; as edições não salvas ficaram de fora.'**
  String mpExportadoGravado(String slot);

  /// No description provided for @mpSlotVazio.
  ///
  /// In pt, this message translates to:
  /// **'O {slot} já está vazio na pedaleira.'**
  String mpSlotVazio(String slot);

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get axEntrada;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Osciladores'**
  String get axOsciladores;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Filtro'**
  String get axFiltro;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Envelope'**
  String get axEnvelope;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Arpejador'**
  String get axArpejador;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Saída'**
  String get axSaida;

  /// Título de seção do painel do Axioma Mono Synth
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get axOutros;

  /// No description provided for @ppTemplates.
  ///
  /// In pt, this message translates to:
  /// **'Templates'**
  String get ppTemplates;

  /// No description provided for @ppPersonalizado.
  ///
  /// In pt, this message translates to:
  /// **'Personalizado'**
  String get ppPersonalizado;

  /// No description provided for @ppAplicado.
  ///
  /// In pt, this message translates to:
  /// **'Template {nome} aplicado'**
  String ppAplicado(String nome);

  /// No description provided for @ppEscolherTemplate.
  ///
  /// In pt, this message translates to:
  /// **'Escolher template'**
  String get ppEscolherTemplate;

  /// No description provided for @ppDaDarkglass.
  ///
  /// In pt, this message translates to:
  /// **'Da Darkglass (os da pedaleira)'**
  String get ppDaDarkglass;

  /// No description provided for @ppDoApp.
  ///
  /// In pt, this message translates to:
  /// **'Do app (pontos de partida nossos)'**
  String get ppDoApp;

  /// No description provided for @ppAConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Valores ainda não lidos da pedaleira'**
  String get ppAConfirmar;

  /// No description provided for @mbTipoDrive.
  ///
  /// In pt, this message translates to:
  /// **'Drive type'**
  String get mbTipoDrive;

  /// No description provided for @mbModoDrive.
  ///
  /// In pt, this message translates to:
  /// **'Drive mode'**
  String get mbModoDrive;

  /// No description provided for @mbSolo.
  ///
  /// In pt, this message translates to:
  /// **'Solo'**
  String get mbSolo;

  /// No description provided for @mbSoloLigado.
  ///
  /// In pt, this message translates to:
  /// **'Só {banda} soando'**
  String mbSoloLigado(String banda);

  /// No description provided for @mbSoloDesligado.
  ///
  /// In pt, this message translates to:
  /// **'Solo desligado: as três bandas soam'**
  String get mbSoloDesligado;

  /// No description provided for @mbCurvaCompressor.
  ///
  /// In pt, this message translates to:
  /// **'Curva do compressor: Threshold {limiar} dB, Ratio {razao}:1'**
  String mbCurvaCompressor(String limiar, String razao);

  /// No description provided for @mbOff.
  ///
  /// In pt, this message translates to:
  /// **'OFF'**
  String get mbOff;

  /// Seção das Configurações com os ajustes globais da pedaleira (mixer, Global EQ, entrada)
  ///
  /// In pt, this message translates to:
  /// **'Pedaleira'**
  String get pdSecao;

  /// No description provided for @pdDica.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes globais da Anagram: valem para todos os presets e não entram no preset. Mudam na hora.'**
  String get pdDica;

  /// No description provided for @pdSaidas.
  ///
  /// In pt, this message translates to:
  /// **'Saídas'**
  String get pdSaidas;

  /// No description provided for @pdGlobalEq.
  ///
  /// In pt, this message translates to:
  /// **'Global EQ'**
  String get pdGlobalEq;

  /// No description provided for @pdEqModoGanho.
  ///
  /// In pt, this message translates to:
  /// **'Ganho'**
  String get pdEqModoGanho;

  /// No description provided for @pdEqModoFrequencia.
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get pdEqModoFrequencia;

  /// No description provided for @pdEqModoLargura.
  ///
  /// In pt, this message translates to:
  /// **'Largura'**
  String get pdEqModoLargura;

  /// No description provided for @pdEqInputGain.
  ///
  /// In pt, this message translates to:
  /// **'Input Gain'**
  String get pdEqInputGain;

  /// No description provided for @eqbResetTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Voltar o Parametric EQ ao padrão?'**
  String get eqbResetTitulo;

  /// No description provided for @eqbResetTexto.
  ///
  /// In pt, this message translates to:
  /// **'Todas as bandas, os cortes e o ganho voltam ao padrão do bloco. Dá para desfazer logo depois.'**
  String get eqbResetTexto;

  /// No description provided for @eqbResetFeito.
  ///
  /// In pt, this message translates to:
  /// **'Parametric EQ de volta ao padrão.'**
  String get eqbResetFeito;

  /// No description provided for @pdEqReset.
  ///
  /// In pt, this message translates to:
  /// **'Reset'**
  String get pdEqReset;

  /// No description provided for @pdEqResetTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Voltar o Global EQ ao padrão?'**
  String get pdEqResetTitulo;

  /// No description provided for @pdEqResetTexto.
  ///
  /// In pt, this message translates to:
  /// **'As 6 bandas voltam a 35 Hz, 160 Hz, 397 Hz, 1,25 kHz, 2,5 kHz e 9,63 kHz, com ganho 0 e a largura de fábrica. Dá para desfazer logo depois.'**
  String get pdEqResetTexto;

  /// No description provided for @pdEqResetConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'VOLTAR AO PADRÃO'**
  String get pdEqResetConfirmar;

  /// No description provided for @pdEqResetFeito.
  ///
  /// In pt, this message translates to:
  /// **'Global EQ de volta ao padrão.'**
  String get pdEqResetFeito;

  /// No description provided for @pdEqDica.
  ///
  /// In pt, this message translates to:
  /// **'Arraste os pontos: para os lados muda a frequência, para cima e para baixo o ganho. Os knobs mexem no que o modo escolhido mostra.'**
  String get pdEqDica;

  /// No description provided for @pdEntrada.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get pdEntrada;

  /// No description provided for @pdEntradaDica.
  ///
  /// In pt, this message translates to:
  /// **'Ganho de entrada do instrumento 1 (−12 a +12 dB). A Anagram guarda seis instrumentos; os outros cinco e os nomes entram quando o app conhecer as chaves deles.'**
  String get pdEntradaDica;

  /// No description provided for @pdPlaca.
  ///
  /// In pt, this message translates to:
  /// **'Placa de som'**
  String get pdPlaca;

  /// No description provided for @pdPlacaDica.
  ///
  /// In pt, this message translates to:
  /// **'Só leitura: a pedaleira não aceita mudar estes pelo USB.'**
  String get pdPlacaDica;

  /// No description provided for @pdAtualizar.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get pdAtualizar;

  /// No description provided for @pdLendo.
  ///
  /// In pt, this message translates to:
  /// **'Lendo os ajustes da pedaleira…'**
  String get pdLendo;

  /// No description provided for @pdFalhaLer.
  ///
  /// In pt, this message translates to:
  /// **'Não deu para ler os ajustes da pedaleira.'**
  String get pdFalhaLer;

  /// No description provided for @pdTentarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get pdTentarDeNovo;

  /// No description provided for @pdErroGravar.
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira não aceitou a última mudança. Os valores mostrados são os que ela tem agora.'**
  String get pdErroGravar;

  /// No description provided for @pdPendentes.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não dá para mudar pelo app: Master, Mute e Link do mixer e os nomes dos instrumentos.'**
  String get pdPendentes;

  /// Seção das Configurações com o arquivo de registro (log) do app, para relatar defeitos
  ///
  /// In pt, this message translates to:
  /// **'Registro para suporte'**
  String get registroSecao;

  /// Seção das Configurações com o arquivo de registro (log) do app, para relatar defeitos
  ///
  /// In pt, this message translates to:
  /// **'O app guarda o que acontece neste arquivo:'**
  String get registroOnde;

  /// Seção das Configurações com o arquivo de registro (log) do app, para relatar defeitos
  ///
  /// In pt, this message translates to:
  /// **'Copiar registro'**
  String get registroCopiar;

  /// Seção das Configurações com o arquivo de registro (log) do app, para relatar defeitos
  ///
  /// In pt, this message translates to:
  /// **'Registro copiado. Cole na issue do GitHub junto com o que aconteceu.'**
  String get registroCopiado;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'v{versao} disponível'**
  String versaoNovaNaBarra(String versao);

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'BAIXAR'**
  String get versaoNovaBaixar;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Lembrar depois'**
  String get versaoNovaLembrarDepois;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Atualizações'**
  String get versaoNovaSecao;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Verificar versão nova ao abrir'**
  String get versaoNovaVerificar;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Ao abrir, o app consulta só o GitHub para saber qual é a última versão publicada. Nenhum dado seu é enviado. Desligado, o app não acessa a internet.'**
  String get versaoNovaVerificarTexto;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Você está na versão mais recente.'**
  String get versaoNovaEmDia;

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Versão {versao} disponível.'**
  String versaoNovaDisponivel(String versao);

  /// Aviso de versão nova: barra de cima e seção Atualizações das Configurações
  ///
  /// In pt, this message translates to:
  /// **'Não deu para verificar agora; o app tenta de novo na próxima abertura.'**
  String get versaoNovaSemResposta;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Controles da pedaleira'**
  String get ctlTitulo;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Clique num controle para editar. Botão direito num knob atribui o parâmetro a um pot ou ao pedal; o menu do bloco põe um footswitch nele.'**
  String get ctlDicaMouse;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Toque num controle para editar ou atribuir um parâmetro do bloco aberto; o menu do bloco põe um footswitch nele.'**
  String get ctlDicaToque;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'FOOT'**
  String get ctlSiglaFoot;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'POT'**
  String get ctlSiglaPot;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'EXP'**
  String get ctlSiglaExp;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'livre'**
  String get ctlLivre;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Liga/desliga'**
  String get ctlLigaDesliga;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Atribuir a {controle}'**
  String ctlAtribuirA(String controle);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'já está aqui'**
  String get ctlJaAqui;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Footswitch {numero} liga/desliga este bloco'**
  String ctlFootswitchLigaBloco(int numero);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Nome no visor'**
  String get ctlNome;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Os presets de fábrica usam até {maximo} letras; um nome maior pode ser cortado no visor.'**
  String ctlNomeLongo(int maximo);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'MÍN'**
  String get ctlMinimo;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'MÁX'**
  String get ctlMaximo;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Tirar este parâmetro'**
  String get ctlRemoverAlvo;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'SOLTAR CONTROLE'**
  String get ctlRemoverControle;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'ATRIBUIR PARÂMETRO'**
  String get ctlAtribuirDoBloco;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Parâmetro de {bloco}'**
  String ctlEscolherParametro(String bloco);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Abra um bloco na cadeia para atribuir um parâmetro dele.'**
  String get ctlSemBlocoAberto;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Nenhum parâmetro neste controle.'**
  String get ctlSemAlvos;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Mínimo e máximo iguais deixam o controle sem curso.'**
  String get ctlFaixaIguais;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Fora da faixa do parâmetro.'**
  String get ctlFaixaFora;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'casa {linha}·{casa} vazia'**
  String ctlCasaVazia(int linha, int casa);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Atribuído a {controle}'**
  String ctlAtribuidoA(String controle);

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'Atribuir a um controle da pedaleira'**
  String get ctlAcaoAtribuir;

  /// Controles da pedaleira (footswitches, pots e pedal de expressão) no editor
  ///
  /// In pt, this message translates to:
  /// **'FECHAR'**
  String get ctlFechar;

  /// Comportamento da Anagram conferido na bancada (BD8): pot atribuído só vale na visualização compacta do preset
  ///
  /// In pt, this message translates to:
  /// **'Na pedaleira, os pots atribuídos só respondem na tela do preset em uma linha; com o preset expandido, os knobs mexem no bloco selecionado.'**
  String get ctlDicaPedaleira;

  /// Cartão do Auto Drummer: estilo, nível e tempo
  ///
  /// In pt, this message translates to:
  /// **'Bateria'**
  String get utBateria;

  /// Cartão do botão Action do Auto Drummer
  ///
  /// In pt, this message translates to:
  /// **'Ação'**
  String get utAcao;

  /// Cartão principal do Cognate Metro
  ///
  /// In pt, this message translates to:
  /// **'Metrônomo'**
  String get utMetronomo;

  /// Cartão do Gap Mode do Cognate Metro (compassos mudos para treinar)
  ///
  /// In pt, this message translates to:
  /// **'Treino'**
  String get utTreino;

  /// Botão que dá um toque no Action do Auto Drummer
  ///
  /// In pt, this message translates to:
  /// **'Disparar'**
  String get utDisparar;

  /// O toque só existe tocado na pedaleira: sem ao vivo não há o que enviar
  ///
  /// In pt, this message translates to:
  /// **'Ligue o AO VIVO para disparar daqui.'**
  String get utDispararSemAoVivo;

  /// Gestos do Action do Auto Drummer (como num footswitch)
  ///
  /// In pt, this message translates to:
  /// **'Um toque começa (com intro) ou faz uma virada; dois toques rápidos param; segurar 1 s passa para a próxima parte. Aqui, cada DISPARAR é um toque.'**
  String get utGestosAcao;

  /// O Status é saída do plugin e não chega pelo USB (P8)
  ///
  /// In pt, this message translates to:
  /// **'Se a bateria está tocando ou parada, só o visor da pedaleira mostra.'**
  String get utEstadoNoVisor;

  /// Tap tempo calculado no app
  ///
  /// In pt, this message translates to:
  /// **'Bater'**
  String get utBater;

  /// Por que o Bater está desabilitado em Follow Tempo e Global Tempo
  ///
  /// In pt, this message translates to:
  /// **'Bater o tempo só vale no modo Fixed Tempo.'**
  String get utBaterSoNoFixo;

  /// Accuracy é saída do plugin e não chega pelo USB
  ///
  /// In pt, this message translates to:
  /// **'A precisão do seu tempo (Accuracy) só aparece no visor da pedaleira.'**
  String get utPrecisaoNoVisor;

  /// Leitura dos pontos do compasso escolhido
  ///
  /// In pt, this message translates to:
  /// **'Compasso de {tempos} tempos, o 1 acentuado'**
  String utTemposDoCompasso(int tempos);

  /// No description provided for @slotAlteradoForaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'{slot} mudou na pedaleira'**
  String slotAlteradoForaTitulo(String slot);

  /// No description provided for @slotAlteradoForaTexto.
  ///
  /// In pt, this message translates to:
  /// **'O slot {slot} foi alterado na pedaleira desde que você abriu. Sobrescrever grava a sua versão por cima do que está lá; recarregar descarta as suas edições e mostra a versão da pedaleira.'**
  String slotAlteradoForaTexto(String slot);

  /// No description provided for @sobrescreverMesmoAssim.
  ///
  /// In pt, this message translates to:
  /// **'SOBRESCREVER MESMO ASSIM'**
  String get sobrescreverMesmoAssim;

  /// No description provided for @recarregarDaPedaleira.
  ///
  /// In pt, this message translates to:
  /// **'RECARREGAR DA PEDALEIRA'**
  String get recarregarDaPedaleira;

  /// No description provided for @uiRecarregarDaPedaleira.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar da pedaleira'**
  String get uiRecarregarDaPedaleira;

  /// No description provided for @recarregarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar {slot} da pedaleira?'**
  String recarregarTitulo(String slot);

  /// No description provided for @recarregarTexto.
  ///
  /// In pt, this message translates to:
  /// **'As mudanças não salvas de \"{nome}\" se perdem e o editor passa a mostrar o que está gravado no slot.'**
  String recarregarTexto(String nome);

  /// No description provided for @recarregar.
  ///
  /// In pt, this message translates to:
  /// **'RECARREGAR'**
  String get recarregar;

  /// No description provided for @pausaUsbTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Pausa entre pacotes USB'**
  String get pausaUsbTitulo;

  /// No description provided for @pausaUsbTexto.
  ///
  /// In pt, this message translates to:
  /// **'Menor = ao vivo mais rápido; aumente se a pedaleira deixar de responder. Auto usa o padrão deste computador.'**
  String get pausaUsbTexto;

  /// No description provided for @versaoNovaConsultaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Ao abrir, o app consulta só o GitHub para saber qual é a última versão publicada. A consulta envia apenas a versão do app (no cabeçalho User-Agent); como em toda conexão, o GitHub vê o seu endereço IP. Desligado, o app não acessa a internet.'**
  String get versaoNovaConsultaTexto;

  /// Rótulo do seletor do modo dos footswitches (ajuste global da pedaleira)
  ///
  /// In pt, this message translates to:
  /// **'Footswitches'**
  String get fmTitulo;

  /// Nome do modo dos footswitches como o Darkglass Suite (P, STP, SCN); other = valor que o app não conhece
  ///
  /// In pt, this message translates to:
  /// **'{modo, select, preset{PRESET} stomp{STOMP} scene{SCENE} other{—}}'**
  String fmModo(String modo);

  /// Leitor de tela do botão de um modo
  ///
  /// In pt, this message translates to:
  /// **'Footswitches no modo {modo}'**
  String fmSemantica(String modo);

  /// Dica curta sob o seletor do modo
  ///
  /// In pt, this message translates to:
  /// **'No modo Stomp, os footswitches seguem os controles da pedaleira deste preset. O modo vale para todos os presets.'**
  String get fmDica;

  /// A troca de modo foi recusada, não respondeu ou a releitura mostrou outro valor
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira não confirmou a troca de modo. O modo mostrado é o que ela tem agora.'**
  String get fmErro;

  /// O export_settings não trouxe a chave mode: o seletor fica desabilitado
  ///
  /// In pt, this message translates to:
  /// **'Esta pedaleira não informa o modo dos footswitches.'**
  String get fmIndisponivel;

  /// Aviso no painel de Controles quando o modo não é Stomp
  ///
  /// In pt, this message translates to:
  /// **'Os FOOT atribuídos só agem no modo Stomp; a pedaleira está em {modo}.'**
  String fmAvisoControles(String modo);

  /// Tooltip do selo desabilitado quando o valor de mode não é preset, stomp nem scene
  ///
  /// In pt, this message translates to:
  /// **'A pedaleira está num modo que o app não conhece. Troque o modo na própria pedaleira.'**
  String get fmDesconhecido;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
