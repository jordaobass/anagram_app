"""Arte que o Darkglass Suite instalado mostra e a tabela do anagramcontrol.online
não traz: a foto de cada gabinete (escolhida pelo arquivo de IR do bloco) e os
blocos neurais/genéricos (amp, pedal, misc, gabinetes sem IR).

O Suite é um app Electron: as imagens ficam em resources/assets/ (cabs/ e
devices/anagram/effects/) e as regras em dist/renderer.prod.js, dentro do
app.asar. Daqui saem quatro coisas, conferidas no Suite 6.11.4:
  - tabelas ib.qv (bass), ib.hP (guitar) e ib.Rh (artists): arquivo de IR -> modelo;
  - mve(nome, bypass): modelo -> imagem em cabs/ (ligada ou "Bypass-…");
  - "urn:…"===e.uri ? …/effects/<imagem>: uri -> imagem do bloco;
  - Ah=[…]: os 36 presets de fábrica da Anagram (presets_de_fabrica).
"""
import json
import re
import shutil

PREFIXO_GABINETE = 'dg_cab_'
# colunas da tabela de gabinetes de baixo (qv) do Suite
COLUNA_ARQUIVO_ORIGINAL = 'Original file name'
COLUNA_NOME_GABINETE = 'Cab listing name'
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


# uris de plugin também vêm como endereço (https://cognate.audio/plugins/…)
_COMPARACAO_URI = re.compile(r'"((?:urn:|https?://)[^"]+)"===e\.uri(?:\|\||\?Gce\+"/devices/anagram/effects/([^"/]+)")')


def _cadeias_de_uri(texto):
    """Cada `"urn:a"===e.uri||"urn:b"===e.uri?Gce+"/…/arquivo"` vira (["urn:a", "urn:b"], arquivo).
    Varredura linear: um elo só continua a cadeia se começa onde o anterior terminou."""
    pendentes, fim_anterior = [], -1
    for elo in _COMPARACAO_URI.finditer(texto):
        if elo.start() != fim_anterior:
            pendentes = []
        pendentes.append(elo.group(1))
        fim_anterior = elo.end()
        if elo.group(2):
            yield pendentes, elo.group(2)
            pendentes = []


def _uris(texto):
    ligadas, desligadas = {}, {}
    for uris, arquivo in _cadeias_de_uri(texto):
        for uri in uris:
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
    por_arquivo = {}
    for linha in tabelas.get('qv', []):
        if linha.get(COLUNA_ARQUIVO_ORIGINAL):
            por_arquivo[linha[COLUNA_ARQUIVO_ORIGINAL]] = linha.get(COLUNA_NOME_GABINETE, '')
    for linha in tabelas.get('hP', []):
        por_arquivo[linha['Filename']] = linha['Cab']
    for linha in tabelas.get('Rh', []):
        por_arquivo[linha['Filename']] = modelo_do_artista(linha['Description'], modelos) or ''
    return por_arquivo


def escolhas_de_gabinete(tabelas):
    """O que se escolhe no bloco de gabinete, como na pedaleira: por tipo,
    [modelo, microfone, posição, arquivo de IR]. Os Artists não têm posição: a
    descrição é "Modelo - Microfone"."""
    bass = [[linha[COLUNA_NOME_GABINETE], linha.get('Mic name in Suite', ''), linha.get('Mic position', ''),
             linha[COLUNA_ARQUIVO_ORIGINAL]]
            for linha in tabelas.get('qv', []) if linha.get(COLUNA_ARQUIVO_ORIGINAL) and linha.get(COLUNA_NOME_GABINETE)]
    guitar = [[linha['Cab'], linha.get('Mic', ''), linha.get('Position', ''), linha['Filename']]
              for linha in tabelas.get('hP', []) if linha.get('Filename') and linha.get('Cab')]
    artists = [[*_modelo_e_microfone(linha['Description']), '', linha['Filename']]
               for linha in tabelas.get('Rh', []) if linha.get('Filename') and linha.get('Description')]
    return {'bass': bass, 'guitar': guitar, 'artists': artists}


def _modelo_e_microfone(descricao):
    modelo, _, microfone = descricao.partition(' - ')
    return [modelo.strip(), microfone.strip()]


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
    from PIL import ImageOps
    with Image.open(origem) as aberta:
        if max(aberta.size) <= LADO_MAXIMO:
            shutil.copyfile(origem, destino)
            return
        # fotos de celular (tons do TONE3000) vêm deitadas, com a rotação no EXIF
        imagem = ImageOps.exif_transpose(aberta)
        imagem.thumbnail((LADO_MAXIMO, LADO_MAXIMO), Image.LANCZOS)
        formato = destino.suffix.lower()
        if formato == '.webp':
            imagem.save(destino, 'WEBP', quality=88, method=6)
        elif formato in ('.jpg', '.jpeg'):
            imagem.convert('RGB').save(destino, 'JPEG', quality=85, optimize=True, progressive=True)
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


# Presets de fábrica da Anagram (área Factory): a pedaleira não os entrega pelo
# USB (DECISOES U18); o Suite traz uma cópia embutida no array `Ah` do renderer,
# como literal JavaScript (chaves sem aspas, !0/!1, Pp.FACTORY).
INICIO_FABRICA = 'Ah=[{name:"Harmonic Booster"'
_NUMERO = re.compile(r'-?(?:\d+(?:\.\d*)?|\.\d+)(?:e[+-]?\d+)?')
_PALAVRA = re.compile(r'[A-Za-z_$][\w$]*(?:\.[\w$]+)*|!0|!1')


def presets_de_fabrica(renderer):
    """[{arquivo, nome, preset}] na ordem do Suite; preset é o envelope
    {"preset": …, "type": "preset", "version": 1}, como a pedaleira grava."""
    texto = renderer.read_text(encoding='utf-8', errors='replace')
    inicio = texto.index(INICIO_FABRICA) + len('Ah=')
    lista = json.loads(_literal_js_para_json(texto[inicio:_fim_do_colchete(texto, inicio)]))
    return [{'arquivo': item['filename'], 'nome': item['name'], 'preset': item['localPreset']['data']}
            for item in lista]


def _fim_do_colchete(texto, inicio):
    """Posição logo depois do ']' que fecha o '[' em [inicio], pulando strings."""
    profundidade, i, em_texto = 0, inicio, False
    while True:
        c = texto[i]
        if em_texto:
            if c == '\\':
                i += 1
            elif c == '"':
                em_texto = False
        elif c == '"':
            em_texto = True
        elif c in '[{':
            profundidade += 1
        elif c in ']}':
            profundidade -= 1
            if profundidade == 0:
                return i + 1
        i += 1


def _literal_js_para_json(trecho):
    """Só o que aparece nesse array: strings com aspas duplas, chaves sem aspas
    (nomes ou números), !0/!1, números como .5 ou 17434656e5 e referências a
    enums (Pp.FACTORY), que viram texto ("factory")."""
    saida, i = [], 0
    while i < len(trecho):
        if trecho[i] == '"':
            fim = i + 1
            while trecho[fim] != '"':
                fim += 2 if trecho[fim] == '\\' else 1
            saida.append(trecho[i:fim + 1])
            i = fim + 1
            continue
        achado = _NUMERO.match(trecho, i) or _PALAVRA.match(trecho, i)
        if not achado:
            saida.append(trecho[i])
            i += 1
            continue
        token = achado.group(0)
        i = achado.end()
        saida.append(_token_em_json(token, eh_chave=trecho[i:i + 1] == ':' and saida[-1:] in (['{'], [','])))
    return ''.join(saida)


def _token_em_json(token, eh_chave):
    if eh_chave:
        return json.dumps(token)
    if token in ('!0', '!1'):
        return 'true' if token == '!0' else 'false'
    if _NUMERO.fullmatch(token):
        return repr(float(token)) if ('.' in token or 'e' in token) else token
    if token in ('true', 'false', 'null'):
        return token
    return json.dumps(token.split('.')[-1].lower())
