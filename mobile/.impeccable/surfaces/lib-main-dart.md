---
version: 1
slug: "lib-main-dart"
primary_target: "lib/main.dart"
related_targets: []
---

Escopo: tela do editor (lista de presets + cadeia + parâmetros + cenas) e conexão. Modo: Operate.
Público: baixista com Anagram, na bancada e no palco; tarefa: trocar preset, ajustar bloco ouvindo, salvar no slot.
Restrições: Flutter nativo, tema escuro, alvos ≥48dp, sem arte de fabricante. Caminho code-led (plataforma nativa, sem usuário para aprovar comps).
Seed: 0b8b81de (assigned 6: flight case de turnê).

## Direction contract
THESIS: o app é o case de estrada da pedaleira, não um site de configurações; recusa a tela de cards cinza com sliders genéricos.
OWN-WORLD: fundo ABS preto texturizado, cantoneiras/arestas de alumínio como filetes de 1px, fita gaffer creme com letra de marcador para nomes, numeração em estêncil, fitas de cor de roadie codificando categoria de bloco.
STORY: o baixista vê qual preset está tocando, segue a linha do sinal pelos blocos, gira o knob e ouve; o selo "NÃO SALVO" lembra que gravar é outro ato.
FIRST VIEWPORT: faixa do preset atual em fita gaffer com slot em estêncil gigante, a linha do sinal em duas pistas (ângulos de 45/90°, herdado do mapa de metrô) com os blocos como pedais ilustrados, knobs grandes embaixo.
SIGNATURE: arrastar um knob acende a fita do bloco e a latência ida-e-volta aparece ao lado do selo Ao vivo.
RISK: textura demais vira fantasia; a fita só existe onde há nome escrito à mão.
Raises: (console escuro, competitivo) ações destrutivas isoladas e só contorno; (mapa de metrô, competitivo) sinal como linha contínua com dobras de 45°/90°. Demais desafiantes recusados.
