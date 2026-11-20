# Anagram App

Editor de presets **gratuito e open source** para a pedaleira de baixo **Darkglass Anagram**:
lista de presets por banco, cadeia de blocos, knobs grandes, cenas e edição ao vivo pelo USB.
Um código Flutter só para macOS, Windows, Linux, Android e navegador (Chrome/Edge).

> **App não oficial, sem vínculo com a Darkglass Electronics.** Anagram é marca do fabricante.

Sem anúncios, sem telemetria e sem chamadas de rede: o app só conversa com a pedaleira pelo USB.

## Download

**[Baixar a última versão](https://github.com/jordaobass/anagram_app/releases/latest)**: os zips de cada
sistema ficam na página da versão.

- **Windows 10/11 (64 bits):** extraia o zip e abra `Anagram App.exe`. Não há instalador. Mantenha os
  arquivos juntos: a `hidapi.dll` da pasta é quem fala com a pedaleira pelo USB. O app ainda não é
  assinado, então na primeira vez o Windows pode mostrar "O Windows protegeu o computador": clique em
  **Mais informações › Executar assim mesmo**.
- **macOS (Apple Silicon):** arraste o app para Aplicativos. Ainda não é notarizado; na primeira vez,
  libere em **Ajustes do Sistema › Privacidade e Segurança › Abrir Mesmo Assim**.

Antes de conectar, feche o **Darkglass Suite** (só um programa por vez fala com a Anagram) e, para o app
trocar de slot, ligue o **USB MIDI** nos ajustes de MIDI da pedaleira. Sem pedaleira, use
**Abrir demonstração**.

> Os builds publicados usam a arte própria do app. A arte da Darkglass não vai junto (veja
> [Arte de terceiros](#arte-de-terceiros)).

## Organização do repositório

| Pasta | O que tem |
|---|---|
| [`mobile/`](mobile/) | O app Flutter (todas as plataformas): código, testes, capturas de referência e ferramentas. Comece pelo [README do app](mobile/README.md). |
| [`docs/`](docs/) | [`DECISOES.md`](docs/DECISOES.md), o registro único das decisões de produto e técnicas (abertas e fechadas, com data e onde aterrissaram), e a pesquisa de referência de interface. |

## Começo rápido

```bash
cd mobile
flutter pub get
flutter test          # núcleo, modos de falha, caminho ponta a ponta e capturas
flutter run -d macos  # ou windows, linux, chrome, um Android conectado
```

Sem pedaleira, o botão **Abrir demonstração** simula uma Anagram em memória.

## Arte de terceiros

O app compila e funciona só com a arte própria. As miniaturas de anagramanswers.com e a arte da
própria pedaleira (Darkglass) podem ser baixadas para uso local em `mobile/assets/blocos_terceiros/`,
que fica **fora do git**; o build de release recusa publicar com elas (`mobile/ferramentas/verificar_release.sh`).
Detalhes nas decisões A1, A2 e A9 de [`docs/DECISOES.md`](docs/DECISOES.md).

## Créditos e licença

Protocolo USB, catálogo de blocos e presets de exemplo portados do
[anagram-tone-maker](https://github.com/basster6/anagram-tone-maker) (MIT). Licença do projeto:
[MIT](LICENSE).
