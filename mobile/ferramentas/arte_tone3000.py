#!/usr/bin/env python3
"""Fotos dos tons de fábrica do TONE3000 e ícones por tipo de equipamento, como
o Darkglass Suite mostra nos blocos TONE3000 (função rQe do renderer.prod.js).

No Suite (resources/assets/devices/anagram/t3k/):
  factory-data/<id>/tone.<ext>  a foto do tom de fábrica <id>
  factory-data/<id>/*.json      o tom no TONE3000: "title" e "gear"
  <gear>.png                    ícone por tipo (amp, amp-cab, cab, pedal, ...)

O bloco grava o caminho do tom em properties["1"].value; a pasta do arquivo é o
<id>. Daqui sai a seção "tone3000" do indice.json:
  {"tons": {"<id>": {"titulo", "gear", "foto"}}, "porGear": {"<gear>": asset}, "credito"}
As imagens vão reduzidas como a arte da pedaleira (DECISOES A16, A17), com o
prefixo t3k_. A foto de um tom do USUÁRIO não vem daqui: o app a lê, no
computador, da pasta do Suite instalado (t3k/neural-models-t3k/<id>/tone.jpg).

Uso:
  python3 ferramentas/arte_tone3000.py --suite <resources/assets do Suite>
"""
import argparse
import json
import pathlib

import arte_suite

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / 'assets' / 'blocos_terceiros'
INDICE = DESTINO / 'indice.json'
PREFIXO = 't3k_'
CREDITO = 'Fotos dos tons de fábrica: TONE3000 (via Darkglass Suite)'
# o ícone animado é o "sem tom" do Suite; o app usa a arte do bloco no lugar dele
ICONE_PADRAO = 'Tone3000-default-animated.png'


def _tom(pasta, destino):
    """(id, entrada) de um tom de fábrica; None sem o json do TONE3000."""
    descricoes = sorted(pasta.glob('*.json'))
    if not descricoes or not pasta.name.isdigit():
        return None
    descricao = json.loads(descricoes[0].read_text(encoding='utf-8'))
    entrada = {'titulo': descricao.get('title') or pasta.name, 'gear': descricao.get('gear')}
    fotos = sorted(pasta.glob('tone.*'))
    if fotos:
        entrada['foto'] = arte_suite.copiar(fotos[0], destino, f'{PREFIXO}{pasta.name}{fotos[0].suffix.lower()}')
    return pasta.name, entrada


def montar_secao(assets, destino=DESTINO):
    """A seção "tone3000" do indice.json, copiando as imagens para [destino]."""
    t3k = assets / 'devices' / 'anagram' / 't3k'
    tons = dict(filter(None, (_tom(pasta, destino) for pasta in sorted((t3k / 'factory-data').iterdir()))))
    por_gear = {icone.stem: arte_suite.copiar(icone, destino, f'{PREFIXO}gear_{icone.name}')
                for icone in sorted(t3k.glob('*.png')) if icone.name != ICONE_PADRAO}
    return {'credito': CREDITO, 'tons': tons, 'porGear': por_gear}


def main(assets):
    indice = json.loads(INDICE.read_text(encoding='utf-8'))
    indice['tone3000'] = montar_secao(assets)
    INDICE.write_text(json.dumps(indice, ensure_ascii=False, indent=1), encoding='utf-8')
    secao = indice['tone3000']
    print(f"{len(secao['tons'])} tons de fábrica e {len(secao['porGear'])} ícones por tipo em {DESTINO}")


if __name__ == '__main__':
    argumentos = argparse.ArgumentParser(usage=__doc__)
    argumentos.add_argument('--suite', type=pathlib.Path, required=True, help='resources/assets do Darkglass Suite')
    main(argumentos.parse_args().suite)
