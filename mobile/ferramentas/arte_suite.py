"""Arte que o Darkglass Suite instalado mostra e a tabela do anagramcontrol.online
não traz: a foto de cada gabinete (escolhida pelo arquivo de IR do bloco) e os
blocos neurais/genéricos (amp, pedal, misc, gabinetes sem IR).

O Suite é um app Electron: as imagens ficam em resources/assets/ (cabs/ e
devices/anagram/effects/) e as regras em dist/renderer.prod.js, dentro do
app.asar. Daqui saem três coisas, conferidas no Suite 6.11.4:
  - tabelas ib.qv (bass), ib.hP (guitar) e ib.Rh (artists): arquivo de IR -> modelo;
  - mve(nome, bypass): modelo -> imagem em cabs/ (ligada ou "Bypass-…");
  - "urn:…"===e.uri ? …/effects/<imagem>: uri -> imagem do bloco.
"""
import json
import re
import shutil

PREFIXO_GABINETE = 'dg_cab_'
# sem modelo reconhecido, o Suite mostra o gabinete de vidro
PADRAO_GABINETE = ('Glass-Cabinet.webp', 'Bypass-Glass-Cabinet.webp')

# gabinete sem arquivo de IR escolhido: a imagem genérica do bloco (no Suite,
# a função que trata os gabinetes, não a tabela de uris)
GABINETES_GENERICOS = {
    'urn:darkglass-anagram:cabinet-bass': ('cabinet-bass.png', 'cabinet-bass-Off.png'),
    'urn:darkglass-anagram:cabinet-guitar': ('cabinet-guitar.png', 'cabinet-guitar-Off.png'),
    'urn:darkglass-anagram:cabinet-artists': ('cabinet-artists.png', 'cabinet-artists-Off.png'),
}


def _eh_desligada(arquivo):
    return arquivo.startswith('Bypass-') or re.search(r'-?off\.', arquivo, re.I) is not None


def ler_regras(renderer):
    """(tabelas de IR, modelo -> (ligada, desligada), uri -> (ligada, desligada))."""
    texto = renderer.read_text(encoding='utf-8', errors='replace')
    inicio = texto.index("const ib=JSON.parse('") + len("const ib=JSON.parse('")
    tabelas = json.loads(texto[inicio:texto.index("')", inicio)])
    return tabelas, _modelos(texto), _uris(texto)


def _modelos(texto):
    """Os pares da mve: o mesmo nome aparece uma vez no ramo bypass e uma no ligado."""
    inicio = texto.index('mve=function(e,t){return t?')
    corpo = texto[inicio:texto.index('}', inicio)]
    ligadas, desligadas = {}, {}
    for nome, arquivo in re.findall(r'"([^"]+)"===e\?Gce\+"/cabs/([^"]+)"', corpo):
        (desligadas if _eh_desligada(arquivo) else ligadas)[nome] = arquivo
    return {nome: (arquivo, desligadas.get(nome, arquivo)) for nome, arquivo in ligadas.items()}


def _uris(texto):
    padrao = r'((?:"urn:[^"]+"===e\.uri(?:\|\|)?)+)\?Gce\+"/devices/anagram/effects/([^"/]+)"'
    ligadas, desligadas = {}, {}
    for grupo, arquivo in re.findall(padrao, texto):
        for uri in re.findall(r'"(urn:[^"]+)"', grupo):
            (desligadas if _eh_desligada(arquivo) else ligadas).setdefault(uri, arquivo)
    achadas = {uri: (arquivo, desligadas.get(uri, arquivo)) for uri, arquivo in ligadas.items()}
    return {**GABINETES_GENERICOS, **achadas}


def modelo_do_artista(descricao, modelos):
    """ib.Rh descreve "Jon - 4x10": o Suite tenta o texto até a vírgula e erra;
    aqui também vale "Jon 4x10" e o nome antes do hífen ("Forrester")."""
    base = descricao.split(',')[0].strip()
    for candidato in (base, base.replace(' - ', ' '), base.split(' - ')[0]):
        if candidato in modelos:
            return candidato
    return None


def gabinetes_por_arquivo(tabelas, modelos):
    """Nome do arquivo de IR (sem extensão) -> modelo, nos três tipos de gabinete."""
    porArquivo = {}
    for linha in tabelas.get('qv', []):
        if linha.get('Original file name'):
            porArquivo[linha['Original file name']] = linha.get('Cab listing name', '')
    for linha in tabelas.get('hP', []):
        porArquivo[linha['Filename']] = linha['Cab']
    for linha in tabelas.get('Rh', []):
        porArquivo[linha['Filename']] = modelo_do_artista(linha['Description'], modelos) or ''
    return porArquivo


# O app mostra a arte como ícone (cerca de 70 px na cadeia, 64 no painel);
# 256 px cobre telas de densidade 3x com folga. As fotos de gabinete do Suite
# chegam a 1700 px e, copiadas inteiras, triplicavam o download do app.
LADO_MAXIMO = 256


def copiar(origem, destino_pasta, nome_destino):
    destino = destino_pasta / nome_destino
    if not destino.exists():
        _copiar_em_tamanho_de_icone(origem, destino)
    return f'assets/blocos_terceiros/{nome_destino}'


def _copiar_em_tamanho_de_icone(origem, destino):
    try:
        from PIL import Image
    except ImportError:
        print('aviso: sem Pillow (pip install pillow), a arte vai no tamanho original')
        shutil.copyfile(origem, destino)
        return
    with Image.open(origem) as imagem:
        if max(imagem.size) <= LADO_MAXIMO:
            shutil.copyfile(origem, destino)
            return
        imagem.thumbnail((LADO_MAXIMO, LADO_MAXIMO), Image.LANCZOS)
        if destino.suffix.lower() == '.webp':
            imagem.save(destino, 'WEBP', quality=88, method=6)
        else:
            imagem.save(destino, optimize=True)


def montar_gabinetes(tabelas, modelos, pasta_cabs, destino_pasta):
    """Seção "gabinetes" do indice.json: arquivo de IR -> [ligada, desligada]."""
    def imagens(modelo):
        ligada, desligada = modelos.get(modelo, PADRAO_GABINETE)
        if not (pasta_cabs / ligada).exists() or not (pasta_cabs / desligada).exists():
            ligada, desligada = PADRAO_GABINETE
        return [copiar(pasta_cabs / ligada, destino_pasta, PREFIXO_GABINETE + ligada),
                copiar(pasta_cabs / desligada, destino_pasta, PREFIXO_GABINETE + desligada)]
    return {arquivo: imagens(modelo) for arquivo, modelo in gabinetes_por_arquivo(tabelas, modelos).items()}
