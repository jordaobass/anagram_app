#!/usr/bin/env python3
"""Arte dos plugins do Darkglass Marketplace (os blocos que se compram ou
baixam à parte: Nembrini, Cognate, falkTX, ...), pela API pública da loja.

Cada produto traz, em variants[].sku, a uri do plugin (a mesma que a pedaleira
grava no preset) e, em images, as fotos: a primeira é a arte do bloco, as
outras são capturas da tela. A imagem é pública e gratuita; o uso foi
autorizado pelo dono do projeto com crédito ao fabricante (DECISOES A17).

Saída em assets/blocos_terceiros/: mk_<uri>.png (no máximo 256 px de lado e
comprimida com pngquant, como a arte da pedaleira, A16), as entradas
"mk_…" do indice.json (origem "marketplace") e a seção "marketplace" com o
crédito aos fabricantes. A arte da própria pedaleira vence na mesma uri.

Uso:
  python3 ferramentas/baixar_arte_marketplace.py
"""
import json
import pathlib
import re
import shutil
import subprocess
import tempfile
import urllib.request

import arte_suite

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / 'assets' / 'blocos_terceiros'
INDICE = DESTINO / 'indice.json'
API = 'https://api-v2.darkglass.com/shopify/products?pageSize=200'
PREFIXO = 'mk_'
ORIGEM = 'marketplace'


def baixar(url):
    pedido = urllib.request.Request(url, headers={'User-Agent': 'anagram-app-ferramentas'})
    with urllib.request.urlopen(pedido, timeout=60) as resposta:
        return resposta.read()


def ler_produtos(texto):
    """[(uri, título, categoria, fabricante, url da arte)] dos produtos com uri de plugin."""
    produtos = []
    for aresta in json.loads(texto)['data']['edges']:
        no = aresta['node']
        imagens = [imagem['node']['url'] for imagem in no['images']['edges']]
        for variante in no['variants']['edges']:
            uri = (variante['node'].get('sku') or '').strip()
            if ':' in uri and imagens:
                produtos.append((uri, no['title'], no.get('productType', ''), no.get('vendor', ''), imagens[0]))
    return produtos


def nome_do_arquivo(uri):
    """mk_ + a uri sem o esquema, só com letras, números e "_": previsível pela uri."""
    return PREFIXO + re.sub(r'[^A-Za-z0-9]+', '_', re.sub(r'^[a-z]+://', '', uri)).strip('_') + '.png'


def trazer_arte(url, nome):
    destino = DESTINO / nome
    if destino.exists():
        return destino
    with tempfile.TemporaryDirectory() as pasta:
        original = pathlib.Path(pasta) / 'original.png'
        # a CDN da loja já reduz pela largura; a cópia em tamanho de ícone garante o limite
        original.write_bytes(baixar(f'{url}&width={arte_suite.LADO_MAXIMO}' if '?' in url else url))
        arte_suite.copiar(original, DESTINO, nome)
    _comprimir(destino)
    return destino


def _comprimir(arquivo):
    """pngquant 80–95, como na A16; sem ele, fica o PNG reduzido."""
    if not shutil.which('pngquant'):
        print(f'aviso: sem pngquant, {arquivo.name} vai só reduzido')
        return
    subprocess.run(['pngquant', '--quality=80-95', '--force', '--skip-if-larger', '--ext', '.png', str(arquivo)],
                   check=False)


def entradas(produtos, ja_tem):
    blocos, fabricantes = {}, set()
    for uri, titulo, categoria, fabricante, url in produtos:
        if uri.split('#')[0] in ja_tem:
            continue
        nome = nome_do_arquivo(uri)
        trazer_arte(url, nome)
        blocos[nome[:-len('.png')]] = {'nome': titulo, 'categoria': categoria,
                                       'arquivo': f'assets/blocos_terceiros/{nome}', 'arquivoDesligado': None,
                                       'uris': [uri], 'origem': ORIGEM, 'fabricante': fabricante}
        fabricantes.add(fabricante)
    return blocos, sorted(fabricantes, key=str.lower)


def main():
    indice = json.loads(INDICE.read_text(encoding='utf-8'))
    blocos = {chave: bloco for chave, bloco in indice['blocos'].items() if bloco.get('origem') != ORIGEM}
    ja_tem = {uri.split('#')[0] for bloco in blocos.values() if bloco.get('origem') == 'pedaleira'
              for uri in bloco['uris']}
    novos, fabricantes = entradas(ler_produtos(baixar(API)), ja_tem)
    indice['blocos'] = {**blocos, **novos}
    indice['marketplace'] = {'credito': 'Imagens dos plugins do Darkglass Marketplace: ' + ', '.join(fabricantes),
                             'fabricantes': fabricantes}
    INDICE.write_text(json.dumps(indice, ensure_ascii=False, indent=1), encoding='utf-8')
    print(f'{len(novos)} plugins do marketplace com arte, de {len(fabricantes)} fabricantes, em {DESTINO}')


if __name__ == '__main__':
    main()
