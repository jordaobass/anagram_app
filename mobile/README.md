# Anagram App

Editor de presets **gratuito e open source** para a pedaleira de baixo **Darkglass Anagram**, no
estilo do Line 6 HX Edit: lista de presets por banco, cadeia de blocos em grade, parâmetros em
knobs grandes, cenas como snapshots, edição ao vivo e "Salvar no slot" separado. Flutter
multiplataforma.

> **App não oficial, sem vínculo com a Darkglass Electronics.** Anagram é marca do fabricante.

Sem anúncios, sem compras no app, sem telemetria e sem coleta de dados: o app só conversa com a
pedaleira pelo USB e não faz nenhuma chamada de rede.

Autor: **jordao_bass** · Licença: [MIT](../LICENSE) · Publicado nas lojas por Nexttag.

## Plataformas

| Plataforma | Como fala com a pedaleira | Estado |
|---|---|---|
| macOS | IOKit (`macos/Runner/CanalHidAnagram.swift`) | build de release roda; sem teste com aparelho |
| Windows | hidapi por FFI (`hidapi.dll` ao lado do .exe) | build de release roda e a `hidapi.dll` enumera o USB; sem teste com aparelho |
| Android | USB Host (`android/.../CanalHidAndroid.kt`), pede permissão | APK de release compila (R8); sem teste com aparelho |
| Web | WebHID (Chrome/Edge no computador) | compila (`flutter build web`); sem teste com aparelho |
| Linux | hidapi por FFI (instale `libhidapi-hidraw0` e uma regra udev para o USB da Anagram) | não compilado ainda |
| iPhone / iPad | indisponível (exige DriverKit); só modo demonstração | — |

Feche o **Darkglass Suite** antes de conectar: só um programa por vez controla a pedaleira.

## Testar com a pedaleira

1. Feche o Darkglass Suite (e qualquer aba do navegador conectada à Anagram).
2. Ligue a Anagram, **ative o USB MIDI nos ajustes de MIDI dela** (é por ele que o app troca de
   slot com Program Change) e conecte o cabo USB.
3. Abra o app e toque em **Conectar**. A barra de cima mostra o firmware quando conecta.
4. Toque num preset da lista: a pedaleira troca para esse slot (sem USB MIDI o app avisa que é só
   audição). Gire um knob e ouça.
   Com **Ao vivo** desligado, a edição fica só no app.
5. **Salvar** (Cmd/Ctrl+S) grava no slot aberto. **Salvar como…** (Cmd/Ctrl+Shift+S) deixa escolher
   o destino na lista; se ele já tem outro preset, o app pede confirmação.

Sem pedaleira, **Abrir demonstração** simula uma Anagram em memória.

## Desenvolvimento

Sem Flutter instalado, os comandos rodam no container `ghcr.io/cirruslabs/flutter:3.41.7`.

```bash
cd mobile
docker run --rm -v "$PWD":/p -w /p ghcr.io/cirruslabs/flutter:3.41.7 sh -c \
  'flutter pub get && flutter analyze && flutter test'
# rotas tipadas (go_router_builder), depois de mudar lib/apresentacao/rotas.dart:
#   dart run build_runner build --delete-conflicting-outputs
# capturas (goldens) das telas principais, só com a arte própria:
#   flutter test test/capturas --update-goldens
# variante local com as miniaturas de terceiros (vai para test/capturas/goldens_terceiros/, ignorada):
#   COM_MINIATURAS=1 flutter test test/capturas --update-goldens
docker run --rm -v "$PWD":/p alpine chown -R 1000:1000 /p   # o container escreve como root
```

macOS e iOS (no Mac, sem CocoaPods — plugins por Swift Package Manager):

```bash
flutter build macos --debug
flutter build ios --debug --no-codesign
```

O canal MIDI do macOS e do iOS é um arquivo só, `apple_compartilhado/CanalMidiAnagram.swift`,
referenciado pelos dois projetos Xcode.

Windows (Visual Studio Build Tools com a carga C++ e Modo de Desenvolvedor ligado, que o Flutter
exige para os plugins): `flutter build windows --release` e copie a `hidapi.dll` x64 da
[release da hidapi](https://github.com/libusb/hidapi/releases) para junto do `.exe`.

Android: o release é assinado pelo keystore descrito em `android/key.properties` (fora do git:
`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). Sem esse arquivo, o Gradle avisa e assina
com a chave de debug, que serve para testar mas não para a Play.

Bancada contra a pedaleira real (no Mac, com a Anagram plugada e o Darkglass Suite fechado):

```bash
flutter test integration_test/bancada_test.dart -d macos
# escrita (grava num slot vazio, relê e apaga): --dart-define=BANCADA_ESCRITA=1
# Program Change para um slot: --dart-define=BANCADA_MIDI=17A
```

## Publicar (release)

Publique **sempre de um clone limpo** (`git clone`), nunca da pasta de trabalho: o Flutter embarca
tudo o que estiver em `assets/blocos_terceiros/`, e as miniaturas de terceiros não podem ir para as
lojas. Antes de cada build de release:

```bash
ferramentas/verificar_release.sh && flutter build <plataforma> --release
```

O script falha (código 1) se houver qualquer arquivo além do `LEIAME.txt` nessa pasta.

## Estrutura

As camadas só dependem para dentro: `apresentacao` → `aplicacao` → `dados` → `nucleo`, e
`plataforma` implementa os contratos do `nucleo` e só a `aplicacao` escolhe qual usar. O `nucleo` é
Dart puro (não importa Flutter).

- `lib/nucleo/` — protocolo (quadros HID, `ClienteAnagram`, `ApiAnagram`, erros), modelo de preset
  que preserva campos desconhecidos, catálogo de blocos, MIDI e a pedaleira de demonstração, que
  fala o protocolo real em memória.
- `lib/dados/` — `RepositorioPedaleira`, que converte toda falha em `Resultado` (nada de exceção
  solta para a interface), e arquivos de preset.
- `lib/aplicacao/` — estado (Riverpod), casos de uso (`SalvarNoSlot`, `TransferirPreset`) e índice
  da arte.
- `lib/plataforma/` — transportes reais: canal nativo (IOKit/USB Host), hidapi por FFI, WebHID, MIDI.
- `lib/apresentacao/` — telas, componentes e o tema; toda cor e medida vem de `tema/tokens.dart`.
- `apple_compartilhado/`, `android/.../kotlin/`, `macos/Runner/` — canais nativos de USB e MIDI.
- `test/` — núcleo, modos de falha, caminho quente ponta a ponta e capturas de referência;
  `integration_test/` — app real e bancada contra a pedaleira.

Decisões e pendências: `../docs/DECISOES.md`.

## Créditos

- Protocolo USB, catálogo de blocos e presets de exemplo: portados do projeto
  [anagram-tone-maker](https://github.com/basster6/anagram-tone-maker), de basster6 — licença MIT
  (`assets/referencia/LICENCA-anagram-tone-maker-MIT.txt`).
- Arte dos blocos: própria, por categoria. Miniaturas de anagramanswers.com podem ser usadas
  localmente (pasta opcional `assets/blocos_terceiros/`, fora do git, gerada por
  `ferramentas/gerar_miniaturas.py`); elas **não** vão para o repositório nem para as lojas até
  haver autorização. O app compila e funciona sem elas.
- Arte da própria pedaleira (Darkglass Electronics, a que o Darkglass Suite mostra, com versão
  ligada e desligada): mesmo regime, na mesma pasta, gerada por
  `python3 ferramentas/baixar_arte_pedaleira.py [pasta-effects-do-Suite]`. Quando existe, vence a
  miniatura de terceiros e o bloco em bypass mostra a imagem "desligado" da pedaleira.
- Fontes: Barlow e Saira Stencil (OFL), Permanent Marker (Apache 2.0) — licenças em `assets/fontes/`.
