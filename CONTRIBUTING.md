# Contributing to Anagram App

Thanks for wanting to help! This is a free, open-source editor for the **Darkglass Anagram**, built
by bass players for bass players. Bug reports, ideas and pull requests of any size are welcome.

> The code, comments and docs are written in **Portuguese (pt-BR)** because that's where the project
> started. Issues and pull requests in **English, Portuguese or Spanish** are all fine.

## Reporting a bug

Open an [issue](https://github.com/jordaobass/anagram_app/issues/new/choose) using the **Bug report**
template and include:

- the app version (ⓘ button in the top bar) and your OS;
- your Anagram **firmware version** (shown in the top bar when connected, e.g. `Anagram · USB · v1.19.2.24`);
- what you did, what you expected and what happened;
- a screenshot, and if the bug is about a preset, the preset JSON (**⋮ › Export JSON…** in the preset menu).

Please close the Darkglass Suite before testing: only one program can talk to the pedal over USB.

## Suggesting a feature

Use the **Feature request** template. Tell us the problem you want to solve and, if the feature
exists on the pedal's own screen, a photo of it helps a lot. Several panels in the app (Ignissor,
Entropia) were built from photos of the pedal sent by users.

## Running the project

You need [Flutter 3.41](https://docs.flutter.dev/get-started/install) (or Docker, see below).

```bash
git clone https://github.com/jordaobass/anagram_app.git
cd anagram_app/mobile
flutter pub get
flutter test          # protocol, failure modes, end-to-end paths and screenshots
flutter run -d macos  # or windows, linux, chrome, or a connected Android device
```

No pedal? Click **Abrir demonstração / Open demo**: a simulated Anagram runs in memory and speaks
the real protocol, so almost everything can be developed and tested without hardware.

Without Flutter installed:

```bash
cd mobile
docker run --rm -v "$PWD":/p -w /p ghcr.io/cirruslabs/flutter:3.41.7 sh -c \
  'flutter pub get && flutter analyze && flutter test'
```

## How the code is organized

Layers only depend inwards: `apresentacao` (UI) → `aplicacao` (state, use cases) → `dados`
(repositories) → `nucleo` (pure Dart: USB protocol, preset model, block catalog). `plataforma`
holds the real transports (hidapi on Windows/Linux, IOKit on macOS, USB Host on Android, WebHID).
More details in [`mobile/README.md`](mobile/README.md); design decisions and open questions are in
[`docs/DECISOES.md`](docs/DECISOES.md).

## Pull requests

1. Fork the repo and create a branch from `main` (`feat/...`, `fix/...`, `docs/...`).
2. Keep each PR focused on one thing, with [Conventional Commits](https://www.conventionalcommits.org/)
   messages (`feat:`, `fix:`, `docs:`, `refactor:`…).
3. Add or update tests for the behavior you change; `flutter analyze` and `flutter test` must pass.
   If you change a screen, regenerate its screenshots with `flutter test test/capturas --update-goldens`
   and check them.
4. UI colors and sizes come from `mobile/lib/apresentacao/tema/tokens.dart`; user-facing text goes in
   the three ARB files (`mobile/lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb`).
5. Anything about the pedal's behavior that you **tested on real hardware** is gold: say the firmware
   version and what you observed in the PR.

## Code of conduct

Be kind and assume good intent. We're all here because we like playing bass.

## License

By contributing you agree that your contribution is licensed under the project's [MIT License](LICENSE).
The block art is © Darkglass Electronics and is used with their permission; it is not covered by
the MIT license.
