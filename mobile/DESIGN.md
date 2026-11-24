---
name: Anagram App
description: Editor de presets da Anagram com cara de case de estrada, em tema escuro (ABS preto) e claro (alumínio).
colors:
  fundo-case: "#131416"
  painel: "#1B1C1F"
  painel-elevado: "#24262A"
  filete: "#34373C"
  aluminio: "#8E949B"
  aluminio-claro: "#C9CDD2"
  texto: "#EDEDEB"
  texto-secundario: "#A7ACB2"
  fita-gaffer: "#E8E1CD"
  fita-gaffer-sombra: "#CFC6AE"
  tinta-marcador: "#17171A"
  tally: "#F0B429"
  sobre-tally: "#1A1405"
  fita-alerta: "#C2361F"
  sobre-alerta: "#FFFFFF"
  led-ligado: "#41D68A"
  led-demonstracao: "#5AA9F0"
  led-desligado: "#6B7077"
  erro: "#FF7A66"
  familia-drive: "#E8772E"
  familia-compressor: "#B5D334"
  familia-equalizador: "#3BB7D6"
  familia-filtro: "#9B78E3"
  familia-modulacao: "#34C3A0"
  familia-delay: "#5585EE"
  familia-reverb: "#D46BB3"
  familia-amplificador: "#E0563F"
  familia-gabinete: "#B9A37C"
  familia-utilitario: "#8D949C"
typography:
  display:
    fontFamily: "SairaStencil"
    fontSize: "40px"
    lineHeight: 1
  headline:
    fontFamily: "PermanentMarker"
    fontSize: "26px"
    lineHeight: 1.1
  nome-preset:
    fontFamily: "BarlowCondensed"
    fontSize: "24px"
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: "0.3px"
  headline-valor:
    fontFamily: "Barlow"
    fontSize: "26px"
    fontWeight: 600
    fontFeature: "tnum"
  title-large:
    fontFamily: "Barlow"
    fontSize: "20px"
    fontWeight: 600
  title-medium:
    fontFamily: "Barlow"
    fontSize: "17px"
    fontWeight: 600
  title-small:
    fontFamily: "BarlowCondensed"
    fontSize: "15px"
    fontWeight: 600
    letterSpacing: "0.6px"
  body-large:
    fontFamily: "Barlow"
    fontSize: "16px"
    lineHeight: 1.4
  body-medium:
    fontFamily: "Barlow"
    fontSize: "15px"
    lineHeight: 1.4
  body-small:
    fontFamily: "Barlow"
    fontSize: "13px"
    lineHeight: 1.35
  label-large:
    fontFamily: "BarlowCondensed"
    fontSize: "17px"
    fontWeight: 700
    letterSpacing: "0.8px"
  label-medium:
    fontFamily: "BarlowCondensed"
    fontSize: "14px"
    fontWeight: 600
    letterSpacing: "0.7px"
  label-small:
    fontFamily: "BarlowCondensed"
    fontSize: "12px"
    fontWeight: 600
    letterSpacing: "0.8px"
  item-menu:
    fontFamily: "Barlow"
    fontSize: "15px"
    fontWeight: 500
    lineHeight: 1.25
    letterSpacing: "0.1px"
  detalhe-menu:
    fontFamily: "Barlow"
    fontSize: "13px"
    fontWeight: 400
rounded:
  canto: "3px"
  controle: "6px"
  painel: "8px"
spacing:
  xxs: "2px"
  xs: "4px"
  s: "8px"
  m: "12px"
  l: "16px"
  xl: "24px"
  xxl: "32px"
  xxxl: "48px"
components:
  botao-primario:
    backgroundColor: "{colors.tally}"
    textColor: "{colors.sobre-tally}"
    typography: "{typography.label-large}"
    rounded: "{rounded.controle}"
    padding: "0 16px"
    height: "48px"
  botao-contorno:
    backgroundColor: "transparent"
    textColor: "{colors.texto}"
    typography: "{typography.label-large}"
    rounded: "{rounded.controle}"
    height: "48px"
  botao-cena:
    backgroundColor: "{colors.painel-elevado}"
    textColor: "{colors.texto}"
    typography: "{typography.label-large}"
    rounded: "{rounded.controle}"
    padding: "4px 12px"
    height: "56px"
  botao-cena-mouse:
    height: "40px"
  botao-cena-ativa:
    backgroundColor: "{colors.tally}"
    textColor: "{colors.sobre-tally}"
  fita-preset:
    backgroundColor: "{colors.fita-gaffer}"
    textColor: "{colors.tinta-marcador}"
    typography: "{typography.nome-preset}"
    padding: "8px 16px"
    height: "56px"
  fita-preset-mouse:
    padding: "4px 16px"
    height: "40px"
  selo-nao-salvo:
    backgroundColor: "{colors.fita-alerta}"
    textColor: "{colors.sobre-alerta}"
    typography: "{typography.label-medium}"
    padding: "2px 8px"
  moldura-case:
    backgroundColor: "{colors.painel}"
    rounded: "{rounded.canto}"
    padding: "16px"
  barra-conexao:
    backgroundColor: "{colors.painel}"
    textColor: "{colors.texto}"
    typography: "{typography.title-small}"
    padding: "0 16px"
    height: "64px"
  barra-conexao-mouse:
    height: "48px"
  linha-preset:
    backgroundColor: "transparent"
    textColor: "{colors.texto}"
    typography: "{typography.body-large}"
    padding: "0 12px"
    height: "48px"
  linha-preset-ativa:
    backgroundColor: "{colors.painel-elevado}"
    textColor: "{colors.tally}"
  dialogo:
    backgroundColor: "{colors.painel-elevado}"
    textColor: "{colors.texto}"
    rounded: "{rounded.painel}"
    width: "440px"
  item-menu:
    backgroundColor: "{colors.painel-elevado}"
    textColor: "{colors.texto}"
    typography: "{typography.item-menu}"
    padding: "0 12px"
    height: "40px"
  item-menu-toque:
    height: "48px"
  item-menu-destrutivo:
    textColor: "{colors.erro}"
  aviso-snackbar:
    backgroundColor: "{colors.fita-gaffer}"
    textColor: "{colors.tinta-marcador}"
---

# Design System: Anagram App

## Overview

**Creative North Star: "O Case de Estrada"**

O app é o flight case da pedaleira, não um site de configurações. Tudo é desenhado como equipamento de turnê visto no chão do palco: casco escuro, quinas de alumínio, nomes escritos a marcador em fita gaffer, numeração em estêncil e fitas de cor de roadie que dizem a família de cada bloco. A densidade é de ferramenta de bancada (lista de 126 slots, grade de 2 × 12 casas, knobs grandes), mas tudo legível de longe e com alvo de toque de no mínimo 48dp.

Dois temas com o mesmo desenho: o escuro (ABS preto, o padrão de palco) e o claro (o mesmo case em alumínio, à luz do dia), escolhidos em Configurações › Aparência (Do sistema, Escuro, Claro; padrão Do sistema). A cor é rara e funcional: o âmbar "tally" marca o que está ativo/selecionado, a fita gaffer marca o nome do preset, o vermelho de alerta marca o que ainda não foi gravado, e as cores de família só aparecem onde há bloco. Recusa explícita do contrato: a tela de cards cinza com sliders genéricos.

Divergência entre direção e construído: o contrato pede "ABS preto texturizado"; o construído é um preto chapado (`fundo-case`), sem textura. O registro segue o construído. A linha do sinal com dobras de 45° (estilo metrô) só aparece quando o preset tem a segunda pista (ver captura `desktop-4-paralelo`).

**Key Characteristics:**
- Casco escuro em três degraus tonais, sem sombra.
- Filetes de 1px de alumínio e cantoneiras de 14px nas quinas dos painéis.
- Fita gaffer creme com letra de marcador apenas no nome do preset.
- Slot do preset em estêncil grande (40px), legível de longe.
- Fita de 4px na cor da família sob cada bloco; o arco do knob herda a mesma cor.
- Âmbar tally como única cor de ação/seleção.

## Colors

Casco preto neutro com alumínio frio, um único acento âmbar de ação e uma família de dez cores de roadie restrita aos blocos.

### Primary
- **Âmbar Tally** (`tally`): botão primário (SALVAR com edição, CONECTAR), cena ativa, contorno de 2px da casa selecionada, filete esquerdo e rótulo do slot aberto na lista, anel de foco do knob, "AO VIVO" ligado e o interruptor. Texto sobre ele é sempre `sobre-tally`.

### Secondary
- **Fita Gaffer** (`fita-gaffer`, borda inferior `fita-gaffer-sombra`): o fundo do nome do preset e do snackbar; também o ponteiro do knob. Nunca em chip, segmento ou seleção: o tema deixa `secondary` em alumínio e a seleção de chip/segmento em `painel-elevado` com contorno âmbar. Texto sobre ela é sempre `tinta-marcador`.
- **Fita de Alerta** (`fita-alerta`): só o selo "NÃO SALVO", com texto branco.

### Tertiary
- **Fitas de Família** (`familia-*`): dez cores, uma por família de bloco (drive, compressor, equalizador, filtro, modulação, delay, reverb, amplificador, gabinete, utilitário). Aparecem na fita de 4px sob a casa, no arco do knob, no corpo da arte própria de bloco e na opção marcada de parâmetro de escolha (com texto `tinta-marcador`). Família de cor neutra (utilitário, gabinete) não preenche a opção marcada, que pareceria desabilitada: ela fica em `painel-elevado` com contorno `tally` de 2px e um check (DECISOES UI1).
- **LEDs de conexão** (`led-ligado`, `led-demonstracao`, `led-desligado`, mais `tally` em "conectando" e `erro` em falha): ponto de 10px na barra de conexão.

### Neutral
- **Preto de Case** (`fundo-case`): fundo do scaffold e miolo da casa vazia.
- **Painel** (`painel`): molduras, barra de conexão, superfície padrão.
- **Painel Elevado** (`painel-elevado`): casa selecionada, linha ativa da lista, cenas inativas, corpo do knob, diálogos.
- **Filete** (`filete`): bordas de 1px, divisores, trilho do knob, aro da casa vazia.
- **Alumínio** (`aluminio`): cantoneiras, linha do sinal, contorno do botão secundário, aro do knob.
- **Alumínio Claro** (`aluminio-claro`): rótulo do slot nas linhas inativas da lista.
- **Texto** / **Texto Secundário** (`texto`, `texto-secundario`): texto principal e de apoio.
- **Erro** (`erro`): mensagem de falha de conexão.

### Named Rules
**The One Tally Rule.** Âmbar é seleção e ação, nada mais. Não use âmbar como decoração nem como cor de família.

**The Family Stripe Rule.** Cor de família só existe onde há um bloco (fita, arco, arte, opção marcada). Superfícies, textos e botões de ação nunca usam cor de família.

## Typography

**Display Font:** Saira Stencil (só números de slot e de cena)
**Headline Font:** Permanent Marker (só o nome do preset na fita gaffer)
**Body Font:** Barlow
**Label Font:** Barlow Condensed

**Character:** Barlow dá a leitura limpa de manual técnico; Barlow Condensed faz os rótulos de painel em caixa alta; estêncil e marcador são as duas "vozes de estrada", cada uma presa a um único papel.

### Hierarchy
- **Display** (Saira Stencil, 40px no toque e 32px com mouse, altura 1): slot do preset aberto ("02A"). Nos botões de cena o mesmo estêncil aparece no tamanho de `title-large` (20px).
- **Headline** (Permanent Marker, 26px, 1.1): só "Anagram App" na fita da tela de conectar.
- **Nome do Preset** (Barlow Condensed 600, 24px no toque e 22px com mouse, 1.15, +0.3px; `Tipos.nomePreset`): o nome sobre a fita gaffer, em `tinta-marcador`. Na lista, o nome vai em Body Large com peso 500 (`Tipos.nomeNaLista`).
- **Headline Valor** (Barlow 600, 26px, figuras tabulares): valores numéricos grandes.
- **Title Large / Medium** (Barlow 600, 20px / 17px): nome do bloco no painel, título de diálogo; valor sob o knob (17px, tabular).
- **Title Small** (Barlow Condensed 600, 15px, +0.6px): estado da conexão, rótulo do slot na lista.
- **Body** (Barlow 16 / 15 / 13px, 1.4–1.35): nome do preset na lista (16), instrução (15), "vazio" e metadados do bloco (13).
- **Label Large** (Barlow Condensed 700, 17px, +0.8px, caixa alta): texto de botão e de cena, "AO VIVO".
- **Label Medium** (Barlow Condensed 600, 14px, +0.7px): nome de parâmetro em caixa alta acima do knob, nome curto na casa, selo "NÃO SALVO", latência.
- **Item de Menu** (Barlow 500, 15px, 1.25, +0.1px, caixa normal; `Tipos.itemMenu`): todo item de menu, do botão direito ao ⋮ e aos seletores. O que fica à direita do item vai em **Detalhe de Menu** (Barlow 400, 13px, `texto-secundario`; `Tipos.detalheMenu`). Menu não usa Label Large: condensada em negrito é voz de botão (DECISOES UI12).

### Named Rules
**The Hand-Lettered Tape Rule.** Marcador só existe em cima de fita gaffer, e só no nome FIXO do app (tela de conectar). O nome do preset, que é dado do usuário, vai na fita em `nome-preset` (Barlow Condensed 600), a voz de rótulo do case, na caixa em que foi escrito (DECISOES BC2).

**The Stencil Is A Number Rule.** Estêncil é para identificador numérico (slot, cena), nunca para frase.

**The Tabular Value Rule.** Todo valor de parâmetro usa figuras tabulares, para o número não dançar enquanto o knob gira.

## Layout

Grade de espaçamento de base 4 (2, 4, 8, 12, 16, 24, 32, 48px). O padrão interno de moldura é 16px; a grade de blocos usa 12px.

Duas composições, decididas por largura ≥ 780 e altura ≥ 600 (o iPad em retrato já entra na ampla):
- **Ampla** (tablet paisagem, desktop): barra de conexão de 64px no topo; lista de presets fixa à esquerda (304px a partir de 1300px de tela, 256px abaixo disso; linhas de 48px agrupadas por banco com divisor de filete); à direita, em coluna: faixa do preset (slot + fita + ações alinhadas à direita; abaixo de 880px de editor as ações descem para baixo da fita), cenas 1–3 em três colunas iguais, moldura da grade, moldura dos parâmetros com todos os knobs à vista, sem páginas, de 104px (encolhem até 84px para caber numa fileira). Editor ao lado da lista com menos de 700px usa a grade e os parâmetros da compacta.
- **Compacta** (celular retrato): mesma ordem empilhada; a fita do nome quebra em até 2 linhas, ações vão para a linha de baixo alinhadas à esquerda, a lista de presets abre ao tocar no slot, knob de 84px e a grade mostra só as casas ocupadas, em fileiras de 4 no celular e até 6 no iPad em retrato (casa de até 112px).

Casas da grade entre 56 e 112px de largura, para as 12 caberem sem rolagem lateral do iPad mini em paisagem para cima; o nome do bloco vai inteiro em até 2 linhas de 14px e, se alguma palavra não couber na largura da casa, entra a abreviação da pedaleira (nunca se parte uma palavra); a caixa do pedal ocupa 86% da casa. A grade ampla reserva 28px antes da casa 1 e depois da 12 para os jaques IN e OUT. Diálogos com 440px; telas vazias (conectar) limitadas a 520px e centralizadas.

## Elevation & Depth

Plano, sem sombra. A profundidade é tonal (preto de case → painel → painel elevado) e desenhada por filetes de 1px e cantoneiras de alumínio. Seleção é contorno de 2px em âmbar, não elevação. A única "quina" de profundidade é a borda inferior de 2px da fita gaffer em `fita-gaffer-sombra`, que dá espessura de fita colada.

### Named Rules
**The No-Shadow Rule.** Nenhuma sombra projetada. Separar camadas por tom e filete.

## Shapes

Cantos quase retos: 3px em molduras de case, 6px em controles (botões, cenas, casa selecionada), 8px em diálogos. A fita gaffer e o selo "NÃO SALVO" são retângulos sem raio. Cantoneiras de alumínio: um L de 14px em traço de 2px em cada quina da moldura. Casa vazia: círculo com aro de filete de 2px, como um jack sem cabo. Knob: arco de 270° com 6px de espessura e ponta arredondada. Linha do sinal: traço de 2px em alumínio, pista 1 reta de ponta a ponta, pista 2 com dobras exatas de 45°.

## Components

### Buttons
Táteis e diretos, sempre ≥ 48dp, texto em Barlow Condensed caixa alta.
- **Shape:** cantos de controle (6px).
- **Primário:** âmbar tally, texto `sobre-tally`, 16px de lateral. Ex.: SALVAR (só com edição não salva, junto do selo NÃO SALVO; sem edição ele é contorno), CONECTAR.
- **Contorno:** transparente, borda de 1px `aluminio`, texto `texto`. Ex.: SALVAR sem edição, SALVAR COMO, DESCARTAR, ABRIR DEMONSTRAÇÃO, DISPARAR da bateria, e LIGADO/DESLIGADO do bloco, que é estado e não ação: contorno com LED de 10px em `led-ligado` (ou `led-desligado`) no lugar do ícone (DECISOES UI7).
- **Foco:** contorno sólido de 2px em `tally` (acima de 3:1 sobre o case e os painéis); em botão já preenchido, o anel é da cor do texto dele (`sobre-tally` no âmbar). O realce âmbar a 24% fica só nas superfícies de toque sem contorno (linhas da lista) (DECISOES UI3).
- **Descartar:** no computador fica à vista, desabilitado sem edição; no celular SALVAR, SALVAR COMO e um menu ⋯ (Descartar, Importar, Exportar) cabem numa linha.
- **Enquanto o Salvar como espera o destino**, os botões de cima ficam desabilitados: a ação está na lista. Na lista, o slot vazio mostra o ícone de gravar (`aluminio`); o ocupado, o ícone de substituir em `aluminio-claro` e, no lugar do nome, "substitui <nome>" em body-small (DECISOES UI8).
- **Diálogo de confirmação:** cancelar em texto neutro (`texto`) à esquerda; confirmar à direita, sempre preenchido em `fita-alerta` com texto `sobre-alerta`, porque todo confirmar ali apaga ou sobrescreve algo.
- **Ícone:** Material Icons via IconButton com tooltip (desconectar, créditos, copiar bloco). O menu do arquivo do preset tem ícone próprio (pasta de arquivo no computador, ⋯ no celular), para não se confundir com o ⋮ do bloco. Todo item de menu (preset, bloco, arquivo, atribuir) leva ícone à esquerda em `aluminio-claro`; "Limpar preset…" fica sozinho depois de um divisor, ícone e texto em `erro`. Cancelar de diálogo é sempre texto neutro (`texto`), nunca âmbar (DECISOES UI6).

### Menus
Menu de contexto (botão direito, toque longo, ⋮), menu de arquivo, idioma, versão nova e seletor de opção: um tipo só, vindo do tema (`popupMenuTheme`), lido como o menu do sistema e não como um painel de botões.
- **Texto:** `item-menu` (Barlow 500, 15px, caixa normal) em `texto`; desabilitado a 38%. Referência: Windows 11 usa Segoe UI 14px regular, o macOS SF 13px regular; 15px compensa a leitura a um metro e o tema escuro, e o 500 é um passo de peso sobre o corpo, não o 700 de botão.
- **Ícone:** 18px à esquerda, em `aluminio-claro`, a 12px do texto (o Windows usa 16px ao lado de 14px).
- **Altura:** 40px com mouse (Windows, macOS, Linux); 48dp no toque (Android, iOS). Exceção consciente à regra de 48dp: no desktop o ponteiro é preciso e os menus do sistema ficam entre 22 e 32px; 40px é o meio-termo que mantém o menu compacto sem virar alvo miúdo (DECISOES UI12). A lista aberta do seletor de área fica em 48px: o DropdownButton não aceita item abaixo disso; só o tipo muda.
- **Detalhe à direita** (o que cada controle já move): `detalhe-menu`, alinhado à direita, como atalho de teclado.
- **Perigoso:** "Limpar preset…" sozinho depois de um divisor, ícone e texto em `erro`.
- **Escolha única** (opção de parâmetro, tipo de drive): check de 18px em `tally` na coluna do ícone; as outras opções deixam a coluna vazia, alinhadas.
- **Divisores:** filete de 1px entre grupos (ações, mover, footswitches, remover).

### Cenas
Três botões de largura igual, altura 56px no toque e 40px com mouse (`MedidasDoTopo`). Inativo: `painel-elevado` com borda de filete. Ativo: preenchido em âmbar. Número em estêncil + nome em caixa alta; cena sem nome mostra só o número e "CENA" (nunca "1 CENA 1").

### Chave "Controlar"
Sob as cenas (e sob as pílulas do modo, quando elas descem): rótulo CONTROLAR em label-small `texto-secundario` e duas opções, TODAS AS CENAS e SÓ A CENA ATIVA, desenhadas como os botões de cena (`BotaoTally`: escolhida em âmbar, a outra em `painel-elevado` com filete), em label-medium e 48dp de alto. Com 480px ou mais, rótulo e opções numa linha; abaixo disso o rótulo sobe e as opções dividem a largura. Cada opção tem tooltip curto dizendo o que muda. Espelha o botão do modo Scene da pedaleira (DECISOES CE1).

### Modo dos footswitches
Na linha das cenas, à direita dos três botões: PRESET / STOMP / SCENE em pílulas pequenas lado a lado (desenho de 26px de altura, raio inteiro, label-small; alvo de toque de 48dp por pílula — empilhadas, três alvos de 48dp não caberiam na altura de 56px de uma cena). Abaixo de 560px de largura na linha (celular, janela estreita), as pílulas descem para uma linha fina logo abaixo das cenas, alinhadas à direita.

**Exceção intencional à regra do âmbar** (pedido do dono, DECISOES FM8): a pílula do modo atual acende na cor do LED da própria Anagram — `modo-preset` branco (#FFFFFF), `modo-stomp` roxo (#9B6CF0), `modo-scene` azul-claro (#6EC6F5) —, com texto `sobre-modo` (#121014), acima de 4,5:1 nas três (teste). As apagadas têm só o contorno de filete e texto `texto-secundario`. Modo desconhecido ou não informado: nenhuma acesa, todas desabilitadas, e o tooltip diz por quê; com modo conhecido, o tooltip dá a dica do Stomp.

Movimento: ao trocar, a cor acende na nova e apaga na antiga (220ms, ease-out); quando a releitura confirma, a nova dá um pulso de brilho na própria cor (420ms); recusa volta ao valor real com um tremor horizontal de 3px que amortece, sem cor, e a frase de erro sob as cenas. Com "reduzir movimento" do sistema, a troca é seca e não há pulso nem tremor. Nas Configurações o modo é um cartão "Footswitches" com três botões iguais aos de cena.

### Fita do Preset (assinatura)
Slot em estêncil de 40px à esquerda (no celular, com "PRESETS ▾" embaixo: tocar abre a lista), seguido da fita gaffer creme com o nome a marcador, um lápis discreto em alumínio (tocar a fita renomeia) e, se houver edição não salva, o selo vermelho "NÃO SALVO" no fim da fita. Os avisos sob a fita (ao vivo desligado, audição sem USB MIDI) usam `erro`, não âmbar. A tela de conectar abre com a mesma assinatura: "01A" em estêncil e a fita com "Anagram App" a marcador; ao conectar ou abrir a demonstração, o giro e a frase ("Conectando (USB)…", "Abrindo a demonstração…") ficam dentro do botão tocado, com a cor mantida, e o outro botão desabilitado (DECISOES UI9).

### Moldura de Case
Painel `painel` com filete de 1px, canto de 3px e cantoneiras de alumínio pintadas por cima. Envolve a grade de blocos e o painel de parâmetros.

### Cadeia (fluxo do sinal)
Lida como um pedalboard: o fio (`aluminio`, 2px) sai do jaque IN à esquerda, passa pelos pedais na ordem e chega ao jaque OUT à direita; depois do último pedal o fio segue tracejado em `filete` até o OUT. Caixas de pedal e encaixes vazios são opacos e cobrem o fio. A linha 2 só tem fio quando há split: desce em 45° no split e sobe no merge (sem merge, no OUT). No celular as casas vão na posição real (buracos com encaixe), e o fio liga as caixas de cada fileira.

### Casa de Bloco
Pedal numa caixa fixa (`painel`, filete de 1px, canto de 6px) para as fotos de proporções diferentes ficarem alinhadas; fita de família de 4px; nome em label-medium (14px). Casa vazia: encaixe tracejado do tamanho da caixa com "+" a 32% dela. Selecionada: fundo `painel-elevado` + contorno âmbar de 2px. Desligada: a imagem de bypass da pedaleira (ou a arte a 38% em cinza) com o mesmo selo "OFF" por cima, e nome em `texto-secundario`. Transição de 150ms. Toque seleciona na hora; o segundo toque dentro do prazo do duplo liga/desliga; toque longo/botão direito abre menu. No painel do bloco, toque duplo no pedal também liga/desliga, e "só na cena N" fica em `aluminio-claro`. As dicas de gesto do painel ficam atrás de um "?" (48dp, `aluminio-claro`) ao lado do nome do bloco; "Controles da pedaleira" recolhe pelo título e só abre sozinho com controle atribuído (DECISOES UI2).

### Knob
Nome do parâmetro em caixa alta acima, valor tabular abaixo. Trilho em filete, arco na cor da família, corpo `painel-elevado` com aro de alumínio (âmbar 2px quando focado), ponteiro em fita gaffer. Arraste vertical/horizontal, rodinha, setas (Shift = passo de 10%), toque duplo volta ao padrão. Parâmetros com poucas opções viram coluna de botões: marcado em cor da família (ou, em família neutra, `painel-elevado` + contorno âmbar + check), demais em contorno.

### Navigation
- **Barra de conexão:** 64px no toque, 48px com mouse (ícones e interruptor sem a margem de toque, 40px), `painel`, filete inferior. LED de 10px + estado em title-small, "AO VIVO" + interruptor âmbar, latência "ida e volta N ms" (só na ampla), ícones de desconectar e créditos. Com versão nova publicada, aviso discreto: ícone em `aluminio-claro` + "vX.Y.Z disponível" em label-medium + BAIXAR (texto em âmbar, é ação) + fechar ("Lembrar depois"); abaixo de 1200px de janela, só o ícone, com as duas ações num menu.
- **Lista de presets:** linhas de 48px, slot em title-small (`aluminio-claro`, âmbar quando aberto), nome em body-large ou "vazio" em body-small; linha aberta ganha `painel-elevado` e filete esquerdo âmbar de 2px. A marca "a pedaleira está neste slot" usa a cor do LED da barra (azul na demonstração) e não aparece em slot vazio.

### Avisos
Snackbar flutuante em fita gaffer com texto `tinta-marcador`, 15px. Diálogo em `painel-elevado`, canto 8px, ações separadas nas pontas.

## Do's and Don'ts

### Do:
- **Do** usar só tokens de `lib/apresentacao/tema/tokens.dart` e cores por papel de `paleta.dart` (`context.cores.<papel>`); nenhuma cor ou medida fora dali.
- **Do** manter alvo mínimo de 48dp em todo controle tocável; com mouse, o topo do editor usa alvos de 32 a 40px (`MedidasDoTopo.mouse`, DECISOES BC1).
- **Do** separar camadas por tom (`fundo-case` → `painel` → `painel-elevado`) e filete de 1px.
- **Do** marcar seleção com contorno âmbar de 2px ou preenchimento âmbar, nunca com sombra.
- **Do** colocar a fita de família de 4px sob todo bloco e herdar a mesma cor no arco do knob.
- **Do** usar figuras tabulares em todo valor numérico que muda.
- **Do** deixar "salvar" como ato separado: edição ao vivo nunca grava sozinha, e o selo "NÃO SALVO" fica visível enquanto houver diferença.

### Don't:
- **Don't** usar Permanent Marker fora da fita gaffer, nem fita gaffer sem nome escrito.
- **Don't** usar âmbar como cor de família, decoração ou aviso; a família compressor é verde-limão justamente para não competir com o âmbar.
- **Don't** pintar ação destrutiva em cor cheia na barra; descartar é contorno. Só o confirmar do diálogo destrutivo é cheio, em `fita-alerta`.
- **Don't** usar sombra projetada nem cantos acima de 8px.
- **Don't** usar logo ou marca da Darkglass fora da arte dos blocos (ícone, nome, telas).
- **Don't** criar tela de cards cinza com sliders genéricos; parâmetro contínuo é knob.

<!-- tema-claro-topo: bloco mantido junto com docs/DECISOES.md (TC1 a TC6, BC1 a BC3) -->
## Tema claro e topo compacto (2026-11-22)

Este bloco vale por cima de qualquer frase anterior deste arquivo que diga o contrário. Origem: dois relatos de
usuários (Reddit: letra feia no nome do preset e barra de cima grande; fórum: só existe o modo escuro).

### Cores por papel, dois jogos
As cores vivem em `lib/apresentacao/tema/paleta.dart` (`Paleta.escura`, `Paleta.clara`, uma `ThemeExtension`
lida por `context.cores`). Os hex do frontmatter são do escuro. O claro, papel a papel:

| Papel | Escuro | Claro | Nota |
|---|---|---|---|
| fundo-case | #131416 | #DFE1E3 | degrau mais fundo |
| painel | #1B1C1F | #ECEEF0 | |
| painel-elevado | #24262A | #F8F9FA | o elevado é o mais claro nos dois |
| filete | #34373C | #C5C9CE | |
| aluminio | #8E949B | #6B7178 | contorno de botão, cantoneira, fio |
| aluminio-claro | #C9CDD2 | #454B52 | vira tinta escura no claro |
| texto / texto-secundario | #EDEDEB / #A7ACB2 | #16181B / #50565D | |
| fita-gaffer / sombra | #E8E1CD / #CFC6AE | #E8E1CD / #B9AE8E | a fita é a mesma; a borda escurece |
| tinta-marcador | #17171A | #17171A | |
| tally (preenchimento) / sobre-tally | #F0B429 / #1A1405 | igual | botão primário, cena ativa, interruptor |
| tally-tinta (novo) | #F0B429 | #865600 | âmbar como TEXTO, contorno de seleção e anel de foco |
| fita-alerta / sobre-alerta | #C2361F / #FFFFFF | igual | |
| led-ligado | #41D68A | #15703F | |
| led-demonstracao | #5AA9F0 | #1F69AE | |
| led-desligado | #6B7077 | #868B92 | |
| erro | #FF7A66 | #B3261E | |
| modo-preset / stomp / scene | #FFFFFF / #9B6CF0 / #6EC6F5 | #2B2E33 / #6B46D6 / #16679F | o LED branco no alumínio parecia apagado: Preset aceso vira grafite |
| sobre-modo | #121014 | #FFFFFF | |
| corpo-knob (novo) | #24262A | #2B2E33 | knob e cursor do fader pretos no claro, ponteiro creme |
| alca-grafico (novo) | #E8E1CD | #2B2E33 | pontos arrastáveis do EQ |
| miolo-alca (novo) | #17171A | #F8F9FA | miolo do puxador da faixa de frequência |
| familia-* | (frontmatter) | drive #D36117 · compressor #778B1E · equalizador #238EA8 · filtro #936DE1 · modulação #279278 · delay #4B7EED · reverb #CE55A8 · amplificador #E0543C · gabinete #987F51 · utilitário #7B838D | mesma matiz e saturação, luminância baixada |
| sinal-split / sinal-merge | #F5E05A / #8FEADB | #958209 / #1C937F | |

**Regra de derivação do claro.** Cor de destaque (família, banda do multibanda, fio, linhas Threshold/Level, mixer,
modo do Global EQ) mantém matiz e saturação HSL e só baixa a luminância relativa para ~0,225: assim passa de 3:1
sobre o painel claro e ainda leva `tinta-marcador` por cima no AA (a opção marcada). O texto do modo do EQ desce
mais (~0,13, AA como texto). Medido com a luminância da cor de verdade em `test/tema/contraste_tema_test.dart`.

**The Ink Amber Rule.** Âmbar de preenchimento (`tally`) e âmbar de tinta (`tally-tinta`) são papéis diferentes:
o primeiro sempre tem `sobre-tally` em cima; o segundo é a cor do texto "AO VIVO", do slot aberto, do "ORIGEM",
do contorno da casa selecionada, do anel de foco e do texto de TextButton. No escuro são o mesmo hex.

As fotos dos pedais não mudam com o tema.

### Topo do editor por ponteiro (`MedidasDoTopo`)
| Peça | Toque (celular, tablet) | Mouse (Windows, macOS, Linux) |
|---|---|---|
| Barra de conexão | 64 | 48 (ícones e interruptor de 40, sem margem de toque) |
| Fita do preset | 56 (respiro 8) | 40 (respiro 4) |
| SALVAR / SALVAR COMO / DESCARTAR / menu | 48 | 40 |
| Cenas | 56 | 40 |
| Alvo da pílula do modo | 48 | 32 (desenho de 26) |
| Estêncil do slot / nome do preset | 40 / 24 | 32 / 22 |
| Espaço fita → cenas | 16 | 8 |

A tela de conectar mantém a fita no tamanho cheio: é a vitrine, não o topo do editor.
<!-- /tema-claro-topo -->

<!-- produto-arte-acoes: bloco mantido junto com PRODUCT.md e docs/DECISOES.md (A9 a A12, U13 a U15) -->
## Arte dos blocos, nomes de ação e textos (2026-11-21)

Este bloco vale por cima de qualquer frase anterior deste arquivo que diga o contrário.

- **Arte dos blocos:** a mesma imagem que a pedaleira mostra na tela (Darkglass Electronics), ligada e
  desligada, é a única versão publicada. A arte própria por família continua como reserva para os blocos
  sem imagem na pedaleira e para o app rodando do código-fonte sem a arte.
- **Nomes de ação** (os mesmos em todas as telas e tamanhos):
  - **SALVAR** grava no slot aberto; **SALVAR COMO…** escolhe o destino.
  - **DESCARTAR** desfaz as edições não salvas. A pergunta de confirmação diz "Descartar edições?" e o
    botão de confirmar diz DESCARTAR: não existe "largar" na interface.
- **Textos que acompanham o aparelho:** com mouse, "clique" e "botão direito"; no toque, "toque" e
  "segure". Copiar um bloco é pelo ícone de copiar do painel do bloco; colar é pelo menu da casa vazia.
- **Sem jargão técnico na tela:** nada de nome de biblioteca ("hidapi", "IOKit") nem de ação do protocolo
  ("edit_anagram_presets"). O detalhe vai para o log; a tela diz o que aconteceu e o que fazer.
- **Avisos:** erro em `erro` com ícone de alerta, logo acima das ações; informação (a pedaleira saiu) em
  texto normal com ícone de informação.
- **Área de presets:** o campo mostra só o nome que a pessoa deu; a área ativa na pedaleira é marcada ao
  lado com o LED `led-ligado` e o rótulo ATIVA, nunca colada no nome.
- **Versão do app:** na tela Sobre, com "· arte da pedaleira" quando o build traz a arte, e também na barra de cima a partir de 880px de janela, ao lado do estado e do firmware (pedido do dono depois desta regra; DECISOES UI9).
- **Idioma:** pílulas no topo da tela Sobre e um menu compacto (globo + idioma atual) na tela de conectar.
- **Sem USB na plataforma** (iPhone/iPad, navegador sem WebHID): título "Modo demonstração", uma frase,
  ABRIR DEMONSTRAÇÃO como botão primário e "POR QUÊ?" com a explicação inteira.
<!-- /produto-arte-acoes -->


<!-- paineis-tema: bloco mantido junto com docs/DECISOES.md (PT1 a PT8) -->
## Painéis com o tema da tela da pedaleira (2026-11-24)

Este bloco vale por cima de qualquer frase anterior deste arquivo que diga o contrário, **só dentro da
área de configuração** (o painel de parâmetros) do Ignissor, do Entropia e do Axioma. Lista de presets,
cadeia, cabeçalho do bloco, cenas e todo o resto continuam no case de estrada.

Pedido do dono: cada um desses blocos ganha o tema visual que tem na tela da própria Anagram. Fidelidade
de espírito, não cópia: nada de arte, fonte ou imagem da Darkglass; tudo pintado em código.

### Como funciona
- `TemaPainel` (`lib/apresentacao/tema/tema_painel.dart`) é uma `ThemeExtension` com estilo
  (`metal` ou `neon`), uma `Paleta` derivada, o gradiente do fundo, o reflexo/grade e o friso.
  `TemaPainel.doBloco(uri, brilho)` devolve o tema do bloco ou nulo.
- `MolduraTemaPainel` aplica `TemaApp.doPainel(tema)` em volta do painel: o mesmo ThemeData do app sobre
  a paleta do painel, com os botões de contorno virando **placas** (fundo `painel-elevado`, forma do
  painel). Knob, fader, seletor, chave e gráficos se repintam sozinhos porque pedem a cor pelo papel.
- `decoracaoCartao(context)` desenha coluna de banda, cartão de seção e caixa de desenho: sem tema, a
  decoração de sempre (pixel igual); com tema, a forma e a placa dele.
- As cores vivem em `lib/apresentacao/tema/paletas_painel.dart`, derivadas de `Paleta.escura`/`clara`
  por `Paleta.copyWith`. Âmbar de ação, fita gaffer, alerta e LEDs são os do case.

### Alumínio escovado (Ignissor e Entropia)
- Fundo: gradiente vertical de três degraus + riscos horizontais finos (escovado) + duas ondas largas de
  reflexo (uma faixa em S à esquerda, um arco à direita).
- Letreiro: o nome do bloco em Barlow 400, 20px, caixa alta, espaçamento 8px, seguido de um filete.
- Títulos de cartão (`titleSmall`): Barlow 400 com +2,4px, caixa alta fina. Cartões são placas com
  gradiente `painel-elevado` → `painel`, canto de 8px.
- Ignissor: Threshold em **verde-limão** e Level em **magenta**, como na tela dele (no case, Threshold é
  rosa e Level verde). Destaque (chave Comp, arco, opção marcada) verde-limão.
- Entropia: as três bandas mantêm verde-água, lilás e laranja; destaque laranja.

| Papel | Escuro | Claro |
|---|---|---|
| fundo pintado (cima → baixo) | #3A4047 · #2B2F34 · #212428 | #CDD2D7 · #B9C0C6 · #AAB2B9 |
| reflexo | branco 6% | branco 22% |
| fundo-case (tela dos desenhos) | #2A2E33 | #F4F5F7 |
| painel / painel-elevado | #33383E / #3D434A | #E3E6E9 / #EEF0F2 |
| filete / alumínio / alumínio-claro | #5A626B / #9CA3AB / #D5D9DE | #9CA4AC / #555C64 / #383E45 |
| texto / texto-secundário | #F2F4F6 / #BCC2C9 | #14171A / #3E444B |
| destaque Ignissor / Entropia | #C4EC3A / #F2A33C | #758A1E / #B96F0E |
| Threshold / Level | #C4EC3A / #F55FCB | #637B11 / #D50E9D |
| tally-tinta / erro / corpo-knob | (do app) / #FF9C8C / #1C1F23 | #764C00 / (do app) / (do app) |

### Synthwave (Axioma)
- Fundo: gradiente roxo, chão em grade de perspectiva no terço de baixo, serra de montanhas em arame nos
  dois cantos e dois trilhos magenta (em cima e embaixo).
- Cartões e caixas de desenho com **cantos chanfrados** (10px; 5px nos pequenos), friso magenta de 2px
  sob o título de cada seção. Letreiro em Share Tech Mono com friso magenta e filete ciano.
- Títulos e valores em **Share Tech Mono** (monoespaçada: o valor não dança, a regra tabular continua).
  O nome do parâmetro acima do knob, o seletor e os botões ficam na Barlow Condensed: na mono,
  "SENSITIVITY" virava "SENSITIVI…" e "5-String Bass", "5-String Ba…".
- Destaque (arco, ondas, curvas do filtro e do envelope, opção marcada) em ciano.

| Papel | Escuro | Claro |
|---|---|---|
| fundo pintado (cima → baixo) | #2B1D55 · #1D1437 · #130C27 | #DCD2F5 · #CEC2EE · #C2B3E8 |
| grade / friso | #FF4FD0 a 10% / #FF5CD4 | #C21E8F a 10% / #D8009E |
| fundo-case (tela dos desenhos) | #1D1437 | #FBF9FF |
| painel / painel-elevado | #2A1D50 / #352862 | #F0EBFC / #F9F7FE |
| filete / alumínio / alumínio-claro | #6B52B3 / #A794DE / #DED5F8 | #A592DB / #5E48A5 / #3D2E70 |
| texto / texto-secundário | #F5F1FF / #C5B9EA | #1A1233 / #463A74 |
| destaque (ciano) | #43E8F2 | #0A8F98 |
| tally-tinta / corpo-knob | (do app) / #140C29 | #764C00 / #2A1D50 |

### Regras
**The Screen-Theme Rule.** Tema de tela só existe DENTRO da moldura do painel do bloco. Fora dela,
nenhuma cor, fonte ou forma desses temas.

**The Same-Hands Rule.** O tema muda a pele, nunca o gesto: knob, fader, seletor, solo, templates, digitar
o valor e voltar ao padrão funcionam igual, com os mesmos alvos (48dp no toque).

**Contraste medido.** `test/tema/contraste_tema_painel_test.dart`: texto e valor ≥ 4,5:1 sobre as três
superfícies e sobre cada degrau do fundo pintado com e sem o reflexo; foco, contorno, destaque, bandas e
traços ≥ 3:1; tinta de marcador sobre destaque e bandas ≥ 4,5:1. Nos dois brilhos.

**Movimento.** Nenhum: o fundo é estático, então "reduzir movimento" não tem o que desligar.
<!-- /paineis-tema -->
