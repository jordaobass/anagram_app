# Anagram App

Editor de presets **gratuito e open source** para a pedaleira de baixo **Darkglass Anagram**:
lista de presets por banco, cadeia de blocos, knobs grandes, cenas e edição ao vivo pelo USB.
Um código Flutter só para macOS, Windows, Linux, Android e navegador (Chrome/Edge).

> **App não oficial, sem vínculo com a Darkglass Electronics.** Anagram é marca do fabricante.

Sem anúncios, sem telemetria e sem chamadas de rede: o app só conversa com a pedaleira pelo USB.

## Como instalar

O app não tem instalador: é uma pasta que você extrai e abre. Todas as versões ficam em
**[Releases › última versão](https://github.com/jordaobass/anagram_app/releases/latest)**.

### Windows 10 ou 11 (64 bits)

1. Abra a [última versão](https://github.com/jordaobass/anagram_app/releases/latest) e, em **Assets**,
   baixe `anagram-app-windows-<versão>.zip`.
2. Na pasta Downloads, clique com o botão direito no zip e escolha **Extrair Tudo…**. Não abra o app de
   dentro do zip: ele precisa dos outros arquivos da pasta.
3. Mova a pasta **Anagram App** para onde quiser (ex. `Documentos`) e abra **Anagram App.exe**.
4. Na primeira vez, o Windows pode mostrar **"O Windows protegeu o computador"**, porque o app ainda não
   é assinado. Clique em **Mais informações › Executar assim mesmo**. Isso só aparece uma vez.
5. Para achar fácil depois: botão direito em `Anagram App.exe` › **Mostrar mais opções › Enviar para ›
   Área de trabalho (criar atalho)**, ou **Fixar em Iniciar**.

Mantenha todos os arquivos juntos na pasta: a `hidapi.dll` é quem fala com a pedaleira pelo USB, e as
`vcruntime`/`msvcp` fazem o app abrir em PCs sem o runtime do Visual C++.

- **Atualizar:** feche o app, apague a pasta antiga e extraia a nova no lugar. Os presets ficam na
  pedaleira, não no app, então nada se perde.
- **Desinstalar:** apague a pasta (e o atalho, se criou). O app não grava nada no registro.

### macOS (Apple Silicon, M1 ou mais novo)

1. Baixe o zip do macOS na [última versão](https://github.com/jordaobass/anagram_app/releases/latest)
   (quando houver build para a versão) e dê dois cliques para extrair.
2. Arraste **Anagram App** para **Aplicativos**.
3. Na primeira vez, o macOS bloqueia porque o app ainda não é notarizado: abra **Ajustes do Sistema ›
   Privacidade e Segurança** e clique em **Abrir Mesmo Assim**. Ou, no Terminal:
   `xattr -dr com.apple.quarantine "/Applications/Anagram App.app"`.

### Linux

Ainda não há build pronto; compile pelo [README do app](mobile/README.md#desenvolvimento). Instale a
`libhidapi-hidraw0` e uma regra udev que dê acesso ao USB da Anagram ao seu usuário.

### Primeira conexão com a pedaleira

1. **Feche o Darkglass Suite** (e qualquer aba do navegador conectada à Anagram): só um programa por vez
   fala com ela.
2. Na pedaleira, abra os ajustes de **MIDI** e ligue o **USB MIDI**. É por ele que o app troca de slot
   quando você toca num preset; sem ele, o app só deixa ouvir o preset sem a pedaleira mudar de slot.
3. Ligue a Anagram no computador pelo cabo USB, abra o app e clique em **Conectar pelo USB**. A barra de
   cima mostra o firmware quando conecta.
4. Toque num preset da lista para abrir. Para montar a cadeia, use o **+** de uma casa vazia (abre a
   biblioteca de efeitos) e arraste os blocos para mudar a ordem. **Salvar** grava no slot.

Sem pedaleira, **Abrir demonstração** simula uma Anagram em memória para você conhecer o app.

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
