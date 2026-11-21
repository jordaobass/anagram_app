# Plano: ponte MIDI e MIDI learn

Pedido de usuário no r/Darkglass (Akai MIDImix) e do dono (M-VAVE Chocolate): controlar **qualquer**
parâmetro de qualquer bloco por uma controladora MIDI, com o app como ponte
(controladora → app → pedaleira pelo USB). A pedaleira sozinha só aceita MIDI nos ~10 controles
atribuídos por preset (CC 17–19, 20–25 e 89).

Situação: **proposta**, aguardando o dono decidir as MI1–MI12 abaixo. Nada daqui foi implementado.

## Fatos conferidos no código (2026-11-21)
- A janela do `EnvioAoVivo` é de **100 ms** (L1); os ~40 ms são a ida e volta medida (L3).
- As regras de cena já valem para qualquer edição que passe por `comParametro` (C1): a ponte não
  precisa de regra própria de cena.
- `ControladorEditor` está perto do limite de 200 linhas por classe e `BarraConexao` também: o código
  novo entra em mixin e widgets próprios.
- `alterarParametros` atual manda sempre na hora (`aplicarDocumento`); a ponte precisa de um caminho
  com `agendarAoVivo`, para respeitar a vazão.

## Escopo
**MVP (Windows e macOS):** entrada MIDI (winmm/FFI no Windows, CoreMIDI pelo canal nativo no macOS);
escolher a porta em Configurações (a porta da própria Anagram aparece desabilitada); modo APRENDER
MIDI (botão, Ctrl/Cmd+L, Esc cancela) — clica no controle, mexe no knob físico; CC → parâmetro do
preset aberto; marca "CC 21" no controle e lista de mapeamentos do preset; escala 0–127 →
faixa do parâmetro (linear, log, inteiro, opções, liga/desliga); coalescência antes do editor;
**pickup** nos contínuos (evita salto de volume ao trocar de preset); luz "MIDI IN".

**Depois:** ações discretas (bypass, cenas, preset ±, Ao vivo; aceitar Nota e Program Change — caso
da Chocolate e dos botões do MIDImix); escopo global e "segue o bloco selecionado"; perfis prontos
MIDImix/Chocolate; faixa mín/máx, inversão, CC 14 bits; LEDs do MIDImix; BLE no Windows, Web MIDI,
Android, Linux; aprender nos toggles e na curva do EQ; rota rápida por CC direto à Anagram (L4).

## Decisões para o dono (em lote)
| # | Pergunta | Recomendação |
|---|---|---|
| MI1 | Contraria a D3 (bindings fora do MVP)? | Não: a ponte não toca em `bindings` nem nos CC da pedaleira; é o app editando como o mouse |
| MI2 | Onde guardar os mapeamentos? | Arquivo do app (`shared_preferences`, chave `midi.mapas.v1`) por uuid do preset; nada vai para a pedaleira. Perfil de controladora global depois |
| MI3 | "Salvar como"/copiar preset levam os mapeamentos? | Sim, copiar para o uuid novo |
| MI4 | Bloco mudou de casa | Guardar posição + uri + símbolo; mesma posição e uri → usa; senão, uri única no preset → usa; senão, órfão (cinza, ignorado) |
| MI5 | Cenas | Segue a C1, sem regra nova; trocar de cena rearma o pickup |
| MI6 | Pickup ou jump? | Pickup nos contínuos, jump nos discretos, com interruptor em Configurações |
| MI7 | Loop com a porta da Anagram | Porta da Anagram desabilitada na entrada; nunca repassar entrada para saída (sem MIDI thru) |
| MI8 | Trocar de preset | Carrega os mapas do novo uuid, descarta valores pendentes, rearma pickup; mensagem com editor ocupado é descartada |
| MI9 | Ao vivo desligado | Controladora edita sem enviar (como o knob, L2) |
| MI10 | Cardinalidade | 1 CC ↔ 1 alvo no MVP; aprender CC já usado move o mapeamento (com DESFAZER) |
| MI11 | Identidade da porta | macOS `kMIDIPropertyUniqueID`; Windows nome + ordem; reabrir sozinha quando volta |
| MI12 | Desfazer | Só o Descartar no MVP; mexer na controladora corta o `undo` da IA (RA1), como um knob da tela |

## Arquitetura
Caminho quente: SO (thread nativa) → `EntradaMidi` → bytes → `lerMensagensMidi` → `PonteMidi`
(aprendendo? captura : mapa → resolve alvo → escala → pickup) → `CoalescedorMidi` (último valor por
alvo, ~16 ms; "soltou" após 150 ms) → `alterarPorControleExterno` (mixin do editor) → `comParametro`
→ `agendarAoVivo`/`enviarAoVivo` → `EnvioAoVivo` (sem mudança).

- **Núcleo** (`lib/nucleo/midi/`): `mensagem_midi.dart` (parser com running status, ignora tempo
  real e SysEx), `gatilho_midi.dart`, `mapeamento_midi.dart` (`AlvoParametro`, `MapasMidi`,
  `resolverAlvo`), `escala_midi.dart` (reusa `escala_parametro.dart`), `captura_suave.dart`
  (pickup), `portas_midi.dart` (`ehPortaDaAnagram`, movido de `midi_windows.dart`),
  `entrada_midi.dart` (interface + `EntradaMidiDemonstracao`).
- **Plataforma:** `winmm_entrada_ffi.dart`, `entrada_midi_windows.dart` (`NativeCallable.listener`,
  fechamento Stop → Reset → Close → `callable.close()`, vigia de portas a cada 2 s),
  `desempacotarMensagemCurta` em `midi_windows.dart`, `entrada_midi_nativa.dart` +
  `apple_compartilhado/CanalEntradaMidi.swift` (CoreMIDI, UMP → bytes, entrega na main thread),
  `FabricaEntradaMidi` separada da `FabricaTransporte`.
- **Dados:** `lib/dados/preferencias_midi.dart`.
- **Aplicação** (`lib/aplicacao/midi/`): `controlador_entrada_midi.dart`,
  `controlador_mapeamentos_midi.dart`, `ponte_midi.dart`, `coalescedor_midi.dart`;
  `estado/controle_externo_do_editor.dart` (mixin).
- **Apresentação:** `alvo_midi.dart` (contorno âmbar no modo aprender; rótulo "CC 21"; seta do
  pickup), `botao_aprender_midi.dart`, `luz_midi_in.dart`, `painel_entrada_midi.dart`,
  `lista_mapeamentos_midi.dart`, atalhos, l10n pt/en/es.

## Riscos
1. Callback do winmm em thread do driver: só inteiros no `NativeCallable.listener`; callback após
   fechar derruba o processo — ordem de fechamento testada com `WinMm` falso.
2. Porta de entrada exclusiva no Windows (`MMSYSERR_ALLOCATED`): "porta ocupada: feche a DAW".
3. Desconexão a quente: vigia de 2 s no Windows; `kMIDIMsgSetupChanged` no macOS.
4. CoreMIDI em thread de alta prioridade; `eventSink` só na main; pbxproj sem quebrar o iOS.
5. Enxurrada de CC: sem coalescer, cada mensagem copia o preset e redesenha; com ele, ~60 estados/s
   na tela e 10 envios/s à pedaleira.
6. Latência pior caso ≈ 16 + 100 + ~40 ms; medir no log (`midi: CC→envio N ms`).
7. Hardware a conferir: botões do MIDImix mandam **Nota** de fábrica; SEND ALL despeja todos os
   controles; modos da Chocolate; Chocolate só por USB no Windows no MVP.
8. Learn ambíguo: aprender só CC e ignorar tempo real.

## Testes
- Unitários: parser, escala (extremos, log, opções, inteiro, liga/desliga em 64), pickup, resolução
  de alvo, json, `ehPortaDaAnagram`, `desempacotarMensagemCurta`, ordem de fechamento do winmm,
  canal nativo simulado; aplicação com `fakeAsync` (50 CCs em 100 ms → ≤ 2 envios e valor final ao
  parar; aprender/Esc/mover; troca de preset; ocupado; Ao vivo desligado; salvar como; porta some e
  volta; mexer pela tela rearma pickup).
- **Ponta a ponta** (`test/ponta_a_ponta/ponte_midi_test.dart`): demonstração + `EntradaMidiDemonstracao`
  → aprender `param-Threshold` com CC 21 → varredura até 127 → a pedaleira de demonstração toca o
  máximo do Threshold, 1–4 envios, selo "não salvo".
- Bancada: `integration_test/bancada_midi_entrada_test.dart` + roteiro com MIDImix e Chocolate no
  Windows e no macOS (lista sem a Anagram, 8 knobs juntos, pickup, tirar o cabo, DAW aberta, BLE no
  Mac, Program Change da D4 continua).

## Fatias (PRs)
| # | PR | Tamanho |
|---|---|---|
| 0 | DECISOES (MI1–MI12) + issue no GitHub | P |
| 1 | Núcleo puro + testes | M |
| 2 | Entrada Windows + demonstração + script de bancada | M |
| 3 | Entrada macOS (Swift, canal) | M |
| 4 | Aplicação (controladores, ponte, coalescedor, mixin, ganchos de salvar como) | G |
| 5 | Interface + l10n + ponta a ponta + README | G |
| 6 | Bancada e ajustes → release | P |
| 7–10 | Depois: ações discretas; global/perfis; LEDs; Web/Android/BLE | M cada |

2 e 3 andam em paralelo depois do 1.

## Issue (inglês)
**Title:** MIDI controller bridge / MIDI learn — control any block parameter from a USB MIDI controller (feedback wanted)

The Anagram only responds to MIDI on the controls assigned per preset (3 footswitches, 6 pots,
expression — about 10 per preset). The Anagram App can already change **any** parameter of **any**
block live over USB. This feature makes the app a bridge: **MIDI controller → Anagram App → any
parameter**, so you can shape tones at home or in the studio with real knobs instead of the mouse
(original request on r/Darkglass with an Akai MIDImix).

**Planned first version (Windows + macOS):**
- Pick a MIDI input port in Settings (the Anagram's own port is excluded, and nothing is echoed back, so no MIDI loops).
- **MIDI Learn:** turn on Learn, click a knob in the app, move a knob on your controller. Done.
- Mappings are saved per preset (in the app, not in the preset file, so nothing extra goes to the pedal) and follow a block when you move it.
- Works with scenes exactly like the on-screen knobs; changes are live and show as "not saved" until you save.
- **Pickup (soft takeover)** for continuous parameters, so switching presets never makes the volume jump.

**Later:** footswitches/buttons for bypass, scenes and preset up/down; global "follow the selected
block" layouts; ready-made profiles; LED feedback.

**We'd love feedback from controller owners:**
1. Which controller do you use (model, USB or Bluetooth)?
2. What do its knobs/faders/buttons send by default (CC, Note, Program Change; absolute or relative/endless)?
3. Would you rather map per preset, or one global layout that follows the selected block?
4. Pickup or jump as the default?
5. Willing to test a beta build on Windows or macOS?

Akai MIDImix and M-VAVE Chocolate are our first test devices. The app has no telemetry; its only network call is an optional check for a new release on GitHub, which can be turned off.
