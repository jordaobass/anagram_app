# Product

<!-- impeccable:product-schema 1 -->

> Escrito em 2026-11-05 a partir do pedido do usuário (sem rodada de entrevista: o agente que
> escreveu não tinha ferramenta de pergunta). Fatos marcados **(inferido)** precisam de confirmação.

## Platform

adaptive

Uma única linguagem visual própria (Flutter), com layout adaptado por tamanho de tela
(tablet/desktop paisagem e celular retrato) e convenções de cada sistema onde elas importam
(atalhos de teclado no desktop, botão voltar no Android, pedido de permissão USB no Android).

## Stack

Flutter multiplataforma (decidido pelo usuário): Riverpod, go_router com rotas tipadas, logger.
Núcleo do protocolo em Dart puro.

## Users

Baixista dono de uma Darkglass Anagram. Dois cenários:
- **Bancada**: em casa ou no estúdio, com a pedaleira no USB do Mac/PC/tablet, montando e
  ajustando presets — ouve cada mudança na hora, como no HX Edit.
- **Palco/ensaio**: precisa trocar de preset e cena rápido, com o aparelho no chão e o
  tablet/celular num suporte, iluminação ruim, mãos ocupadas com o instrumento. **(inferido)**

## Product Purpose

Editar e trocar presets da Anagram sem o Darkglass Suite, no estilo do Line 6 HX Edit: lista de
presets por banco, cadeia de blocos em grade, parâmetros em knobs grandes com valores e unidades
reais, cenas como snapshots, edição ao vivo separada de "Salvar no slot". Sucesso = o baixista
monta um timbre ouvindo cada ajuste e grava sem medo de sobrescrever o slot errado.

## Positioning

Gratuito e open source (MIT, autor jordao_bass), sem anúncios, compras no app nem coleta de dados.
A única chamada de rede é a verificação opcional de versão nova no GitHub, que não envia dado
nenhum e pode ser desligada.

Editor nativo multiplataforma (desktop, Android, web) que fala o protocolo HID da própria
pedaleira; não é um site preso a um navegador nem o app oficial.

## Operating Context

- Só um programa controla a pedaleira por vez: o Darkglass Suite precisa estar fechado.
- 126 slots (42 bancos × A/B/C), 2 linhas × 12 blocos, 3 cenas por preset.
- iPhone/iPad não abrem HID de fornecedor sem DriverKit: lá só modo demonstração.
- Modo demonstração em memória para usar sem aparelho.

## Capabilities and Constraints

- Leitura/gravação do JSON real do preset preservando campos desconhecidos.
- Edição ao vivo (`try_anagram_preset`) ligada por padrão, com interruptor "Ao vivo".
- Arte dos blocos: a mesma da tela da pedaleira (Darkglass Electronics), na única versão publicada;
  ilustração própria por categoria só onde a pedaleira não tem imagem (gabinetes, Tuner, utilitários)
  ou rodando do código-fonte sem a arte (docs/DECISOES.md, A9 a A12).
- Não oficial; sem relação com a Darkglass Electronics.

## Brand Commitments

Nome de trabalho "Anagram App" (pasta `anagram-app`, pacote `anagram_app`, definido pelo usuário). Sem logo
nem marca da Darkglass na interface (ícone, nome, telas); a única exceção é a arte dos blocos, que o usuário
decidiu mostrar como a pedaleira mostra (A9 a A12), com crédito à Darkglass Electronics na tela Sobre.
Créditos ao projeto MIT anagram-tone-maker (basster6). A arte não fica no repositório: entra no build de
release. Miniaturas de anagramanswers.com só como pasta local opcional, nunca no build publicado.

## Evidence on Hand

Presets reais de exemplo e catálogo de 99 blocos de fábrica (firmware v1.18.1.23) do
anagram-tone-maker. Nenhum depoimento, métrica de uso ou teste com aparelho real até agora.

## Product Principles

1. O que soa é o que se vê: cada ajuste vai para a pedaleira na hora, e o "não salvo" fica visível.
2. Gravar é um ato deliberado: nunca sobrescrever slot sem confirmação.
3. Legível a um metro de distância: alvos grandes, números grandes, estado de conexão sempre à vista.
4. Funciona sem aparelho: o modo demonstração é cidadão de primeira classe.

## Accessibility & Inclusion

Alvos de toque ≥ 48 dp (com mouse, 32 a 40 px no topo do editor); contraste AA medido nos temas escuro e claro; controles de knob também operáveis por
teclado e por slider. **(inferido)**
