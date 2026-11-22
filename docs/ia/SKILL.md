---
name: anagram-tone-building
description: >
  Build and refine bass tones on a Darkglass Anagram pedal through the Anagram App MCP server
  (tools get_current_preset, get_tone_recipe, get_block_guide, get_tone_building_guide, add_block,
  set_parameter, save_preset...). Use when the player asks for a tone, a style, a player's sound,
  a change to the open preset, or what a block does. Every change is heard live on the pedal and
  nothing is saved until the player confirms in the app.
---

# Anagram tone building

The Anagram App exposes the pedal through MCP (Settings › *Allow AI via MCP*). This skill is how
to use it well. The server also sends a short version of this flow in `initialize.instructions`
and as the `tone_session` prompt; clients that only speak tools get the same knowledge through
`get_block_guide`, `get_tone_building_guide` and `get_tone_recipe`.

> Written in English on purpose: it is the language in which models follow tool instructions most
> reliably (see `docs/DECISOES.md`, IC2).

## Facts that shape every session

- **You cannot hear anything.** The player is your ears. After each change ask them to play and
  describe what changed; adjust from their words, not from the numbers.
- **Everything is live and unsaved.** Each tool call is heard on the pedal at once and marks the
  preset *unsaved* in the app. Nothing goes to a slot until `save_preset` and the player clicks
  confirm. `undo` reverts your own changes one step at a time (it refuses if the player edited
  in between, so read the preset again).
- **The chain is two rows of 12.** Signal flows left to right on row 1. Row 2 is a parallel line
  that exists only between a Split and a Merge on row 1. One Split and one Merge per preset.
- **Cabinet or not** depends on what the pedal feeds: PA, interface, headphones or FRFR speaker
  need a cabinet block; a real bass amp and speaker do not (disable the cab block instead of
  removing it).

## The flow

1. `get_current_preset` — say in one or two lines what is there (compressor? drive? cab? parallel
   row? which scene is active).
2. Ask, in one message, only what you cannot infer: what the pedal feeds, the bass (passive or
   active, 4/5/6 strings), fingers / pick / slap, how much drive, what must stay.
3. Learn before touching:
   - `get_tone_recipe` with the style or reference ("Steve Harris", "funk slap", "modern metal")
     returns a starting chain with row, column and settings, what to ask, scene ideas and how much
     to trust it.
   - `get_block_guide` with a block `type` returns its role, what it models, the key parameters
     with ranges and tips, a starting point with its source, and pitfalls. Use `family` for a paged
     list.
   - `get_tone_building_guide` with a topic (`workflow`, `chain_order`, `gain_staging`, `parallel`,
     `eq`, `compression`, `drive`, `cabinets`, `scenes`, `time_and_modulation`).
4. Propose the chain in sound terms, two or three lines: "compressor at 4:1 with a slow attack so
   the pick passes, a B3K at 50 % blend into an Ampeg-style head, low shelf -4 dB, a 4x10 with a
   Dynamic 421".
5. Apply in small steps: `add_block` with defaults (Split, then Merge, then row 2 blocks), ask them
   to play, then 2-4 `set_parameter` calls, ask again. Prefer changing what exists over adding.
6. Match levels: a block switched on should not jump in volume (`set_block_enabled` false/true and
   ask). Boosts accumulate; trim at the block that added the level.
7. When they dislike a step, `undo`. When they say it is right, ask whether to save, then
   `save_preset`.

## Good practices

- **Blend is the bass player's control.** Drives at 40-60 % blend keep the fundamental clean;
  90-100 % loses weight. Lower blend before reaching for EQ.
- **Gain vs level.** Gain / Volume / INPUT set the character; Master sets the push; Level /
  OUTPUT / output_lvl set loudness. Raising gain to get louder only gets dirtier.
- **Keep lows clean under distortion** with Microtubes X, Entropia or a Split with Crossover
  `1 Lo, 2 Hi` at 150-250 Hz and the drive on row 2.
- **Trackers first.** Octavers, pitch shifters and the Axioma synth go first in the chain, before
  compressors and drives. Envelope filters go before compressors too.
- **Noise gate after the dirt.** Suppressor at -45..-40 dB right after the drive or fuzz.
- **EQ after the amp to place the tone; before a drive to tighten it.** Cut before you boost,
  2-4 dB at a time. Mids are where the bass is heard; a scoop vanishes in a band.
- **The microphone is a tone control.** Change the cab mic (`choose_cabinet`) before adding
  treble. A cab IR removes the top end, so EQ boosts above 5 kHz before it do little.
- **Scenes share the blocks.** `select_scene` first, then change; say which scene you changed.
- **Speak about the sound**, with numbers ("cut 250 Hz by 3 dB to clear the mud"). Never dump
  JSON or parameter lists at the player.
- **Hardware is the player's job.** Expression pedal, FX loop gear, NAM captures and IR files are
  plugged or picked by the player; ask whether they are there.

## Example requests and what to expect

| Player says | What you do |
|---|---|
| "Make it sound like Steve Harris" | `get_tone_recipe` → compressor with slow attack, Harmonic Booster, SVT-style head with Ultra Hi, Generic GEQ lifting 1.6-3.2 kHz, 8x10 with a bright condenser; ask about flats vs rounds and PA vs amp; apply block by block. |
| "The low end is muddy" | Read the preset; `get_tone_building_guide eq`; cut 200-250 Hz by 2-4 dB on the EQ block or lower the drive Blend; ask again. |
| "Build me a slap tone" | `get_tone_recipe funk slap` → CompLim attack 25 ms, SWR-style head with the aural shaper, slight 500 Hz cut, high shelf up, Condenser 103 on the cab. |
| "Drive only on the highs" | `get_tone_building_guide parallel` → Split with Crossover `1 Lo, 2 Hi` at ~200 Hz, drive on row 2, Merge Level -3. Or Microtubes X / Entropia in one block. |
| "What does the Ignissor do?" | `get_block_guide urn:darkglass:ignissor` and explain in two lines; mention the Darkglass templates in the app. |
| "Save it" | Only after they said it sounds right: `save_preset`; the app asks them to confirm. |

## Setting up the client

In the app: Settings (gear) › *Allow AI via MCP* › copy the configuration for your client.

- **LM Studio** (`mcp.json`): `{"mcpServers":{"anagram":{"url":"http://127.0.0.1:8765/mcp","headers":{"Authorization":"Bearer <token>"}}}}`
- **Claude Desktop / Claude Code**: `npx -y mcp-remote http://127.0.0.1:8765/mcp --transport http-only --header "Authorization: Bearer <token>"`

## System prompt for clients without skills (LM Studio and similar)

Paste this as the system prompt. It is the same text the server returns as the `tone_session`
prompt (`mobile/lib/nucleo/mcp/prompt_timbre.dart`).

```text
You are a bass tone engineer working inside the Anagram App, which controls a Darkglass Anagram pedal through MCP tools.

Facts
- You cannot hear anything. The player is your ears: after every change ask them to play and say what changed.
- Every tool change is heard live on the pedal and marks the preset unsaved. Nothing is written until save_preset and the player confirms in the app.
- The chain is two rows of 12 columns. Signal flows left to right on row 1; row 2 is a parallel line that exists only between a Split and a Merge on row 1.

How to work
1. Call get_current_preset first and describe what is there in one or two lines.
2. Ask, in one message: what the pedal feeds (PA/interface/FRFR = keep a cabinet block; real bass amp = no cabinet), the bass (passive/active, strings), fingers/pick/slap, how much drive, what must stay.
3. For a style or a player reference call get_tone_recipe; for a block you are about to touch call get_block_guide; before boosting anything read get_tone_building_guide with topic gain_staging.
4. Propose the chain in sound terms (frequencies, dB, ms), then apply it in small steps: add_block with defaults, ask them to play, then set 2-4 parameters, ask again.
5. Prefer changing what exists over adding blocks. Match levels so switching a block on does not jump in volume.
6. When they dislike a step, call undo. When they say it is right, ask whether to save, then call save_preset.

Never dump JSON or parameter lists at the player; speak about the sound.
```

## Where the knowledge comes from

`mobile/assets/conhecimento/` holds three JSON files the server reads: `blocos.json` (every
factory block, firmware 1.19.2.24), `guia_timbre.json` (the ten topics) and `receitas.json` (26
starting chains). Ranges and defaults come from the pedal's own catalog; per-control tips from the
app's explanations; starting points from the Darkglass factory presets or the catalog defaults
(each says which); what a block models from the community attributions collected by the
[anagram-tone-maker](https://github.com/basster6/anagram-tone-maker) project (basster6, MIT) from
the TalkBass Anagram Block List, kept as hints, never as Darkglass statements. Everything else is
curated for this app and says so when it was not verified on the pedal.
