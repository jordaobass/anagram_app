# Anagram App

**English** · [Português](README.pt-BR.md)

A **free and open-source** preset editor for the **Darkglass Anagram** bass multi-effects: presets by
bank, a signal chain with the pedal's own block art, big knobs, scenes and **live editing** over USB.
One Flutter codebase for macOS, Windows, Linux, Android and the browser (Chrome/Edge).

<p align="center">
  <a href="https://github.com/jordaobass/anagram_app/releases/latest"><img alt="Download for Windows" src="https://img.shields.io/badge/Download-Windows%2010%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white"></a>
  <a href="https://github.com/jordaobass/anagram_app/releases/latest"><img alt="Download for macOS" src="https://img.shields.io/badge/Download-macOS%20(Apple%20Silicon)-111111?style=for-the-badge&logo=apple&logoColor=white"></a>
</p>

<p align="center">
  <a href="https://github.com/jordaobass/anagram_app/releases/latest"><img alt="Latest version" src="https://img.shields.io/github/v/release/jordaobass/anagram_app?label=version&color=F0B429"></a>
  <a href="https://github.com/jordaobass/anagram_app/releases"><img alt="Downloads" src="https://img.shields.io/github/downloads/jordaobass/anagram_app/total?label=downloads&color=41D68A"></a>
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/github/license/jordaobass/anagram_app?color=8E949B"></a>
  <a href="https://github.com/jordaobass/anagram_app/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/jordaobass/anagram_app?style=flat&color=E8E1CD"></a>
</p>

<p align="center">
  <a href="https://jordaobass.github.io/anagram_app/"><strong>Website</strong></a> ·
  <a href="https://github.com/jordaobass/anagram_app/discussions">Discussions</a> ·
  <a href="https://github.com/jordaobass/anagram_app/issues/new">Suggest a feature</a>
</p>

<p align="center">
  <a href="https://jordaobass.github.io/anagram_app/"><img alt="Tour of the app: editor, multiband compressor and drive, templates, Axioma synth, cabinets and control explanations" src="docs/imagens/en/tour.gif" width="900"></a>
</p>

> **Unofficial app, not affiliated with Darkglass Electronics.** Anagram is a trademark of its
> manufacturer; the block art is used with Darkglass's permission.

No ads and no telemetry. The app talks to the pedal over USB; its only network call is an optional
check on launch (Windows, macOS and Linux) that asks GitHub for the latest release. That request
sends only the app's version (in the User-Agent header); as with any connection, GitHub sees your IP
address. It can be turned off in **Settings › Updates**.

The interface is in **English, Portuguese and Spanish** (it follows your system language; you can
change it in **Settings**, the gear icon).

## What you can do

| | |
|---|---|
| <img src="docs/imagens/en/ignissor.webp" width="420" alt="Ignissor"><br>**Multiband compressor (Ignissor)**: band curves, draggable Threshold and Level, Solo and Mute, a compression curve per band | <img src="docs/imagens/en/entropia.webp" width="420" alt="Entropia"><br>**Multiband drive (Entropia)**: Drive Type and Drive Mode like on the pedal, a waveform that saturates with the drive |
| <img src="docs/imagens/en/templates.webp" width="420" alt="Templates"><br>**Templates**: Darkglass's own plus starting points from the app, applied live with undo | <img src="docs/imagens/en/axioma.webp" width="420" alt="Axioma"><br>**Axioma Mono Synth**: oscillators, filter and envelope drawn live |
| <img src="docs/imagens/en/gabinete.webp" width="420" alt="Cabinet"><br>**Cabinets**: model photo, microphone and position, with a searchable gallery | <img src="docs/imagens/en/explicacao.webp" width="420" alt="Parameter explanation"><br>**Every control explained**: rest the mouse on its name to see what it does to the sound on that pedal |

<p align="center"><img src="docs/imagens/en/celular.webp" width="260" alt="On a phone"><br><em>On a phone (Android) the chain becomes a compact grid.</em></p>

Also: a parallel row with Split and Merge, move/clone/swap presets and banks, clear a preset, export
and import JSON, the Factory area (36 Darkglass presets, read-only) and local AI via MCP.

## How to install

There's no installer: it's a folder you extract and open. Every version is in
**[Releases › latest](https://github.com/jordaobass/anagram_app/releases/latest)**: download the zip
for your system under **Assets**. (The green **Code** button downloads the source code, not the app.)

### Windows 10 or 11 (64-bit)

1. Download `anagram-app-windows-<version>.zip` from **Assets** in the
   [latest release](https://github.com/jordaobass/anagram_app/releases/latest).
2. In your Downloads folder, right-click the zip and choose **Extract All…**. Don't run the app from
   inside the zip: it needs the other files in the folder.
3. Move the **Anagram App** folder wherever you like (e.g. `Documents`) and open **Anagram App.exe**.
4. The first time, Windows may show **"Windows protected your PC"**, because the app isn't signed yet.
   Click **More info › Run anyway**. This only shows up once.
5. To find it easily later: right-click `Anagram App.exe` › **Show more options › Send to › Desktop
   (create shortcut)**, or **Pin to Start**.

Keep all the files together in the folder: `hidapi.dll` talks to the pedal over USB, and the
`vcruntime`/`msvcp` files let the app open on PCs without the Visual C++ runtime.

- **Update:** close the app, delete the old folder and extract the new one in its place. Presets live on
  the pedal, not in the app, so nothing is lost.
- **Uninstall:** delete the folder (and the shortcut, if you made one). The app writes nothing to the
  registry.

### macOS (Apple Silicon, M1 or newer)

1. Download `anagram-app-macos-<version>.zip` from **Assets** in the
   [latest release](https://github.com/jordaobass/anagram_app/releases/latest) and double-click it to
   extract.
2. Drag **Anagram App** to **Applications**.
3. The first time, macOS blocks it because the app isn't notarized yet: open **System Settings ›
   Privacy & Security** and click **Open Anyway**. Or, in Terminal:
   `xattr -dr com.apple.quarantine "/Applications/Anagram App.app"`.

### Linux

There's no ready-made build yet; build it from source (see [the app README](mobile/README.md)). Install
`libhidapi-hidraw0` and a udev rule that gives your user access to the Anagram's USB device.

### Connecting to the pedal for the first time

1. **Close the Darkglass Suite** (and any browser tab connected to the Anagram): only one program at a
   time can talk to it.
2. On the pedal, open the **MIDI** settings and turn on **USB MIDI**. That's how the app switches slots
   when you click a preset; without it the app can only preview a preset while the pedal stays on its
   own slot.
3. Connect the Anagram to your computer with the USB cable, open the app and click **Connect over USB**.
   The top bar shows the firmware version once connected.
4. Click a preset in the list to open it. To build the chain, use the **+** in an empty slot (it opens
   the effects library) and drag blocks to change their order. **Save** writes it to the slot.

No pedal? **Open demo** simulates an Anagram in memory so you can explore the app.

## Local AI via MCP (optional, desktop only)

The app can take requests from an AI assistant running on your own computer (LM Studio, Claude Desktop
or any other MCP client): *"make the low end fuller"*, *"build me a slap tone"*. The AI reads the open
preset and adjusts the blocks; every change is **heard immediately**, shows up on screen and stays
**unsaved**. Nothing is written to the pedal unless you confirm it in the app.

1. Open **Settings** (gear icon in the top bar) and turn on **Allow AI via MCP**. The app then listens
   only on your own computer, at `http://127.0.0.1:8765/mcp`, and requires the token shown there.
2. Click **Copy configuration for** your client and paste it into its MCP file. In LM Studio
   (`mcp.json`):

   ```json
   {
     "mcpServers": {
       "anagram": {
         "url": "http://127.0.0.1:8765/mcp",
         "headers": { "Authorization": "Bearer <token from Settings>" }
       }
     }
   }
   ```

   Claude Desktop only speaks stdio, so the copied configuration uses the bridge
   `npx -y mcp-remote <url> --transport http-only --header "Authorization: Bearer <token>"`.
3. Open a preset in the app and talk to the AI.

> **The AI can't hear the sound**: it adjusts based on what you describe, and you tell it whether it
> got better. Small models tend to describe what they would do instead of calling the tools; prefer a
> model with good tool calling. Tools: `get_current_preset`, `list_block_types`, `set_parameter`,
> `set_block_enabled`, `select_scene`, `add_block`, `move_block`, `remove_block`, `choose_cabinet`,
> `undo` and `save_preset`.

## Repository layout

| Folder | What's in it |
|---|---|
| [`mobile/`](mobile/) | The Flutter app (all platforms): code, tests, reference screenshots and tools. Start with [the app README](mobile/README.md). |
| [`docs/`](docs/) | [`DECISOES.md`](docs/DECISOES.md), the single log of product and technical decisions (open and closed, with dates and where they landed). |

The code, comments and internal docs are written in Portuguese (pt-BR), where the project started.

## Quick start

```bash
cd mobile
flutter pub get
flutter test          # protocol, failure modes, end-to-end paths and screenshots
flutter run -d macos  # or windows, linux, chrome, a connected Android device
```

No pedal? **Open demo** simulates an Anagram in memory.

## Third-party art

The block art, cabinet photos and factory presets belong to **Darkglass Electronics** (the same ones
the pedal shows on its screen). They live in `mobile/assets/blocos_terceiros/` and are **published with
Darkglass's permission**. Images are downsized (max 256 px, compressed PNG) and regenerated from the
Darkglass Suite by `mobile/ferramentas/baixar_arte_pedaleira.py`;
`mobile/ferramentas/verificar_release.sh` rejects any file in that folder that isn't this art.
Darkglass Marketplace plugins use each product's public store image, credited to its maker on the
About screen (`mobile/ferramentas/baixar_arte_marketplace.py`); TONE3000 factory tones show their
photo from the Suite. Internal utilities (tuner, mixer, meters, MIDI…) get icons drawn by the app.

## Contributing

Issues, ideas and pull requests are welcome, in English, Portuguese or Spanish. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) to run the project, report bugs and send PRs.

## Credits and license

USB protocol, block catalog and example presets ported from
[anagram-tone-maker](https://github.com/basster6/anagram-tone-maker) (MIT). Project license:
[MIT](LICENSE). The block art is © Darkglass Electronics, used with permission, and is not covered by
the MIT license.
