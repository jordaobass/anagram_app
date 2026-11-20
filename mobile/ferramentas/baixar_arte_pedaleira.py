#!/usr/bin/env python3
"""Traz a arte que a própria pedaleira mostra (par ligado/desligado por uri) para
assets/blocos_terceiros/ e acrescenta essas entradas ao indice.json.

A arte é da Darkglass Electronics e vem no Darkglass Suite
(assets/devices/anagram/effects). Como as miniaturas de anagramanswers.com, ela
NÃO vai para o repositório nem para as lojas sem autorização (docs/DECISOES.md, A9).

A tabela uri -> [ligado, desligado] é a publicada pelo anagramcontrol.online.
As imagens vêm da pasta do Suite, se informada; senão, da cópia daquele site.

Uso:
  python3 ferramentas/baixar_arte_pedaleira.py [pasta-effects-do-Darkglass-Suite]
"""
import json
import pathlib
import re
import sys
import urllib.request

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / 'assets' / 'blocos_terceiros'
INDICE = DESTINO / 'indice.json'
CATALOGO = RAIZ / 'assets' / 'referencia' / 'blocks-factory.json'
SITE = 'https://anagramcontrol.online/'
TABELA = SITE + 'src/block-images.js'
PREFIXO = 'dg_'
CREDITO = 'Imagens: Darkglass Electronics (arte da pedaleira) e anagramanswers.com'


def baixar(url):
    pedido = urllib.request.Request(url, headers={'User-Agent': 'anagram-app-ferramentas'})
    with urllib.request.urlopen(pedido, timeout=30) as resposta:
        return resposta.read()


def ler_tabela():
    """uri -> (ligado, desligado), lida do objeto BLOCK_IMAGES do site."""
    texto = baixar(TABELA).decode()
    corpo = re.search(r'BLOCK_IMAGES = (\{.*?\n\});', texto, re.S).group(1)
    return {uri: tuple(par) for uri, par in json.loads(corpo).items()}


def trazer_imagem(relativo, pasta_suite):
    nome = pathlib.Path(relativo).name
    destino = DESTINO / f'{PREFIXO}{nome}'
    if not destino.exists():
        origem = pasta_suite / nome if pasta_suite else None
        conteudo = origem.read_bytes() if origem and origem.exists() else baixar(SITE + 'assets/blocks/' + relativo)
        destino.write_bytes(conteudo)
    return f'assets/blocos_terceiros/{destino.name}'


def main(pasta_suite):
    fabrica = json.loads(CATALOGO.read_text())['blocks']
    indice = json.loads(INDICE.read_text()) if INDICE.exists() else {'blocos': {}}
    blocos = {chave: valor for chave, valor in indice['blocos'].items() if not chave.startswith(PREFIXO)}
    DESTINO.mkdir(parents=True, exist_ok=True)
    for uri, (ligado, desligado) in ler_tabela().items():
        chave = PREFIXO + re.sub(r'[^A-Za-z0-9]+', '_', uri)
        bloco = fabrica.get(uri.split('#')[0]) or fabrica.get(uri) or {}
        blocos[chave] = {'nome': bloco.get('name', ''), 'categoria': bloco.get('category', ''),
                         'arquivo': trazer_imagem(ligado, pasta_suite),
                         'arquivoDesligado': trazer_imagem(desligado, pasta_suite),
                         'uris': [uri], 'origem': 'pedaleira'}
    indice.update({'origem': 'Arte da pedaleira (Darkglass Suite) e fichas de anagramanswers.com; '
                             'autorização pendente antes de publicar.', 'credito': CREDITO, 'blocos': blocos})
    INDICE.write_text(json.dumps(indice, ensure_ascii=False, indent=1))
    total = sum(1 for chave in blocos if chave.startswith(PREFIXO))
    print(f'{total} blocos com arte da pedaleira em {DESTINO}')


if __name__ == '__main__':
    if len(sys.argv) > 2:
        sys.exit(__doc__)
    main(pathlib.Path(sys.argv[1]) if len(sys.argv) == 2 else None)
