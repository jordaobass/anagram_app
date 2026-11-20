---
name: Anagram App
description: Editor de presets da Anagram com cara de case de estrada, tema escuro único.
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
  familia-compressor: "#E2C23A"
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
  botao-cena-ativa:
    backgroundColor: "{colors.tally}"
    textColor: "{colors.sobre-tally}"
  fita-preset:
    backgroundColor: "{colors.fita-gaffer}"
    textColor: "{colors.tinta-marcador}"
    typography: "{typography.headline}"
    padding: "8px 16px"
    height: "56px"
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
  aviso-snackbar:
    backgroundColor: "{colors.fita-gaffer}"
    textColor: "{colors.tinta-marcador}"
---

# Design System: Anagram App

## Overview

**Creative North Star: "O Case de Estrada"**

O app é o flight case da pedaleira, não um site de configurações. Tudo é desenhado como equipamento de turnê visto no chão do palco: casco escuro, quinas de alumínio, nomes escritos a marcador em fita gaffer, numeração em estêncil e fitas de cor de roadie que dizem a família de cada bloco. A densidade é de ferramenta de bancada (lista de 126 slots, grade de 2 × 12 casas, knobs grandes), mas tudo legível de longe e com alvo de toque de no mínimo 48dp.

Tema escuro único, sem variante clara. A cor é rara e funcional: o âmbar "tally" marca o que está ativo/selecionado, a fita gaffer marca o nome do preset, o vermelho de alerta marca o que ainda não foi gravado, e as cores de família só aparecem onde há bloco. Recusa explícita do contrato: a tela de cards cinza com sliders genéricos.

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
- **Âmbar Tally** (`tally`): botão primário (SALVAR NO SLOT, LIGADO, CONECTAR), cena ativa, contorno de 2px da casa selecionada, filete esquerdo e rótulo do slot aberto na lista, anel de foco do knob, "AO VIVO" ligado e o interruptor. Texto sobre ele é sempre `sobre-tally`.

### Secondary
- **Fita Gaffer** (`fita-gaffer`, borda inferior `fita-gaffer-sombra`): o fundo do nome do preset e do snackbar; também o ponteiro do knob. Texto sobre ela é sempre `tinta-marcador`.
- **Fita de Alerta** (`fita-alerta`): só o selo "NÃO SALVO", com texto branco.

### Tertiary
- **Fitas de Família** (`familia-*`): dez cores, uma por família de bloco (drive, compressor, equalizador, filtro, modulação, delay, reverb, amplificador, gabinete, utilitário). Aparecem na fita de 4px sob a casa, no arco do knob, no corpo da arte própria de bloco e na opção marcada de parâmetro de escolha (com texto `tinta-marcador`).
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
- **Display** (Saira Stencil, 40px, altura 1): slot do preset aberto ("02A"). Nos botões de cena o mesmo estêncil aparece no tamanho de `title-large` (20px).
- **Headline** (Permanent Marker, 26px, 1.1): nome do preset sobre a fita gaffer, em `tinta-marcador`.
- **Headline Valor** (Barlow 600, 26px, figuras tabulares): valores numéricos grandes.
- **Title Large / Medium** (Barlow 600, 20px / 17px): nome do bloco no painel, título de diálogo; valor sob o knob (17px, tabular).
- **Title Small** (Barlow Condensed 600, 15px, +0.6px): estado da conexão, rótulo do slot na lista.
- **Body** (Barlow 16 / 15 / 13px, 1.4–1.35): nome do preset na lista (16), instrução (15), "vazio" e metadados do bloco (13).
- **Label Large** (Barlow Condensed 700, 17px, +0.8px, caixa alta): texto de botão e de cena, "AO VIVO".
- **Label Medium** (Barlow Condensed 600, 14px, +0.7px): nome de parâmetro em caixa alta acima do knob, nome curto na casa, selo "NÃO SALVO", latência.

### Named Rules
**The Hand-Lettered Tape Rule.** Marcador só existe em cima de fita gaffer, e fita só existe onde há nome escrito à mão. Fora da fita do preset, nada de Permanent Marker.

**The Stencil Is A Number Rule.** Estêncil é para identificador numérico (slot, cena), nunca para frase.

**The Tabular Value Rule.** Todo valor de parâmetro usa figuras tabulares, para o número não dançar enquanto o knob gira.

## Layout

Grade de espaçamento de base 4 (2, 4, 8, 12, 16, 24, 32, 48px). O padrão interno de moldura é 16px; a grade de blocos usa 12px.

Duas composições, decididas por largura ≥ 780 e altura ≥ 600 (o iPad em retrato já entra na ampla):
- **Ampla** (tablet paisagem, desktop): barra de conexão de 64px no topo; lista de presets fixa à esquerda (304px a partir de 1300px de tela, 256px abaixo disso; linhas de 48px agrupadas por banco com divisor de filete); à direita, em coluna: faixa do preset (slot + fita + ações alinhadas à direita; abaixo de 880px de editor as ações descem para baixo da fita), cenas 1–3 em três colunas iguais, moldura da grade, moldura dos parâmetros com todos os knobs à vista, sem páginas, de 104px (encolhem até 84px para caber numa fileira). Editor ao lado da lista com menos de 700px usa a grade e os parâmetros da compacta.
- **Compacta** (celular retrato): mesma ordem empilhada; a fita do nome quebra em até 2 linhas, ações vão para a linha de baixo alinhadas à esquerda, a lista de presets abre ao tocar no slot, knob de 84px e a grade mostra só as casas ocupadas, em fileiras de 4 no celular e até 6 no iPad em retrato (casa de até 112px).

Casas da grade entre 56 e 112px de largura, para as 12 caberem sem rolagem lateral do iPad mini em paisagem para cima; abaixo de 76px a casa mostra a abreviação do bloco; a arte ocupa 86% da casa. Diálogos com 440px; telas vazias (conectar) limitadas a 520px e centralizadas.

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
- **Primário:** âmbar tally, texto `sobre-tally`, 16px de lateral. Ex.: SALVAR NO SLOT, CONECTAR, LIGADO.
- **Contorno:** transparente, borda de 1px `aluminio`, texto `texto`. Ex.: DESCARTAR, LARGAR, DESLIGADO, ABRIR DEMONSTRAÇÃO.
- **Foco:** cor de foco é âmbar a 24% de opacidade.
- **Ações destrutivas** (descartar, largar) ficam isoladas e só em contorno; DESCARTAR só aparece quando há edição não salva.
- **Ícone:** Material Icons via IconButton com tooltip (desconectar, créditos, copiar bloco, menu de arquivo).

### Cenas
Três botões de largura igual, altura 56px. Inativo: `painel-elevado` com borda de filete. Ativo: preenchido em âmbar. Número em estêncil + nome em caixa alta.

### Fita do Preset (assinatura)
Slot em estêncil de 40px à esquerda (toque abre a lista no celular), seguido da fita gaffer creme com o nome a marcador e, se houver edição não salva, o selo vermelho "NÃO SALVO" no fim da fita.

### Moldura de Case
Painel `painel` com filete de 1px, canto de 3px e cantoneiras de alumínio pintadas por cima. Envolve a grade de blocos e o painel de parâmetros.

### Casa de Bloco
Arte do pedal (miniatura ou arte própria da família), fita de família de 4px, nome curto em label-medium. Selecionada: fundo `painel-elevado` + contorno âmbar de 2px. Desligada: arte a 38% de opacidade e nome em `texto-secundario`. Transição de 150ms. Toque seleciona, toque duplo liga/desliga, toque longo/botão direito abre menu.

### Knob
Nome do parâmetro em caixa alta acima, valor tabular abaixo. Trilho em filete, arco na cor da família, corpo `painel-elevado` com aro de alumínio (âmbar 2px quando focado), ponteiro em fita gaffer. Arraste vertical/horizontal, rodinha, setas (Shift = passo de 10%), toque duplo volta ao padrão. Parâmetros com poucas opções viram coluna de botões: marcado em cor da família, demais em contorno.

### Navigation
- **Barra de conexão:** 64px, `painel`, filete inferior. LED de 10px + estado em title-small, "AO VIVO" + interruptor âmbar, latência "ida e volta N ms" (só na ampla), ícones de desconectar e créditos.
- **Lista de presets:** linhas de 48px, slot em title-small (`aluminio-claro`, âmbar quando aberto), nome em body-large ou "vazio" em body-small; linha aberta ganha `painel-elevado` e filete esquerdo âmbar de 2px.

### Avisos
Snackbar flutuante em fita gaffer com texto `tinta-marcador`, 15px. Diálogo em `painel-elevado`, canto 8px, ações separadas nas pontas.

## Do's and Don'ts

### Do:
- **Do** usar só tokens de `lib/apresentacao/tema/tokens.dart`; nenhuma cor ou medida fora dali.
- **Do** manter alvo mínimo de 48dp em todo controle tocável.
- **Do** separar camadas por tom (`fundo-case` → `painel` → `painel-elevado`) e filete de 1px.
- **Do** marcar seleção com contorno âmbar de 2px ou preenchimento âmbar, nunca com sombra.
- **Do** colocar a fita de família de 4px sob todo bloco e herdar a mesma cor no arco do knob.
- **Do** usar figuras tabulares em todo valor numérico que muda.
- **Do** deixar "salvar" como ato separado: edição ao vivo nunca grava sozinha, e o selo "NÃO SALVO" fica visível enquanto houver diferença.

### Don't:
- **Don't** usar Permanent Marker fora da fita gaffer, nem fita gaffer sem nome escrito.
- **Don't** usar âmbar como cor de família ou decoração.
- **Don't** pintar ação destrutiva em cor cheia; descartar/largar é contorno.
- **Don't** usar sombra projetada nem cantos acima de 8px.
- **Don't** usar logo, foto ou marca da Darkglass na arte de bloco.
- **Don't** criar tela de cards cinza com sliders genéricos; parâmetro contínuo é knob.
