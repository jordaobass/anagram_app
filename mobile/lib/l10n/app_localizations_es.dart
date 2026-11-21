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
  String avisoPresetAtualizado(String slot) {
    return '$slot cambió fuera de la app; se recargó la lista y se abrió la versión actual.';
  }

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
  String get lpRemoverTitulo => '¿Quitar el Split?';

  @override
  String lpRemoverTexto(int quantidade) {
    return 'Sin el Split la fila 2 no recibe señal: también salen el Merge y los $quantidade bloques de la fila 2.';
  }

  @override
  String get lpRemoverConfirmar => 'QUITAR';

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
  String get mbGraves => 'Graves';

  @override
  String get mbMedios => 'Medios';

  @override
  String get mbAgudos => 'Agudos';

  @override
  String get mbBordaGraves => '20 Hz';

  @override
  String get mbBordaAgudos => '20 kHz';

  @override
  String get mbMudo => 'Silencio';

  @override
  String get mbCompLigada => 'Comp activado';

  @override
  String get mbCompDesligada => 'Comp desactivado';

  @override
  String get mbSaida => 'Salida';

  @override
  String get mbOutros => 'Otros';

  @override
  String get mbExplicaMisturaLimpa =>
      'Comp Level es el volumen de las tres bandas comprimidas. Clean Level mezcla en paralelo la señal seca, sin compresión: en el mínimo (−24 dB) casi solo se oye lo comprimido; al subirlo vuelve el ataque natural de la cuerda.';

  @override
  String get mbBuscarOpcao => 'Buscar (ej.: turbo grunt)';

  @override
  String get smOrdemInvalida =>
      'El Split tiene que quedar antes del Merge en la fila 1.';

  @override
  String get smSoNaLinha1 => 'Split y Merge quedan en la fila 1.';

  @override
  String gvAnterior(String rotulo) {
    return '$rotulo: opción anterior';
  }

  @override
  String gvProximo(String rotulo) {
    return '$rotulo: opción siguiente';
  }

  @override
  String gvAbrirLista(String rotulo, String nome) {
    return '$rotulo: $nome. Toca para ver todos';
  }

  @override
  String get gvBuscar => 'Escribe para buscar';

  @override
  String get gvNadaEncontrado => 'Nada encontrado';

  @override
  String get gxModeloAnterior => 'Gabinete anterior';

  @override
  String get gxProximoModelo => 'Gabinete siguiente';

  @override
  String get gxBuscarGabinete => 'Escribe para buscar';

  @override
  String get mcpConfiguracoes => 'Configuración';

  @override
  String get mcpSecao => 'IA local (MCP)';

  @override
  String get mcpPermitir => 'Permitir IA vía MCP';

  @override
  String get mcpPermitirTexto =>
      'Un asistente de IA en tu computadora (LM Studio, Claude Desktop…) puede leer el preset abierto y ajustar el tono. Los cambios suenan al momento y solo van a la pedalera si guardas.';

  @override
  String get mcpEstadoDesligado =>
      'Apagado: ningún programa puede hablar con la app.';

  @override
  String get mcpEstadoIniciando => 'Iniciando…';

  @override
  String mcpEstadoEscutando(String endereco) {
    return 'Escuchando en $endereco';
  }

  @override
  String mcpEstadoPortaOcupada(int porta) {
    return 'El puerto $porta ya lo usa otro programa (u otra ventana de la app). Elige otro puerto.';
  }

  @override
  String get mcpPorta => 'Puerto';

  @override
  String get mcpPortaInvalida => 'Usa un número de 1024 a 65535.';

  @override
  String get mcpAplicarPorta => 'APLICAR';

  @override
  String get mcpToken => 'Token de acceso';

  @override
  String get mcpTokenTexto =>
      'El cliente de IA envía este token en cada pedido. Sin él, la app no obedece.';

  @override
  String get mcpMostrarToken => 'Mostrar token';

  @override
  String get mcpOcultarToken => 'Ocultar token';

  @override
  String get mcpCopiarToken => 'Copiar token';

  @override
  String get mcpGerarNovoToken => 'GENERAR NUEVO';

  @override
  String get mcpGerarNovoTitulo => '¿Generar un token nuevo?';

  @override
  String get mcpGerarNovoTexto =>
      'El token actual deja de valer al momento: el cliente de IA necesitará el nuevo.';

  @override
  String get mcpCopiarConfiguracao => 'Copiar configuración para';

  @override
  String get mcpClienteLmStudio => 'LM Studio';

  @override
  String get mcpClienteClaudeDesktop => 'Claude Desktop';

  @override
  String get mcpClienteGenerico => 'Otro cliente';

  @override
  String get mcpCopiado => 'Copiado al portapapeles.';

  @override
  String get mcpLimitacoes =>
      'La IA no oye el sonido: ajusta según lo que describes, y tú dices si mejoró. Los modelos pequeños suelen describir lo que harían en vez de llamar a las herramientas; prefiere un modelo con buen soporte de herramientas.';

  @override
  String get mcpAtivoNaBarra => 'IA';

  @override
  String get mcpAtivoDica =>
      'La IA local puede ajustar el tono (MCP encendido)';

  @override
  String mcpMudancaDaIa(String resumo) {
    return 'IA: $resumo';
  }

  @override
  String get mcpPedidoSalvarTitulo => '¿Guardar lo que ajustó la IA?';

  @override
  String mcpPedidoSalvarTexto(String nome, String slot) {
    return 'La IA pidió grabar \"$nome\" en el slot $slot de la pedalera.';
  }

  @override
  String mcpPedidoSalvarSemSlot(String nome) {
    return 'La IA pidió grabar \"$nome\" en la pedalera. Tú eliges el slot.';
  }

  @override
  String get mcpSalvar => 'GUARDAR';

  @override
  String get mcpAgoraNao => 'AHORA NO';

  @override
  String get ttDicaMouse =>
      'Deja el ratón sobre el nombre de un control para ver qué hace con el sonido';

  @override
  String get ttDicaToque =>
      'Toca el nombre de un control para ver qué hace con el sonido';

  @override
  String get smUmSplit => 'Este preset ya tiene un Split (uno por preset).';

  @override
  String get smUmMerge => 'Este preset ya tiene un Merge (uno por preset).';

  @override
  String get smMergeSemSplit =>
      'Pon el Split antes: el Merge junta la fila 2, que solo existe con el Split.';

  @override
  String get smLinha2SemSplit =>
      'Sin Split en la fila 1, esta fila todavía no recibe señal.';

  @override
  String get lpCriar => 'CREAR FILA PARALELA';

  @override
  String get lpCriarDica =>
      'Divide la señal después del bloque seleccionado en la fila 1: la fila 2 suena en paralelo y el Merge une las dos antes de la salida.';

  @override
  String get lpRemover => 'QUITAR FILA PARALELA';

  @override
  String get lpSemEspaco =>
      'La fila 1 necesita dos casillas libres para el Split y el Merge.';

  @override
  String get smFaixaCriar => '+ Crear fila paralela · Split, fila 2 y Merge';

  @override
  String get smItemBiblioteca => 'Split + Merge (fila paralela)';

  @override
  String get smItemBibliotecaDica =>
      'Divide la señal en esta casilla: la fila 2 suena en paralelo y el Merge une las dos.';

  @override
  String get smJaTemLinhaParalela =>
      'Este preset ya tiene fila paralela (un Split y un Merge por preset).';

  @override
  String get smDividirDepois => 'Dividir la señal después de este bloque';

  @override
  String get mpExportarJson => 'Exportar JSON…';

  @override
  String get mpLimpar => 'Borrar preset…';

  @override
  String get mpLimparFabrica => 'Borrar preset (Fábrica es solo lectura)';

  @override
  String mpLimparTitulo(String slot) {
    return '¿Borrar el $slot?';
  }

  @override
  String mpLimparTexto(String nome, String slot) {
    return 'El preset \"$nome\" sale del slot $slot en la pedalera y el slot queda vacío. No se puede deshacer. Para guardar una copia, exporta el JSON antes.';
  }

  @override
  String get mpExportarAntes => 'Exportar JSON';

  @override
  String get mpLimparConfirmar => 'Borrar';

  @override
  String mpLimpo(String slot) {
    return '$slot borrado: el slot quedó vacío.';
  }

  @override
  String mpExportadoGravado(String slot) {
    return 'Se exportó el preset guardado en $slot; las ediciones sin guardar quedaron fuera.';
  }

  @override
  String mpSlotVazio(String slot) {
    return 'El $slot ya está vacío en la pedalera.';
  }

  @override
  String get axEntrada => 'Entrada';

  @override
  String get axOsciladores => 'Osciladores';

  @override
  String get axFiltro => 'Filtro';

  @override
  String get axEnvelope => 'Envolvente';

  @override
  String get axArpejador => 'Arpegiador';

  @override
  String get axSaida => 'Salida';

  @override
  String get axOutros => 'Otros';

  @override
  String get ppTemplates => 'Templates';

  @override
  String get ppPersonalizado => 'Personalizado';

  @override
  String ppAplicado(String nome) {
    return 'Template $nome aplicado';
  }

  @override
  String get ppEscolherTemplate => 'Elegir template';

  @override
  String get ppDaDarkglass => 'De Darkglass (los de la pedalera)';

  @override
  String get ppDoApp => 'De la app (nuestros puntos de partida)';

  @override
  String get ppAConfirmar => 'Valores aún no leídos de la pedalera';

  @override
  String get mbTipoDrive => 'Drive type';

  @override
  String get mbModoDrive => 'Drive mode';

  @override
  String get mbSolo => 'Solo';

  @override
  String mbSoloLigado(String banda) {
    return 'Solo suena $banda';
  }

  @override
  String get mbSoloDesligado => 'Solo apagado: suenan las tres bandas';

  @override
  String get mbOff => 'OFF';

  @override
  String get pdSecao => 'Pedalera';

  @override
  String get pdDica =>
      'Ajustes globales de la Anagram: valen para todos los presets y no se guardan en el preset. Cambian al instante.';

  @override
  String get pdSaidas => 'Salidas';

  @override
  String get pdGlobalEq => 'Global EQ';

  @override
  String get pdEqModoGanho => 'Ganancia';

  @override
  String get pdEqModoFrequencia => 'Frecuencia';

  @override
  String get pdEqModoLargura => 'Ancho';

  @override
  String get pdEqInputGain => 'Input Gain';

  @override
  String get pdEqReset => 'Reset';

  @override
  String get pdEqResetTitulo => '¿Volver el Global EQ al valor de fábrica?';

  @override
  String get pdEqResetTexto =>
      'Las 6 bandas vuelven a 35 Hz, 160 Hz, 397 Hz, 1,25 kHz, 2,5 kHz y 9,63 kHz, con ganancia 0 y el ancho de fábrica. Se puede deshacer justo después.';

  @override
  String get pdEqResetConfirmar => 'VOLVER AL VALOR DE FÁBRICA';

  @override
  String get pdEqResetFeito => 'Global EQ de vuelta al valor de fábrica.';

  @override
  String get pdEqDica =>
      'Arrastra los puntos: hacia los lados cambia la frecuencia, arriba y abajo la ganancia. Los knobs cambian lo que muestra el modo elegido.';

  @override
  String get pdEntrada => 'Entrada';

  @override
  String get pdEntradaDica =>
      'Ganancia de entrada del instrumento 1 (−12 a +12 dB). La Anagram guarda seis instrumentos; los otros cinco y sus nombres llegarán cuando la app conozca sus claves.';

  @override
  String get pdPlaca => 'Tarjeta de sonido';

  @override
  String get pdPlacaDica =>
      'Solo lectura: la pedalera no acepta cambiar esto por USB.';

  @override
  String get pdAtualizar => 'Actualizar';

  @override
  String get pdLendo => 'Leyendo los ajustes de la pedalera…';

  @override
  String get pdFalhaLer => 'No se pudieron leer los ajustes de la pedalera.';

  @override
  String get pdTentarDeNovo => 'Reintentar';

  @override
  String get pdErroGravar =>
      'La pedalera no aceptó el último cambio. Los valores mostrados son los que tiene ahora.';

  @override
  String get pdPendentes =>
      'Todavía no se puede cambiar desde la app: Master, Mute y Link del mixer y los nombres de los instrumentos.';
}
