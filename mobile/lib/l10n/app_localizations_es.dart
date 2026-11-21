// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get desconectar => 'Desconectar';

  @override
  String get creditos => 'Créditos';

  @override
  String get estadoSemConexao => 'Sin conexión';

  @override
  String estadoConectando(String meio) {
    return 'Conectando ($meio)…';
  }

  @override
  String get estadoDemonstracao => 'Demostración · sin pedalera';

  @override
  String estadoConectada(String meio, String firmware) {
    return 'Anagram · $meio · $firmware';
  }

  @override
  String get estadoFalha => 'Fallo de conexión';

  @override
  String conexaoSemantica(String texto) {
    return 'Conexión: $texto';
  }

  @override
  String idaEVolta(int ms) {
    return 'ida y vuelta $ms ms';
  }

  @override
  String get aoVivo => 'EN VIVO';

  @override
  String get aoVivoDesligado => 'EN VIVO APAGADO';

  @override
  String get conexaoPermissaoNegada =>
      'El sistema negó el acceso al USB de la Anagram. En Android, toca Conectar de nuevo y acepta el pedido; en macOS, revisa los ajustes de Privacidad y seguridad.';

  @override
  String get conexaoOcupada =>
      'La Anagram está conectada, pero otro programa la retiene. Cierra Darkglass Suite y cualquier pestaña del navegador conectada a la pedalera.';

  @override
  String get conexaoSemAnagram =>
      'No se encontró ninguna Anagram en el USB. Revisa el cable y que esté encendida.';

  @override
  String get conexaoSemResposta =>
      'La Anagram no respondió. Desconecta y vuelve a conectar el cable e inténtalo de nuevo.';

  @override
  String get conexaoRespostaInvalida => 'Respuesta inesperada de la pedalera.';

  @override
  String get erroOcupada => 'Otro programa retiene la pedalera.';

  @override
  String get erroDesconectado => 'La pedalera está desconectada.';

  @override
  String get erroSemResposta => 'La pedalera no respondió a tiempo.';

  @override
  String get erroRespostaInvalida =>
      'La pedalera rechazó o envió una respuesta inesperada.';

  @override
  String erroOperacaoEmCurso(String detalhe) {
    return 'Espera a que termine la operación en curso.';
  }

  @override
  String get erroSemSuporte =>
      'Esta plataforma no puede comunicarse con la pedalera.';

  @override
  String get avisoDemonstracaoFalhou => 'No se pudo abrir la demostración.';

  @override
  String avisoFalhaInesperada(String meio) {
    return 'No se pudo abrir $meio. Inténtalo de nuevo; el detalle quedó en el log.';
  }

  @override
  String get avisoPedaleiraDesconectada =>
      'La pedalera se desconectó. Conéctala de nuevo para seguir donde lo dejaste.';

  @override
  String get avisoFormatoMaisNovo =>
      'Preset con un formato más nuevo que esta app: los campos desconocidos se conservan.';

  @override
  String avisoPresetTrocado(String slot) {
    return 'La pedalera devolvió otro preset para $slot (id distinto del de la lista). La lista se recargó; ábrelo de nuevo.';
  }

  @override
  String get avisoAreaNaoTrocou => 'La pedalera no cambió de área.';

  @override
  String naoSalvou(String motivo) {
    return 'No se guardó: $motivo';
  }

  @override
  String get salvarDesconectada =>
      'la pedalera está desconectada. Conéctala e inténtalo de nuevo.';

  @override
  String get salvarSemResposta =>
      'la pedalera no respondió a tiempo. Puede que el slot no se haya guardado; revísalo antes de intentarlo de nuevo.';

  @override
  String get salvarRespostaInvalida =>
      'la pedalera rechazó o envió una respuesta inesperada.';

  @override
  String get salvarOcupada => 'otro programa retiene la pedalera.';

  @override
  String get indisponivelIos =>
      'iPhone y iPad no dejan que las apps comunes abran la interfaz USB de control de la Anagram: eso exige un driver DriverKit con permiso especial de Apple, que esta app aún no tiene. Usa la demostración aquí, o edita desde Mac, PC, Android o Chrome.';

  @override
  String get indisponivelNavegador =>
      'Este navegador no tiene WebHID. Usa Chrome o Edge en la computadora, o la demostración.';

  @override
  String get indisponivelSemUsb =>
      'Esta plataforma no tiene acceso USB a la pedalera.';

  @override
  String get importacaoIlegivel => 'No se pudo leer el archivo.';

  @override
  String importacaoNaoEhPreset(String detalhe) {
    return 'Este archivo no es un preset de la Anagram.';
  }

  @override
  String get exportacaoFalhou => 'No se pudo guardar el archivo.';

  @override
  String get nomeVazio => 'El nombre no puede quedar vacío.';

  @override
  String nomeComMarcador(String marcador) {
    return 'El nombre no puede contener \"$marcador\".';
  }

  @override
  String get familiaDrive => 'Drive';

  @override
  String get familiaDinamica => 'Dinámica';

  @override
  String get familiaEq => 'EQ';

  @override
  String get familiaFiltro => 'Filtro';

  @override
  String get familiaModulacao => 'Modulación';

  @override
  String get familiaDelay => 'Delay';

  @override
  String get familiaReverb => 'Reverb';

  @override
  String get familiaAmp => 'Amp';

  @override
  String get familiaGabinete => 'Gabinete';

  @override
  String get familiaUtilitario => 'Utilidad';

  @override
  String areaSemNome(int numero) {
    return 'Área $numero';
  }

  @override
  String get conecteTitulo => 'Conecta la Anagram por USB';

  @override
  String get conecteFecheSuite =>
      'Cierra Darkglass Suite antes: solo un programa a la vez controla la pedalera.';

  @override
  String get abrirDemonstracao => 'ABRIR DEMOSTRACIÓN';

  @override
  String get conectarPeloUsb => 'CONECTAR POR USB';

  @override
  String get cancelar => 'CANCELAR';

  @override
  String versaoApp(String versao) {
    return 'v$versao';
  }

  @override
  String versaoAppComArte(String versao) {
    return 'v$versao · arte de la pedalera';
  }

  @override
  String get fecharAviso => 'Cerrar aviso';

  @override
  String get largarEdicoesTitulo => '¿Descartar cambios?';

  @override
  String largarEdicoesTexto(String nome) {
    return '\"$nome\" tiene cambios que no se guardaron en el slot.';
  }

  @override
  String get continuarEditando => 'SEGUIR EDITANDO';

  @override
  String get largar => 'DESCARTAR';

  @override
  String get origem => 'ORIGEN';

  @override
  String get gravarAqui => 'Guardar aquí';

  @override
  String get pedaleiraNesteSlot => 'La pedalera está en este slot';

  @override
  String get slotVazio => 'vacío';

  @override
  String get area => 'ÁREA';

  @override
  String largarAoTrocarArea(String nome) {
    return '\"$nome\" tiene cambios sin guardar y se cerrará al cambiar de área.';
  }

  @override
  String get areaInativa =>
      'Esta área no está activa en la pedalera: abrir un preset solo lo reproduce, sin cambiar el slot en ella.';

  @override
  String get tornarAtiva => 'ACTIVAR';

  @override
  String get salvar => 'GUARDAR';

  @override
  String get salvarComo => 'GUARDAR COMO…';

  @override
  String get descartar => 'DESCARTAR';

  @override
  String get menuArquivo => 'Importar o exportar JSON';

  @override
  String get importarPreset => 'Importar preset (.json)';

  @override
  String get exportarPreset => 'Exportar preset (.json)';

  @override
  String presetImportado(String nome) {
    return '\"$nome\" importado. Guárdalo en un slot para conservarlo.';
  }

  @override
  String get presetExportado => 'Preset exportado.';

  @override
  String get presetCopiado => 'JSON del preset copiado al portapapeles.';

  @override
  String presetSalvoEm(String nome, String slot) {
    return '\"$nome\" guardado en $slot.';
  }

  @override
  String substituirTitulo(String slot) {
    return '¿Reemplazar $slot?';
  }

  @override
  String substituirTexto(String slot, String nome) {
    return 'El slot $slot guarda \"$nome\". Será reemplazado por el preset editado.';
  }

  @override
  String get substituir => 'REEMPLAZAR';

  @override
  String get salvarComoEscolhaDestino =>
      'GUARDAR COMO: TOCA EL SLOT DE DESTINO';

  @override
  String slotSemantica(String slot) {
    return 'Slot $slot';
  }

  @override
  String get slotNovo => 'nuevo';

  @override
  String get abrirListaSemantica => ', abrir lista de presets';

  @override
  String renomearPresetSemantica(String nome) {
    return 'Renombrar preset $nome';
  }

  @override
  String get avisoAoVivoDesligado =>
      'EN VIVO APAGADO — los cambios quedan en la app, la pedalera no cambia.';

  @override
  String get avisoAudicao =>
      'AUDICIÓN — la pedalera sigue en su slot (sin USB MIDI).';

  @override
  String get naoSalvo => 'SIN GUARDAR';

  @override
  String get escolhaUmPreset => 'Elige un preset';

  @override
  String slotEstaVazio(String slot) {
    return 'El slot $slot está vacío';
  }

  @override
  String get escolhaUmPresetTexto =>
      'Al abrirlo, la pedalera empieza a sonar con él. Los cambios suenan al instante y solo quedan guardados cuando guardas.';

  @override
  String get slotVazioTexto =>
      'Crea un preset aquí. Para traer bloques de otro preset, usa el ícono de copiar en el panel del bloque y luego mantén pulsada una casilla vacía para pegar.';

  @override
  String get criarPresetAqui => 'CREAR PRESET AQUÍ';

  @override
  String get verPresets => 'VER PRESETS';

  @override
  String get nomeDoPreset => 'Nombre del preset';

  @override
  String get nome => 'Nombre';

  @override
  String get renomear => 'RENOMBRAR';

  @override
  String blocoPosicao(String familia, int linha, int casa) {
    return '$familia · fila $linha, casilla $casa';
  }

  @override
  String get arrasteComMouse => 'Arrastra en la cuadrícula para moverlo';

  @override
  String get arrasteNoToque =>
      'Mantén pulsado y arrastra en la cuadrícula para moverlo';

  @override
  String ligadoSoNaCena(int cena) {
    return 'ENCENDIDO SOLO EN LA ESCENA $cena';
  }

  @override
  String desligadoSoNaCena(int cena) {
    return 'APAGADO SOLO EN LA ESCENA $cena';
  }

  @override
  String get copiarBloco => 'Copiar bloque';

  @override
  String get maisAcoesBloco => 'Más acciones del bloque';

  @override
  String get blocoLigadoSemantica => 'Bloque encendido';

  @override
  String get ligado => 'ENCENDIDO';

  @override
  String get desligado => 'APAGADO';

  @override
  String get adicionarEfeitoMenu => 'Agregar efecto…';

  @override
  String get colarAqui => 'Pegar aquí';

  @override
  String get ligarDesligar => 'Encender / apagar';

  @override
  String get moverEsquerda => 'Mover a la izquierda';

  @override
  String get moverDireita => 'Mover a la derecha';

  @override
  String moverParaLinha(int linha) {
    return 'Mover a la fila $linha';
  }

  @override
  String get removerBloco => 'Quitar bloque';

  @override
  String get semParametros => 'Este bloque no tiene parámetros ajustables.';

  @override
  String soNaCena(int cena) {
    return 'SOLO EN LA ESCENA $cena';
  }

  @override
  String get dicaMontarCadeia =>
      'Toca un + de la cuadrícula para agregar un efecto. Toca un bloque para ajustarlo; mantenlo pulsado y arrástralo para moverlo.';

  @override
  String faixaEstimada(String simbolo) {
    return '$simbolo (rango estimado)';
  }

  @override
  String get adicionarEfeito => 'Agregar efecto';

  @override
  String linhaCasa(int linha, int casa) {
    return 'Fila $linha, casilla $casa';
  }

  @override
  String get buscarPeloNome => 'Buscar por nombre';

  @override
  String get todos => 'Todos';

  @override
  String nenhumEfeito(String busca) {
    return 'Ningún efecto con \"$busca\".';
  }

  @override
  String nenhumEfeitoNaFamilia(String busca, String familia) {
    return 'Ningún efecto con \"$busca\" en $familia.';
  }

  @override
  String get sobreTitulo => 'Acerca de y diagnóstico';

  @override
  String get creditoAutorTitulo => 'Autor';

  @override
  String get creditoAutor =>
      'jordao_bass · software libre, licencia MIT. Gratis, sin anuncios, sin compras en la app y sin recopilación de datos.';

  @override
  String get creditoProtocoloTitulo => 'Protocolo USB y catálogo de bloques';

  @override
  String get creditoProtocolo =>
      'Portado del proyecto anagram-tone-maker, de basster6 — licencia MIT (github.com/basster6/anagram-tone-maker).';

  @override
  String get creditoArteTitulo => 'Arte de los bloques';

  @override
  String get creditoArtePropria =>
      'Arte propia de la app, por categoría de bloque.';

  @override
  String get creditoImagensTitulo => 'Imágenes de los bloques';

  @override
  String creditoImagens(String credito) {
    return '$credito. Los bloques sin imagen usan arte propia, por categoría.';
  }

  @override
  String get creditoFontesTitulo => 'Fuentes';

  @override
  String get creditoFontes =>
      'Barlow y Saira Stencil (SIL Open Font License) · Permanent Marker (Apache 2.0).';

  @override
  String get creditoAvisoTitulo => 'Aviso';

  @override
  String get creditoAviso =>
      'App no oficial, sin vínculo con Darkglass Electronics. Anagram es marca del fabricante.';

  @override
  String get diagnosticoPausa => 'DIAGNÓSTICO · PAUSA ENTRE REPORTES USB';

  @override
  String get diagnosticoPausaTexto =>
      'Compara 0, 2 y 10 ms y mira la \"ida y vuelta\" en la barra y en el log.';

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaDoSistema => 'Del sistema';

  @override
  String get separadorDecimal => ',';

  @override
  String get valorLigado => 'Encendido';

  @override
  String get valorDesligado => 'Apagado';

  @override
  String get voltarAoPadrao => 'Volver al valor por defecto';

  @override
  String voltouAoPadrao(String parametro) {
    return '$parametro volvió al valor por defecto.';
  }

  @override
  String get desfazer => 'DESHACER';

  @override
  String get pausaAuto => 'Auto';

  @override
  String get linha1 => 'FILA 1';

  @override
  String get linha2Paralela => 'FILA 2 · PARALELA';

  @override
  String cenaSemantica(int numero, String nome) {
    return 'Escena $numero, $nome';
  }

  @override
  String cenaPadrao(int numero) {
    return 'Escena $numero';
  }

  @override
  String adicionarEfeitoNaCasa(int casa, int linha) {
    return 'Agregar efecto en la casilla $casa, fila $linha';
  }

  @override
  String blocoLigado(String nome) {
    return '$nome, encendido';
  }

  @override
  String blocoDesligado(String nome) {
    return '$nome, apagado';
  }

  @override
  String get presets => 'Presets';

  @override
  String get txDicaMontarCadeiaMouse =>
      'Haz clic en un + de la cuadrícula para agregar un efecto. Haz clic en un bloque para ajustarlo y arrástralo para moverlo.';

  @override
  String get txSlotVazioMouse =>
      'Crea un preset aquí. Para traer bloques de otro preset, usa el ícono de copiar en el panel del bloque y luego haz clic derecho en una casilla vacía para pegar.';

  @override
  String get txModoDemonstracaoTitulo => 'Modo demostración';

  @override
  String get txSemUsbAquiCurto =>
      'Aquí la app no llega a la pedalera por USB. Explora todo en el modo demostración.';

  @override
  String get txPorQue => '¿POR QUÉ?';

  @override
  String get txEntendi => 'ENTENDIDO';

  @override
  String get txAtiva => 'ACTIVA';

  @override
  String get txAtivaNaPedaleiraDica => 'Área activa en la pedalera';

  @override
  String get txEstadoAbrindoDemonstracao => 'Abriendo la demostración…';

  @override
  String get cdNovoPreset => 'Preset nuevo';

  @override
  String get uiPresets => 'PRESETS';

  @override
  String get uiMaisAcoesPreset => 'Más acciones del preset';

  @override
  String get uiMenuArquivo => 'Importar o exportar el preset';

  @override
  String get uiDescartarEdicoes => 'Descartar ediciones';

  @override
  String get uiFecharBiblioteca => 'Cerrar';

  @override
  String get uiCena => 'ESCENA';

  @override
  String get uiSeloDesligado => 'OFF';

  @override
  String get uiRenomear => 'Renombrar';

  @override
  String get uiDicaDuploClique => 'Doble clic en el pedal lo enciende y apaga';

  @override
  String get uiDicaToqueDuplo => 'Doble toque en el pedal lo enciende y apaga';

  @override
  String get cdBlocoMono => 'Mono';

  @override
  String get cdBlocoEstereo => 'Estéreo';

  @override
  String get cdBlocoMonoCurto => 'M';

  @override
  String get cdBlocoEstereoCurto => 'ST';

  @override
  String get kbDigitarDica => 'Haz clic en el número para escribir el valor';

  @override
  String kbFaixa(String minimo, String maximo) {
    return 'De $minimo a $maximo';
  }

  @override
  String get kbNaoEhNumero => 'Escribe un número, como -12,5 o 1,5k.';

  @override
  String get kbAplicar => 'APLICAR';

  @override
  String get lpCriar => 'CREAR FILA PARALELA';

  @override
  String get lpCriarDica =>
      'Divide la señal después del bloque seleccionado en la fila 1: la fila 2 suena en paralelo y el Merge une las dos antes de la salida.';

  @override
  String get lpRemover => 'QUITAR FILA PARALELA';

  @override
  String get lpRemoverTitulo => '¿Quitar la fila paralela?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'Se quitan el Split, el Merge y los $quantidade bloques de la fila 2.';
  }

  @override
  String get lpRemoverConfirmar => 'QUITAR';

  @override
  String get lpSemEspaco =>
      'La fila 1 necesita dos casillas libres para el Split y el Merge.';

  @override
  String get cbGabinete => 'Gabinete';

  @override
  String get cbMicrofone => 'Micrófono';

  @override
  String get cbPosicao => 'Posición';

  @override
  String get cbEscolher => 'Elegir';

  @override
  String cbIrDoUsuario(String arquivo) {
    return 'IR propio: $arquivo';
  }

  @override
  String get opMoverPara => 'Mover a…';

  @override
  String get opClonarPara => 'Clonar a…';

  @override
  String get opTrocarBanco => 'Intercambiar banco con…';

  @override
  String get opAcoesPreset => 'Mover, clonar o intercambiar banco';

  @override
  String opDestinoMover(String origem) {
    return 'Mover $origem: toca el slot de destino';
  }

  @override
  String opDestinoClonar(String origem) {
    return 'Clonar $origem: toca el slot de destino';
  }

  @override
  String opDestinoBanco(String banco) {
    return 'Intercambiar el banco $banco: toca un slot del otro banco';
  }

  @override
  String get opTrocarTitulo => '¿Intercambiar los dos?';

  @override
  String opTrocarTexto(String destino, String nome, String origem) {
    return '$destino tiene \"$nome\". Pasa a $origem.';
  }

  @override
  String get opTrocar => 'INTERCAMBIAR';

  @override
  String opSubstituirTitulo(String destino) {
    return '¿Reemplazar $destino?';
  }

  @override
  String opSubstituirTexto(String nome, String origem) {
    return '\"$nome\" se borrará y se cambiará por la copia de $origem.';
  }

  @override
  String get opSubstituir => 'REEMPLAZAR';

  @override
  String opBancosTitulo(String a, String b) {
    return '¿Intercambiar los bancos $a y $b?';
  }

  @override
  String get opBancosTexto =>
      'Los tres presets de cada banco cambian de lugar.';

  @override
  String opMovido(String origem, String destino) {
    return '$origem pasó a $destino.';
  }

  @override
  String opClonado(String origem, String destino) {
    return 'Copia de $origem guardada en $destino.';
  }

  @override
  String opBancosTrocados(String a, String b) {
    return 'Bancos $a y $b intercambiados.';
  }

  @override
  String get gxModeloAnterior => 'Gabinete anterior';

  @override
  String get gxProximoModelo => 'Gabinete siguiente';

  @override
  String get gxBuscarGabinete => 'Escribe para buscar';

  @override
  String get fbAreaFabrica => 'Fábrica';

  @override
  String get fbSoLeitura => 'SOLO LECTURA';

  @override
  String get fbAreaSoLeitura =>
      'Presets de fábrica de Darkglass: abrir uno solo lo hace sonar. Para guardarlo, cópialo a una de tus áreas.';

  @override
  String get fbAvisoPresetDeFabrica =>
      'PRESET DE FÁBRICA — solo suena. Cópialo a una de tus áreas para guardarlo.';

  @override
  String get fbCopiarParaMinhaArea => 'COPIAR A MI ÁREA…';

  @override
  String get fbCopiarTitulo => '¿Copiar a qué área?';

  @override
  String get fbCopiarPara => 'Copiar a mi área…';

  @override
  String get eqBandaGeral => 'General';

  @override
  String get eqPassaAltas => 'Pasa altos';

  @override
  String get eqPassaBaixas => 'Pasa bajos';

  @override
  String get eqShelfGraves => 'Shelf de graves';

  @override
  String eqBanda(int numero) {
    return 'Banda $numero';
  }

  @override
  String get eqShelfAgudos => 'Shelf de agudos';

  @override
  String get ttDicaMouse =>
      'Deja el ratón sobre el nombre de un control para ver qué hace con el sonido';

  @override
  String get ttDicaToque =>
      'Toca el nombre de un control para ver qué hace con el sonido';
}
