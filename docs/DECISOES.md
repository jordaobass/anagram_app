# Decisões — Anagram App

Registro único de decisões (aberta / decidida). Formato: **estado · data · onde aterrissou**.
Fatos sobre o protocolo vêm de `docs/pesquisa-anagram-hid.md` do app Partitura (código conferido
em 2026-11-05) e de `pesquisa-hx-stomp.md` (com fontes). **Nada foi testado com a pedaleira real
ainda**: o que depende do aparelho está marcado como hipótese.

## Produto e escopo

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| D1 | Nome do projeto `anagram-app`, pacote `anagram_app`, título "Anagram App" até haver marca | decidida (usuário) | 2026-11-05 | `pubspec.yaml`, `AppInfo.xcconfig`, `AndroidManifest.xml`, `web/` |
| D6 | **Gratuito e open source**, licença MIT "Copyright (c) 2026 jordao_bass". Autor = jordao_bass (README, Créditos, `description` do pubspec); nenhuma menção à Nexttag no app | decidida (usuário) | 2026-11-05 | `LICENSE`, `README.md`, `TelaCreditos` |
| D7 | **Autor x publicador**: a autoria e a licença são de jordao_bass; a publicação nas lojas é pela conta da Nexttag (Apple team `QH32WB9TFQ`, Play da Nexttag). Única menção: a linha "Publicado nas lojas por Nexttag" no README | decidida (usuário) | 2026-11-05 | `README.md`, `DEVELOPMENT_TEAM` |
| D8 | Bundle/application id `com.nexttag.anagramapp` em todas as plataformas (substitui o provisório `io.github.jordaobass.anagramapp`); `DEVELOPMENT_TEAM = QH32WB9TFQ` no iOS e no macOS | decidida (usuário) | 2026-11-05 | `build.gradle.kts`, `project.pbxproj`, `AppInfo.xcconfig`, `linux/CMakeLists.txt` |
| D9 | Sem anúncios, sem compras no app, **sem telemetria nem coleta de dados** (nenhuma chamada de rede). Isso prevalece sobre a regra geral de mandar logs ao Loki: aqui o log é só local (`logger`) | decidida (usuário) | 2026-11-05 | `lib/nucleo/registro.dart` |
| D2 | MVP no estilo HX Edit: lista por banco (01A…42C) que toca o preset ao abrir; grade 2×12 com bypass (toque duplo, botão, menu); parâmetros em knobs ~~paginados~~ todos à vista (T7) com faixas e unidades reais; cenas 1–3 como snapshots; edição ao vivo; selo "NÃO SALVO"; salvar no slot com confirmação; importar/exportar JSON; copiar/colar bloco | decidida | 2026-11-05 | `lib/apresentacao/` |
| D3 | Fora do MVP: arrastar bloco (reordenar exige regras de split/merge), adicionar bloco novo do catálogo, edição de bindings (pot/foot/exp), setlists, trocar modo de footswitch, Control Active/All, atalhos além dos básicos, importar presets do Bass Eras | decidida | 2026-11-05 | — |
| D4 | Abrir preset = **Program Change pelo USB MIDI** (programa = número do slot contando de 1, sem bank select, canal 1 — conferido no `midi.py goto_slot`: 17A = programa 49) e depois `try_anagram_preset`. CoreMIDI no macOS/iOS, android.media.midi no Android, Web MIDI no navegador; Linux/Windows sem MIDI por ora. Sem MIDI, a fita diz "AUDIÇÃO — a pedaleira continua no slot dela". Exige o USB MIDI ligado nos ajustes da pedaleira. **Hipótese a conferir no aparelho**: o byte de programa 1–126 (e não 0–125) | decidida (revisão) | 2026-11-05 | `MensagensMidi`, `SaidaMidi*`, `CanalMidiAnagram` (Swift), `CanalMidiAndroid.kt` |
| D5 | Abrir o app ou conectar **não** toca nada: só abrir um preset muda o som (não há como saber qual preset está tocando na pedaleira) | decidida | 2026-11-05 | `EditorVazio` |

## Edição ao vivo (pedido do usuário)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| L1 | Edição AO VIVO por padrão: mexeu, soa. Durante o arraste vai no máximo 1 documento a cada 100 ms (sempre o mais recente, nunca dois em voo); ao soltar vai o valor final na hora. Bypass, cena, colar e descartar vão na hora | decidida (usuário) | 2026-11-05 | `lib/aplicacao/envio_ao_vivo.dart` |
| L2 | Interruptor "Ao vivo" (ligado por padrão) na barra; desligado, edita sem mandar; religar manda o estado atual | decidida (usuário) | 2026-11-05 | `BarraConexao`, `definirAoVivo` |
| L3 | Latência ida e volta de cada ação medida com cronômetro e registrada no log (`anagram try_anagram_preset: ida e volta N ms (R relatórios)`); a última aparece na barra | decidida (usuário) | 2026-11-05 | `ClienteAnagram._registrarMedicao` |
| L4 | ~~aberta~~ **decidida (revisão)**: pausa entre relatórios configurável — padrão do transporte (0 ms no IOKit, onde o SetReport é síncrono; 10 ms em Android/hidapi/WebHID), escolha 0/2/10 ms em Sobre e diagnóstico, e a pausa sai em cada linha de medição do log. Medir no Mac. Texto original: Hipótese: `try_anagram_preset` com o preset inteiro (~38 relatórios de 64 B para um preset de 4 blocos, com 10 ms de pausa entre relatórios = ≥ 0,4 s só de envio) pode ser lento demais para arraste fluido. Medir no Mac; se passar de ~150 ms, opções: tirar a pausa entre relatórios, ou enviar por MIDI CC os knobs vinculados | **aberta** | 2026-11-05 | — |
| L5 | **Salvar** (botão/Cmd+S) grava no slot aberto, sem perguntar. **Salvar como…** (Cmd+Shift+S) põe a lista de presets em modo "escolher destino"; confirma só se o destino está ocupado e é diferente da origem. Grava e relê para confirmar; outro slot ganha uuid novo | decidida (revisão) | 2026-11-05 | `fluxo_salvar.dart`, `FaixaEscolherDestino` |
| L6 | Trocar de cena não marca "NÃO SALVO" (a cena ativa fica fora da comparação, mas vai junto ao salvar) | decidida (revisão) | 2026-11-05 | `EstadoEditor.naoSalvo` |
| L7 | Resposta de outra ação conhecida (atrasada, de chamada que estourou o prazo) é descartada; leitura sem `data` é erro, nunca "slot vazio". Eco de ação desconhecido é aceito, porque o formato do firmware não está documentado | decidida (revisão) | 2026-11-05 | `ClienteAnagram._ehRespostaDe`, `ApiAnagram.lerPreset` |
| L8 | Aperto de mão de 3 s (firmware) com Cancelar; tentativa cancelada é ignorada quando termina | decidida (revisão) | 2026-11-05 | `ControladorConexao` |

## Cenas (snapshots)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| C1 | Valor mostrado = sobreposição da cena ativa, senão o valor base. Editar com a cena ativa grava na cena **se ela já sobrepõe** o parâmetro; senão grava na base (vale para todas as cenas) — como "Snapshot Edits: Recall" do HX | decidida | 2026-11-05 | `DocumentoPreset.comParametro` |
| C2 | Bypass grava **só** em `scenes[cena ativa].enabled` (cria o registro se faltar), base e outras cenas intactas — "as cenas guardam só o que difere". O cabeçalho mostra "LIGADO/DESLIGADO SÓ NA CENA n". **Hipótese**: conferir no aparelho que o firmware lê assim | decidida (revisão), conferir | 2026-11-05 | `comBlocoHabilitado`, `bypassSoNaCena` |
| C3 | Criar sobreposição nova de cena (o "assign to snapshot" do HX) fica fora do MVP | decidida | 2026-11-05 | — |

## Protocolo e formato

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| P1 | Núcleo em Dart puro (`lib/nucleo/`): quadros HID, cliente com fila (uma conversa por vez) e prazo, API tipada, modelo de preset que preserva campos desconhecidos (round-trip testado nos 4 exemplos reais) | decidida | 2026-11-05 | `lib/nucleo/` |
| P2 | Resposta de escrita (`edit_anagram_presets`, `try_anagram_preset`, `delete`) não está documentada: qualquer resposta sem `error` conta como aceite; o salvar confirma relendo o slot | decidida (hipótese de formato) | 2026-11-05 | `ClienteAnagram._extrairCarga` |
| P3 | Opções de parâmetro: o catálogo só dá min/max. Se os rótulos são números que começam em min e terminam em max ("2:1"…"100:1"), o valor é o número; se max−min = n−1, passos de 1; senão espalha de min a max. **Hipótese**; conferir Ratio do Compressor no aparelho | aberta | 2026-11-05 | `DefinicaoParametro.valoresOpcoes` |
| P4 | Bloco fora do catálogo de fábrica (Marketplace): mostra o fim da uri e os parâmetros guardados com faixa **estimada** (marcada no nome). `get_plugin_info` já está na API, mas ainda não é chamado | aberta | 2026-11-05 | `parametrosVisiveis` |
| P5 | Enquanto o catálogo não carregou, o painel de parâmetros espera (não mostra faixa chutada) | decidida | 2026-11-05 | `PainelParametros` |

## Plataformas

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| T1 | macOS: canal nativo Swift com IOHIDManager (sem dependência), sandbox com `com.apple.security.device.usb`; envio como a hidapi (id ≠ 0 → buffer inteiro) | decidida; compila; **sem teste com aparelho** | 2026-11-05 | `macos/Runner/MainFlutterWindow.swift` |
| T2 | Android: USB Host em Kotlin, pede permissão; interface = HID com endpoint de saída; sem OUT usa SET_REPORT | decidida; compila (APK debug); **sem teste com aparelho** | 2026-11-05 | `CanalHidAndroid.kt` |
| T3 | Linux/Windows: hidapi por FFI (biblioteca do sistema: `libhidapi-hidraw0` / `hidapi.dll` ao lado do .exe), leitura em isolate | decidida; **não compilado** (sem toolchain desktop Linux/Windows aqui) | 2026-11-05 | `lib/plataforma/transporte_hidapi.dart` |
| T4 | Web: WebHID (Chrome/Edge), id do relatório à parte no `sendReport` | decidida; compila (`flutter build web`) | 2026-11-05 | `transporte_webhid.dart` |
| T5 | iPhone/iPad: sem HID de fornecedor sem DriverKit; botão Conectar desabilitado com o motivo, só demonstração. MIDI no iOS fica para a etapa de MIDI (D4) | decidida | 2026-11-05 | `fabrica_plataforma_io.dart` |
| T6 | Plugins nativos por Swift Package Manager (o Mac de build não tem CocoaPods); macOS mínimo 12.0 | decidida | 2026-11-05 | `pubspec.yaml`, `project.pbxproj` |

## Arte e créditos (pedido do usuário)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| A1 | Miniaturas dos blocos = as 46 do site Bass Eras, casadas pela uri informada pela pedaleira e, na falta, pelo nome. **Ficam fora do repositório** (repo público): pasta opcional `assets/blocos_terceiros/` no `.gitignore`, preenchida por `ferramentas/gerar_miniaturas.py`. Sem a pasta, o app usa a arte própria (testado). O crédito "Imagens: anagramanswers.com" só aparece em Créditos quando elas estão presentes | decidida (usuário) | 2026-11-05 | `assets/blocos_terceiros/`, `provedores.dart`, `TelaCreditos` |
| A2 | **Pendência: autorização de anagramanswers.com** antes de pôr as miniaturas no repositório ou nas lojas | **aberta** | 2026-11-05 | — |
| A7 | O histórico local tinha as miniaturas de terceiros (commits `6d2d5a2`, `fd272ff`, `4d2e41c`). **Decisão do usuário: squash num commit só** antes de publicar no GitHub público; o repositório passa a ser a raiz `anagram-app/` (`mobile/` + `docs/`). O histórico antigo fica fora do repositório, em `../anagram-app-backup/` (bundle + `.git` original), sem ir para o remoto | decidida (usuário) | 2026-11-06 | `jordaobass/anagram_app` |
| A8 | Release só de clone limpo; `ferramentas/verificar_release.sh` falha se houver arquivo de terceiros em `assets/blocos_terceiros/` | decidida (revisão) | 2026-11-05 | `ferramentas/`, `README.md` |
| A9 | **Arte da própria pedaleira** (a que o Darkglass Suite mostra, `assets/devices/anagram/effects`): par ligado/desligado por uri, 101 blocos de fábrica, 200 px. Vence a miniatura de anagramanswers.com na mesma uri; bloco em bypass mostra a imagem "Off" em vez do filtro cinza. Mesmo regime da A1: pasta `assets/blocos_terceiros/` (prefixo `dg_`), fora do git e barrada no release pelo `verificar_release.sh`. Gerada por `ferramentas/baixar_arte_pedaleira.py` (tabela uri→arquivo do anagramcontrol.online; imagens da pasta do Suite, se informada, ou da cópia do site). Sem arte: gabinetes de fábrica (`cabinet-bass/guitar/artists`), Tuner, mixer, medidores, MIDI e tone3000 continuam com a arte própria. **Revê a A4 a pedido do usuário** (A4 vetava a arte do Marketplace no app); a arte é da Darkglass, então ir para repositório público ou lojas **exige autorização do fabricante** (pendência junto da A2) | decidida (usuário), uso local | 2026-11-05 | `baixar_arte_pedaleira.py`, `IndiceMiniaturas`, `ArteBlocoWidget` |
| A3 | Sem miniatura: arte própria por família (cor e forma por família, glifo da função, sem marca nem logo) | decidida (usuário) | 2026-11-05 | `pintor_arte_familia.dart` |
| A4 | Nada da arte do Darkglass Marketplace usada pelo anagramcontrol.online; modelo `ArteOficial` reservado para arte autorizada pelo fabricante | decidida (usuário) | 2026-11-05 | `indice_miniaturas.dart` |
| A5 | Gabinetes (13 miniaturas) não casam: na pedaleira o gabinete é um bloco único com o arquivo do IR em `properties`; casar por arquivo de IR fica para depois | aberta | 2026-11-05 | — |
| A6 | Código do anagramcontrol.online (sem licença) usado só como referência de comportamento; código portado do anagram-tone-maker (MIT) com crédito | decidida | 2026-11-05 | `TelaCreditos`, `README.md` |

## Visual

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| V1 | Mundo "case de estrada": ABS preto, filetes e cantoneiras de alumínio, nome do preset em fita gaffer com letra de marcador, slot em estêncil, fita de cor por família; tema escuro único; alvos ≥ 48 dp. Contrato em `mobile/.impeccable/surfaces/lib-main-dart.md`; tokens em `lib/apresentacao/tema/tokens.dart` | decidida (sem rodada de aprovação com o usuário; caminho code-led) | 2026-11-05 | `PRODUCT.md`, `DESIGN.md` |

## Interface (revisão, rodada 2)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| U1 | Celular: cadeia só com casas ocupadas + 1 livre por linha, quebrando fileiras (nada escondido à direita); parâmetros todos, sem páginas | decidida | 2026-11-05 | `GradeCompacta`, `PainelParametros(paginar:)` |
| U2 | Knob volta ao padrão ao **segurar** (toque duplo era fácil de dar sem querer); ação acessível "Voltar ao padrão" | decidida | 2026-11-05 | `BotaoGiratorio` |
| U3 | Renomear pela fita (até 24 caracteres — **hipótese** do limite do visor), criar preset em slot vazio, remover bloco pelo menu da casa | decidida | 2026-11-05 | `dialogo_renomear.dart`, `EditorVazio`, `menu_bloco.dart` |
| U4 | Botão "CONECTAR PELO USB"; o meio técnico (IOKit/hidapi) fica no detalhe abaixo | decidida | 2026-11-05 | `PainelConectar` |
| U5 | Descartar sempre presente (desabilitado sem mudanças), Ao vivo desligado em faixa vermelha na barra e aviso na fita | decidida | 2026-11-05 | `AcoesPreset`, `BarraConexao`, `FaixaPreset` |
| U6 | Espaço e 1–3 só valem com o foco no editor; com botão/campo focado a tecla é dele | decidida | 2026-11-05 | `AtalhosEditor` |
| U7 | Preset de `version` > 1: abre, preserva os campos e avisa | decidida | 2026-11-05 | `DocumentoPreset.versaoMaisNova` |
| U8 | Android: plugar a Anagram oferece abrir o app (USB_DEVICE_ATTACHED + filtro VID 0x2FA6/PID 0x2500) | decidida; não testado em aparelho | 2026-11-05 | `AndroidManifest.xml`, `res/xml/filtro_usb_anagram.xml` |
| U9 | iPhone/iPad: o código CoreMIDI já está no app iOS; um modo "só MIDI" (trocar slot/cena sem HID) fica para depois | aberta | 2026-11-05 | `ios/Runner/AppDelegate.swift` |

## Rodada 3 (revisão)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| R1 | Preset importado (sem original) ganha uuid novo ao salvar, e Salvar pergunta antes de gravar sobre slot ocupado | decidida | 2026-11-05 | `ControladorEditor.salvar/_gravar`, `executarSalvar` |
| R2 | Preset novo nasce com `bindings: {}`, como os arquivos reais | decidida | 2026-11-05 | `DocumentoPreset.vazio` |
| R3 | Abrir slot: resultado de uma abertura anterior é descartado se outro slot já foi escolhido; SALVAR desabilitado enquanto carrega | decidida | 2026-11-05 | `abrirSlot`, `AcoesPreset` |
| R4 | O uuid lido tem de bater com o `id` que a lista anunciou para o slot; divergência recusa o preset e relê a lista | decidida | 2026-11-05 | `_bateComALista` |
| R5 | Depois de Salvar como em outro slot, Program Change para o destino (a pedaleira fica onde o preset foi gravado) | decidida | 2026-11-05 | `_gravar` |
| R6 | Perder a conexão zera modo destino e "slot na pedaleira"; o aviso de desconexão aparece uma vez (tela de conectar) | decidida | 2026-11-05 | `_aoMudarConexao` |
| R7 | Cancelar durante a abertura do MIDI: a tentativa é rechecada e a porta MIDI aberta tarde é fechada | decidida | 2026-11-05 | `ControladorConexao._abrirMidi` |
| R8 | Segurar o knob volta ao padrão com snackbar DESFAZER (também ao vivo) | decidida | 2026-11-05 | `BotaoGiratorio` |
| R9 | Lista ao lado do editor a partir de 780 px (iPad retrato); editor estreito ao lado da lista usa grade e parâmetros do celular abaixo de 700 px | decidida | 2026-11-05 | `Quebras`, `TelaEditor` |
| R10 | Lista: "ORIGEM" e ícone de gravar no modo destino; ícone verde no slot em que a pedaleira está (com MIDI) | decidida | 2026-11-05 | `ListaPresets` |
| D4 | Se no aparelho o Program Change cair um slot depois (01A → 01B), o firmware é 0-based: trocar para `slot.numero - 1` em `lib/nucleo/midi/saida_midi.dart` | **aberta — confirmar na bancada** | 2026-11-05 | `MensagensMidi.trocaDePrograma` |

## Tablet / iPad (rodada 4)

| # | Decisão | Estado | Data | Onde |
|---|---|---|---|---|
| T7 | Parâmetros **sem páginas** também no amplo: todos à vista, em fileiras. No amplo o knob encolhe de 104 até 84 px para não deixar um parâmetro sozinho na segunda fileira. Substitui a paginação de D2: a tela já rola, e a página só escondia parâmetro (no iPad 11" o 6º do Microtubes X ficava atrás da seta) | decidida | 2026-11-05 | `PainelParametros._tamanhoQueCabe` |
| T8 | Grade 2×12 **sem rolagem lateral** do iPad mini em paisagem para cima: casa mínima cai de 76 para 56 px (ainda acima do alvo de 48), e abaixo de 76 px a casa mostra a abreviação (`casaRotuloCompleto`). Antes, as casas 10–12 ficavam fora da tela sem aviso | decidida | 2026-11-05 | `Medidas.casaMinima`, `GradeBlocos` |
| T9 | Lista de presets com 256 px abaixo de 1300 px de largura (iPad mini/11"); 304 px no iPad 13" e no desktop | decidida | 2026-11-05 | `Quebras.listaLarga`, `TelaEditor` |
| T10 | Grade compacta com tantas casas por fileira quanto cabem sem passar de 112 px (mínimo 4, o celular continua igual): o iPad em retrato mostra 5 a 6 blocos por fileira | decidida | 2026-11-05 | `GradeCompacta.casasPorFileira` |
| T11 | Faixa do preset: abaixo de 880 px de largura, os botões de salvar descem para baixo da fita, em vez de espremer a fita até estourar (estourava 56 px no iPad mini em paisagem) | decidida | 2026-11-05 | `Medidas.larguraFaixaEmLinha`, `FaixaPreset` |

