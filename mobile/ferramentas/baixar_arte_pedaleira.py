#!/usr/bin/env python3
"""Traz a arte que a própria pedaleira mostra (par ligado/desligado por uri) para
assets/blocos_terceiros/ e acrescenta essas entradas ao indice.json.

A arte é da Darkglass Electronics e vem no Darkglass Suite
(assets/devices/anagram/effects). Ela não vai para o repositório; os builds
publicados são feitos com ela, num clone limpo (docs/DECISOES.md, A9 a A12).

A tabela uri -> [ligado, desligado] é a publicada pelo anagramcontrol.online.
As imagens vêm da pasta do Suite, se informada; senão, da cópia daquele site.

Com a instalação do Darkglass Suite (--suite, a pasta resources/assets, e
--renderer, o dist/renderer.prod.js extraído do app.asar), também traz a foto
de cada gabinete pelo arquivo de IR e a arte dos blocos que a tabela do site
não tem (amp, pedal e misc neurais, gabinetes sem IR), e grava os presets de
fábrica em fabrica.json (a área Fábrica do app, DECISOES U18), e as fotos dos
tons de fábrica do TONE3000 (DECISOES A18). Ver ferramentas/arte_suite.py e
ferramentas/arte_tone3000.py.

Uso:
  python3 ferramentas/baixar_arte_pedaleira.py [pasta-effects] [--suite ASSETS --renderer RENDERER_JS]
  # app.asar -> renderer: npx @electron/asar extract app.asar extraido
"""
import argparse
import json
import pathlib
import re
import sys
import urllib.request

import arte_suite
import arte_tone3000

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / 'assets' / 'blocos_terceiros'
INDICE = DESTINO / 'indice.json'
CATALOGO = RAIZ / 'assets' / 'referencia' / 'blocks-factory.json'
SITE = 'https://anagramcontrol.online/'
TABELA = SITE + 'src/block-images.js'
PREFIXO = 'dg_'
CREDITO_PEDALEIRA = 'Imagens: Darkglass Electronics (arte da pedaleira)'
CREDITO_MISTO = CREDITO_PEDALEIRA + ' e anagramanswers.com'


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


def completar_com_suite(blocos, fabrica, assets, renderer):
    """Gabinetes por IR e os blocos que só o Suite tem arte; devolve a seção "gabinetes"."""
    tabelas, modelos, uris = arte_suite.ler_regras(renderer)
    efeitos = assets / 'devices' / 'anagram' / 'effects'
    # a arte do Marketplace não impede a da pedaleira na mesma uri (esta vence)
    ja_tem = {uri for bloco in blocos.values() if bloco.get('origem') != 'marketplace' for uri in bloco.get('uris', [])}
    for uri, (ligada, desligada) in uris.items():
        if uri in ja_tem or not (efeitos / ligada).exists():
            continue
        bloco = fabrica.get(uri.split('#')[0]) or fabrica.get(uri) or {}
        blocos[PREFIXO + re.sub(r'[^A-Za-z0-9]+', '_', uri)] = {
            'nome': bloco.get('name', ''), 'categoria': bloco.get('category', ''),
            'arquivo': arte_suite.copiar(efeitos / ligada, DESTINO, PREFIXO + ligada),
            'arquivoDesligado': arte_suite.copiar(efeitos / desligada, DESTINO, PREFIXO + desligada)
            if (efeitos / desligada).exists() else None,
            'uris': [uri], 'origem': 'pedaleira'}
    return {'porArquivo': arte_suite.montar_gabinetes(tabelas, modelos, assets / 'cabs', DESTINO),
            'escolhas': arte_suite.escolhas_de_gabinete(tabelas)}


def gravar_fabrica(renderer):
    presets = arte_suite.presets_de_fabrica(renderer)
    (DESTINO / 'fabrica.json').write_text(json.dumps(
        {'origem': 'Presets de fábrica da Darkglass Electronics (Darkglass Suite).', 'presets': presets},
        ensure_ascii=False))
    print(f'{len(presets)} presets de fábrica em {DESTINO / "fabrica.json"}')


def main(pasta_suite, assets=None, renderer=None):
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
    if assets and renderer:
        indice['gabinetes'] = completar_com_suite(blocos, fabrica, assets, renderer)
        indice['tone3000'] = arte_tone3000.montar_secao(assets)
        gravar_fabrica(renderer)
    # o crédito diz o que está de fato na pasta: num clone limpo (release, A12)
    # só há a arte da pedaleira; na pasta de trabalho pode haver também as
    # miniaturas de anagramanswers.com (A2)
    # a arte do Marketplace (A17) tem crédito próprio, na seção "marketplace"
    misto = any(not chave.startswith(PREFIXO) and bloco.get('origem') != 'marketplace'
                for chave, bloco in blocos.items())
    indice.update({'origem': 'Arte da pedaleira (Darkglass Suite)' + (' e fichas de anagramanswers.com' if misto else '') + '.',
                   'credito': CREDITO_MISTO if misto else CREDITO_PEDALEIRA, 'blocos': blocos})
    INDICE.write_text(json.dumps(indice, ensure_ascii=False, indent=1))
    total = sum(1 for chave in blocos if chave.startswith(PREFIXO))
    gabinetes = len(indice.get('gabinetes', {}).get('porArquivo', {}))
    print(f'{total} blocos com arte da pedaleira e {gabinetes} arquivos de IR de gabinete em {DESTINO}')


if __name__ == '__main__':
    argumentos = argparse.ArgumentParser(usage=__doc__)
    argumentos.add_argument('pasta_effects', nargs='?', type=pathlib.Path)
    argumentos.add_argument('--suite', type=pathlib.Path, help='resources/assets do Darkglass Suite')
    argumentos.add_argument('--renderer', type=pathlib.Path, help='dist/renderer.prod.js extraído do app.asar')
    lido = argumentos.parse_args()
    if bool(lido.suite) != bool(lido.renderer):
        sys.exit('--suite e --renderer vão juntos.')
    main(lido.pasta_effects, lido.suite, lido.renderer)
