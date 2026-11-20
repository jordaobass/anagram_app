# Pesquisa: como o Line 6 HX Stomp e o HX Edit trocam e editam presets

Data: 2026-11-05

Objetivo: levantar o padrão de interação do HX Stomp / HX Edit para orientar o MVP do app da Darkglass Anagram.

## Como ler este documento

- **(confirmado)**: li em página que abri (lista de fontes no fim).
- **(parcial)**: só vi em resultado de busca ou em manual de aparelho irmão (HX Effects), não no manual do HX Stomp.
- **(não confirmado)**: não consegui abrir fonte que prove.

Limitação: os sites que hospedam o manual do HX Stomp e o Pilot's Guide do HX Edit (manualmachine.com, manuals.plus, fullcompass.com) responderam 403. O único manual completo que consegui ler foi o do **HX Effects 3.0**. Ele pertence à mesma família e à mesma interface, mas **não** é o do HX Stomp. Onde isso importa, está marcado.

## 1. Presets, bancos e troca de preset

- O HX Stomp tem 126 presets: 1 setlist x 42 bancos x 3 presets (parcial; resultado de busca em fórum Line 6). O HX Stomp XL e o Helix têm mais setlists (confirmado no fórum, tópico 67242: o Stomp "não tem" gestão de setlists como o Helix).
- Numeração tipo "01A" (banco + letra): confirmado no manual do HX Effects, que mostra "01A", "01B", "01C", "01D" no scribble strip. No Stomp a letra vai só até C (inferência a partir de 42 x 3; não confirmado no manual do Stomp).
- Troca de preset no aparelho (manual HX Effects, seção Preset Mode):
  1. No modo Preset, BANK acima/abaixo escolhe o banco; os presets do banco piscam, "prontos para carregar".
  2. Tocar o footswitch do preset carrega.
  3. Alternativa: girar o Big Knob no modo Preset.
- Ajuste global "Preset Mode: Moment[ary]" faz o aparelho voltar ao modo Stomp logo após escolher um preset (confirmado, HX Effects).
- No HX Edit existe um painel Librarian (Ctrl+Shift+L) com a lista de presets do aparelho e arquivos locais (confirmado pelo atalho; layout detalhado não confirmado).

## 2. Cadeia de blocos: grade, caminhos A/B, split/merge

- A "Signal Flow view" mostra os blocos em sequência. Mover um bloco para o caminho B (parâmetro "Path" no Footswitch 2 / Knob 2) cria automaticamente um bloco **Split** à esquerda dele e um bloco **Mixer** (merge) depois do último efeito. Para remover o caminho B, basta mover todos os blocos de volta ao A (confirmado, HX Effects, págs. 36–37).
- O bloco Mixer **não pode** ser bypassado; o Split pode (se bypassado, comporta-se como Split Y com Balance no centro). Tipos de Split: Y, A/B, Crossover, Dynamic (confirmado).
- Os blocos Split e Merge Mixer não podem virar Favoritos (confirmado).
- Limite de blocos: o fórum Line 6 cita "limite de 6 blocos" no HX Stomp (parcial, FAQ página 8); o **HX Stomp XL** tem 8 blocos (não confirmado em fonte aberta). Não assumir "8 blocos" para o Stomp sem conferir.
- Os blocos podem ser arrastados e soltos, copiados e colados entre presets e entre aparelhos Helix/HX, inclusive entre janelas do HX Edit, "com algumas restrições" (confirmado, HX Effects, pág. 5). Pode haver bloco que não cola por limite de DSP ("Dynamic DSP").

## 3. Selecionar bloco e editar parâmetros

- No aparelho: tocar brevemente o footswitch do bloco o seleciona. Os 3 primeiros parâmetros aparecem na tela e os 3 knobs (1–3) os controlam; o scribble strip mostra colchetes brancos no bloco selecionado (confirmado).
- **Paginação:** quando o modelo tem mais de 3 parâmetros, aparecem setas nos cantos da tela e os botões de página avançam/voltam (confirmado, HX Effects).
- Apertar um knob restaura o valor padrão do parâmetro; em parâmetros de tempo, apertar alterna ms/Hz e subdivisão de nota (confirmado).
- No HX Edit: painel de parâmetros na parte inferior da janela (parcial; descrição do usuário, não li o Pilot's Guide). Atalhos de valor: setas = ajuste fino, Shift+setas = grosso, tecla D = valor padrão (confirmado, defkey).

## 4. Modos de footswitch

- **Stomp**: os footswitches ligam/desligam blocos e selecionam bloco para edição.
- **Preset**: BANK acima/abaixo + switches de preset.
- **Snapshot**: entra-se apertando BANK acima e abaixo ao mesmo tempo, a partir do modo Preset; cada switch seleciona uma snapshot (confirmado, HX Effects).
- Modo **"Scroll"**: não confirmado em nenhuma fonte aberta. Fica fora do documento até haver fonte.
- Configuração relacionada: "Snpsht Mode: Latch" e "Up/Dn Switch" em Global Settings > Switches (confirmado, HX Effects).

## 5. Snapshots

- Guardam: estado de bypass de todos os blocos (por padrão), valores dos parâmetros que foram "atribuídos ao controlador Snapshot" (até 64), valores de mensagens instantâneas do Command Center e, opcionalmente, o tempo (confirmado, HX Effects, págs. 29–31). O HX Effects tem 4 snapshots; o HX Stomp tem 3 (parcial; Stomp XL tem 4, não confirmado).
- Para um parâmetro variar por snapshot: apertar e girar o knob dele. O valor passa a mostrar "pequenos nós" na barra (aparelho) e, no HX Edit, o valor aparece **colorido de branco** (confirmado no fórum, tópico 69755: "quando atribuído corretamente, o valor do parâmetro fica branco"). Sem essa atribuição, a edição por snapshot não persiste.
- Cada bloco tem a opção "Snapshot Bypass On/Off": se Off, a snapshot não controla o bypass daquele bloco (confirmado).
- **Snapshot Edits (Global Settings > Preferences):**
  - **Recall** (padrão): edições feitas numa snapshot são mantidas ao pular entre snapshots, até trocar de preset.
  - **Discard**: voltar à snapshot recarrega o estado da última gravação. Para guardar a edição é preciso salvar (apertar SAVE duas vezes) **antes** de trocar de snapshot.
  - No HX Stomp, ACTION + seta de página alterna entre Recall (cinza) e Discard (vermelho) (confirmado no fórum, tópico 36656).
- "Snapshot Reselect": Reload (padrão) ou Toggle ao apertar de novo a snapshot ativa (confirmado).
- Copiar/colar snapshot: segurar o switch da origem e tocar o do destino; no HX Edit, Ctrl+Shift+C / Ctrl+Shift+V (confirmado).
- Mudar de snapshot já marca o preset como editado (ver seção 6).

## 6. Salvar x edição ao vivo, indicador de não salvo

- No aparelho, toda alteração vale na hora, mas fica em "memória descartável" até salvar. SAVE abre a tela de salvar (nome, destino); **apertar SAVE duas vezes** faz o "quick save" no mesmo slot (confirmado, HX Effects pág. 17 e fórum 44149).
- Trocar de preset sem salvar perde a edição (confirmado, fórum 44149).
- **Indicador de edição:** o aparelho mostra um pequeno **"E"** no preset editado (confirmado: manual HX Effects, "When the selected preset is in an edited state, a small 'E' is displayed", e fórum Stomp FAQ). No HX Edit, há um asterisco na visão de fluxo de sinal que aparece a cada alteração e reaparece depois de salvar e editar de novo (parcial; só resultado de busca, não abri a página). Se o asterisco fica no nome do preset ou noutro lugar: não confirmado.
- No HX Edit: Ctrl+S salva, Ctrl+Shift+S salva como; o item "Save Preset" fica desabilitado quando não há alteração (confirmado, defkey e fórum 54221).
- "O HX Edit envia toda alteração na hora ao aparelho": é o comportamento descrito pelo usuário e coerente com o modelo editor/aparelho, mas **nenhuma fonte aberta o afirma literalmente** (não confirmado).

## 7. Copiar/colar, mover, bypass, importar/exportar

- Aparelho: ACTION > Copy Block, depois tocar o switch de destino > Paste Block. A ação ACTION também permite mover e limpar o bloco (confirmado).
- Bypass no aparelho: tocar o switch do bloco, ou na Signal Flow selecionar o bloco e apertar FS2/FS3. O estado do bloco muda de aparência (ativo, ativo selecionado, bypassado, bypassado selecionado) (confirmado).
- HX Edit: **Space** alterna o bypass do bloco; **Delete** limpa; Ctrl+C / Ctrl+V copia e cola; Shift+Enter ou botão direito abre o menu de contexto (confirmado, defkey). "Clique/duplo clique" no bloco para bypass: não confirmado.
- Importar / exportar presets, IRs e Favoritos pelo HX Edit: Ctrl+I e Ctrl+E (confirmado). A extensão `.hlx` para preset é conhecimento geral, não vi em fonte aberta (não confirmado aqui). Backup completo do aparelho também existe (confirmado, HX Effects).

## 8. Atalhos de teclado do HX Edit (Windows; confirmado em defkey)

| Atalho | Ação |
|---|---|
| Ctrl+S / Ctrl+Shift+S | Salvar preset / salvar como |
| Ctrl+I / Ctrl+E | Importar / exportar preset, IR, favorito |
| Ctrl+C / Ctrl+V | Copiar / colar |
| Ctrl+Shift+C / V | Copiar / colar snapshot |
| Ctrl+Shift+1..n | Selecionar snapshot |
| Del | Limpar |
| Ctrl+A / Ctrl+R | Selecionar tudo / renomear |
| Space | Alternar bypass do bloco |
| Setas / Shift+setas / D | Valor fino / grosso / padrão |
| F1 | Abre o Pilot's Guide (parcial) |

## 9. Tabela: padrão HX para equivalente na Anagram e MVP

| Padrão HX | Equivalente na Darkglass Anagram | MVP? | Justificativa |
|---|---|---|---|
| Presets 126 em bancos (01A...) | 126 slots, 42 bancos x A/B/C | Sim | Mesma estrutura; é a navegação básica. |
| Troca de preset (footswitch/Big Knob) | Sem comando HID de "selecionar slot": tocar o documento lido via `try_anagram_preset`, ou MIDI Program Change | Sim | Lista por banco que "toca" o preset ao tocar nele. |
| Setlists | Não existe | Não | A Anagram não tem; o Stomp também só tem uma. |
| Grade de blocos, caminhos A/B | 2 linhas x 12 blocos (linha 2 = paralelo) | Sim | É a visão central do preset. |
| Split / Merge | Blocos split/merge existem | Sim, só exibir | Necessários para desenhar a grade; edição avançada depois. |
| Bypass do bloco (clique / Space) | `enabled` do bloco | Sim | Ação mais usada; tem retorno imediato. |
| Selecionar bloco e 3 knobs com paginação | Parâmetros do bloco em knobs, paginados | Sim | Padrão que o usuário já conhece. |
| Arrastar bloco | Reordenar na grade | Talvez | Útil, mas exige regras de slot e de DSP; fazer depois do resto. |
| Copiar/colar bloco | Copiar/colar entre posições e presets | Sim | Barato (JSON do bloco) e economiza muito tempo. |
| Snapshots (3-4) | 3 cenas por preset; guardam `enabled` e só os parâmetros que diferem; ativa em `preset.scene` (conta de 0) | Sim | Cenas 1–3 são a variação ao vivo do preset. |
| Snapshot Edits Recall/Discard | Não há equivalente conhecido | Não | Basta o comportamento "Recall" (edita na cena ativa); Discard é preferência de palco. |
| Valor colorido por snapshot | Parâmetro "difere da cena base" | Sim | Mostra o que a cena realmente sobrescreve. |
| Edição ao vivo (aparelho aplica na hora) | `try_anagram_preset` toca o preset inteiro sem salvar | Sim | Com debounce e interruptor "Ao vivo" para não inundar o USB. |
| Indicador de edição ("E" / asterisco) | Estado "não salvo" calculado no app | Sim | Evita perder edição ao trocar de preset. |
| Salvar (Save / Ctrl+S, duplo toque) | `edit_anagram_presets` grava no slot | Sim, com confirmação | Escrita destrutiva no slot; confirmar nome e destino. |
| Importar/exportar (.hlx / Ctrl+I, Ctrl+E) | JSON do preset | Sim | Backup e compartilhamento; formato próprio em JSON. |
| Modos de footswitch (Stomp/Preset/Snapshot) | Pedaleira via MIDI CC 85: 1 preset, 2 stomp, 3 scene | Só exibição | Mostrar o modo atual; trocar o modo pode ficar para depois. |
| Atribuição de controladores (Controller Assign) | Bindings pot1–pot6, foot1–foot3, exp.pedal | Não | Edição de bindings é complexa; footswitch só age por binding no modo Stomp. |
| Controlar preset ativo ou todos | Control Active / All | Só exibição | Conceito específico da Anagram; mostrar o estado. |
| Atalhos de teclado | Equivalentes no app | Parcial | Ctrl+S, Space (bypass), Ctrl+C/V; o resto depois. |
| Modo Scroll | Não confirmado | Não | Sem fonte; não projetar em cima de suposição. |

## 10. Sugestão de MVP

1. Lista por banco (42 x A/B/C) com nome; tocar um item toca o preset (via `try`).
2. Grade 2 x 12 com bypass por clique e indicação de split/merge.
3. Painel de parâmetros em knobs, 3 por página, com paginação.
4. Cenas 1–3: trocar a ativa, destacar parâmetros que diferem da base.
5. Edição ao vivo com debounce e interruptor "Ao vivo".
6. Indicador de "não salvo" no nome; salvar com confirmação (slot e nome).
7. Importar/exportar JSON; copiar/colar bloco.

Fora do MVP: arrastar bloco (talvez), edição de bindings, setlists, mudar modo de footswitch (só exibir), Snapshot Edits Discard, modo Scroll.

## 11. Pendências para confirmar

- Ler o manual do **HX Stomp** (não o do HX Effects) para confirmar: letras A–C, 3 snapshots, limite de blocos e o "Scroll".
- Ler o Pilot's Guide do HX Edit para confirmar: envio ao vivo, posição do asterisco, clique/duplo clique no bloco, formato `.hlx`.
- Obter o manual oficial em line6.com/support/manuals (a página existe mas os PDFs que abri vieram de espelhos).

## Fontes

- Manual do HX Effects 3.0, Rev B (espelho jam.ua; PDF lido localmente): https://jam.ua/files/files/5fb77f4d6b6ed.HX%20Effects%203.0%20Owner's%20Manual%20-%20Rev%20B%20-%20English%20.pdf
- Atalhos do HX Edit (Windows): https://defkey.com/hx-edit-windows-shortcuts
- Fórum Line 6, atalho de Snapshot Edits no HX Stomp (Recall cinza / Discard vermelho): https://line6.com/support/topic/36656-hx-stomp-only—shortcut-press-action-andpreferences-snapshot-edits-value
- Fórum Line 6, snapshots no HX Edit (valor branco ao atribuir): https://line6.com/support/topic/69755-saving-snapshot-changes-for-xh-stomp-in-hx-edit
- Fórum Line 6, snapshots Recall/Discard e Reselect: https://line6.com/support/topic/63067-hx-effects-snap-reselect-snpsht-edits/
- Fórum Line 6, HX Stomp FAQ (indicador "E", limite de blocos): https://line6.com/support/topic/36246-hx-stomp-faq/page/8/
- Fórum Line 6, mudanças só em memória até salvar duas vezes: https://line6.com/support/topic/44149-unstore-preset-changes-verification-save-versions-of-one-preset
- Fórum Line 6, salvar presets do Stomp no HX Edit / export: https://line6.com/support/topic/67242-saving-hx-stomp-presets-in-hx-edit
- Fórum Line 6, Ctrl/Cmd+S e "Save Preset" desabilitado sem alteração: https://line6.com/support/topic/54221-hx-editor-save-preset-vs-toggle-snapshot-bug/
- Páginas encontradas mas que NÃO consegui abrir (403): manualmachine.com (HX Stomp e HX Edit), manuals.plus, fullcompass.com (HXStompUserGuide.pdf). Índice oficial de manuais: https://line6.com/support/manuals
