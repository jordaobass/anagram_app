#!/usr/bin/env python3
"""Copia as miniaturas de blocos (de terceiros) para assets/blocos_terceiros/ e gera o índice.

As imagens NÃO vão para o repositório (ver .gitignore e docs/DECISOES.md, A2): a publicação
depende de autorização de anagramanswers.com. Sem elas o app usa a arte própria por categoria.

Uso:
  python3 ferramentas/gerar_miniaturas.py <pasta-com-png> <blocos.json>
Exemplo (site Bass Eras do autor):
  python3 ferramentas/gerar_miniaturas.py ../../anagram/frontend/src/assets/blocos \\
      ../../anagram/frontend/src/data/blocos.json
"""
import json
import pathlib
import re
import shutil
import sys

RAIZ = pathlib.Path(__file__).resolve().parent.parent
DESTINO = RAIZ / 'assets' / 'blocos_terceiros'
CATALOGO = RAIZ / 'assets' / 'referencia' / 'blocks-factory.json'

# casamentos que o nome sozinho não resolve (conferidos à mão no catálogo de fábrica)
MANUAL = {
    'axioma': ['urn:darkglass:axioma_synth'], 'b3k': ['urn:darkglass:B3K'],
    'eq6': ['urn:darkglass:DarkglassGEQ'], 'fet': ['urn:darkglass:FETComp'],
    'isobrick': ['urn:darkglass:neural-plugins:modern-california-cln'],
    'moerfr': ['urn:darkglass:moerfer'], 'ns': ['urn:darkglass:Suppressor'],
    'sublemon': ['urn:darkglass:Sublemon'],
    'chorus': ['urn:darkglass:Chorus', 'urn:darkglass:ChorusStereo'],
    'shimmer': ['urn:darkglass:ShimmerReverb', 'urn:darkglass:ShimmerReverbStereo'],
}


def normalizar(texto):
    return re.sub(r'[^a-z0-9]', '', texto.lower())


def main(pasta_png, arquivo_blocos):
    blocos = json.loads(pathlib.Path(arquivo_blocos).read_text())
    fabrica = json.loads(CATALOGO.read_text())['blocks']
    por_nome = {}
    for uri, bloco in fabrica.items():
        por_nome.setdefault(normalizar(bloco['name']), []).append(uri)
    DESTINO.mkdir(parents=True, exist_ok=True)
    indice = {}
    for chave, bloco in blocos.items():
        origem = pathlib.Path(pasta_png) / f'{chave}.png'
        if not origem.exists():
            continue
        shutil.copy2(origem, DESTINO / origem.name)
        entrada = {'nome': bloco['nome'], 'categoria': bloco['categoria'],
                   'arquivo': f'assets/blocos_terceiros/{origem.name}',
                   'uris': MANUAL.get(chave) or por_nome.get(normalizar(bloco['nome']), [])}
        if bloco.get('ficha'):
            entrada['ficha'] = bloco['ficha']
        indice[chave] = entrada
    saida = {'origem': 'Fichas de anagramanswers.com; autorização pendente antes de publicar.',
             'credito': 'Imagens: anagramanswers.com', 'blocos': indice}
    (DESTINO / 'indice.json').write_text(json.dumps(saida, ensure_ascii=False, indent=1))
    print(f'{len(indice)} miniaturas copiadas para {DESTINO}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
