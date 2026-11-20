#!/usr/bin/env python3
"""Gera o ícone do app em todas as plataformas a partir de um desenho só.

O desenho segue o tema "case de estrada" (DESIGN.md): fundo escuro do case,
"A" em estêncil âmbar (a cor do tally) e cantoneiras de alumínio, como as dos
cartões do app. É arte própria: nada de logo ou imagem da Darkglass.

Uso (na pasta mobile/):
  docker run --rm -v "$PWD":/p -w /p python:3.12-slim \\
    sh -c 'pip install -q pillow && python ferramentas/gerar_icones.py'
"""
import json
import pathlib

from PIL import Image, ImageDraw, ImageFont

RAIZ = pathlib.Path(__file__).resolve().parent.parent
FONTE = RAIZ / 'assets' / 'fontes' / 'SairaStencilOne-Regular.ttf'
MESTRE = 1024

# Espelham lib/apresentacao/tema/tokens.dart
FUNDO_CASE = (0x13, 0x14, 0x16)
PAINEL = (0x1B, 0x1C, 0x1F)
ALUMINIO = (0x8E, 0x94, 0x9B)
TALLY = (0xF0, 0xB4, 0x29)


def desenhar(lado, *, margem=0.0, cantos=True, fundo_transparente=False, so_letra=False):
    """Desenha o ícone em `lado` px. `margem` é a fração vazia em volta
    (macOS pede respiro; iOS e Android adaptativo, não)."""
    escala = 4  # desenha grande e reduz: bordas lisas em qualquer tamanho
    total = lado * escala
    # com cantos arredondados o que fica fora deles é transparente; sem cantos
    # (iOS, maskable), o fundo vai até a borda e a plataforma recorta
    transparente = fundo_transparente or margem or cantos
    imagem = Image.new('RGBA', (total, total), (0, 0, 0, 0) if transparente else FUNDO_CASE + (255,))
    pincel = ImageDraw.Draw(imagem)
    inicio = round(total * margem)
    fim = total - inicio
    tamanho = fim - inicio
    if not so_letra:
        raio = round(tamanho * 0.22) if cantos else 0
        pincel.rounded_rectangle((inicio, inicio, fim - 1, fim - 1), raio, fill=FUNDO_CASE + (255,))
        _cantoneiras(pincel, inicio, fim, tamanho)
    _letra(pincel, inicio, tamanho)
    return imagem.resize((lado, lado), Image.LANCZOS)


def _cantoneiras(pincel, inicio, fim, tamanho):
    """Cantoneiras de alumínio nos cantos opostos, como nos cartões do app."""
    braco = round(tamanho * 0.16)
    espessura = max(1, round(tamanho * 0.035))
    folga = round(tamanho * 0.11)
    a, b = inicio + folga, fim - folga
    pincel.rectangle((a, a, a + braco, a + espessura), fill=ALUMINIO)
    pincel.rectangle((a, a, a + espessura, a + braco), fill=ALUMINIO)
    pincel.rectangle((b - braco, b - espessura, b, b), fill=ALUMINIO)
    pincel.rectangle((b - espessura, b - braco, b, b), fill=ALUMINIO)


def _letra(pincel, inicio, tamanho):
    fonte = ImageFont.truetype(str(FONTE), round(tamanho * 0.70))
    caixa = pincel.textbbox((0, 0), 'A', font=fonte)
    largura, altura = caixa[2] - caixa[0], caixa[3] - caixa[1]
    x = inicio + (tamanho - largura) / 2 - caixa[0]
    y = inicio + (tamanho - altura) / 2 - caixa[1]
    pincel.text((x, y), 'A', font=fonte, fill=TALLY)


def salvar(imagem, caminho, *, sem_alfa=False):
    caminho.parent.mkdir(parents=True, exist_ok=True)
    if sem_alfa:
        imagem = imagem.convert('RGB')
    imagem.save(caminho, optimize=True)


def windows():
    destino = RAIZ / 'windows' / 'runner' / 'resources' / 'app_icon.ico'
    tamanhos = [16, 24, 32, 48, 64, 128, 256]
    # cada tamanho desenhado no próprio tamanho, não reduzido do de 256
    quadros = [desenhar(t) for t in tamanhos]
    quadros[-1].save(destino, format='ICO', sizes=[(t, t) for t in tamanhos], append_images=quadros[:-1])


def macos():
    pasta = RAIZ / 'macos' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'
    for lado in (16, 32, 64, 128, 256, 512, 1024):
        # a grade de ícones do macOS deixa ~10% de respiro em volta
        salvar(desenhar(lado, margem=0.1), pasta / f'app_icon_{lado}.png')


def ios():
    pasta = RAIZ / 'ios' / 'Runner' / 'Assets.xcassets' / 'AppIcon.appiconset'
    contents = json.loads((pasta / 'Contents.json').read_text())
    for item in contents['images']:
        base = float(item['size'].split('x')[0])
        lado = round(base * int(item['scale'].rstrip('x')))
        # o iOS recorta os cantos sozinho e recusa transparência no ícone
        salvar(desenhar(lado, cantos=False), pasta / item['filename'], sem_alfa=True)


ANDROID = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}


def android():
    res = RAIZ / 'android' / 'app' / 'src' / 'main' / 'res'
    for densidade, lado in ANDROID.items():
        salvar(desenhar(lado), res / f'mipmap-{densidade}' / 'ic_launcher.png')
        # adaptativo: camada de 108 dp, com a arte dentro da zona segura de 66 dp
        frente = desenhar(round(lado * 108 / 48), margem=0.2, so_letra=True, fundo_transparente=True)
        salvar(frente, res / f'mipmap-{densidade}' / 'ic_launcher_foreground.png')
    adaptativo = res / 'mipmap-anydpi-v26' / 'ic_launcher.xml'
    adaptativo.parent.mkdir(parents=True, exist_ok=True)
    adaptativo.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<!-- Gerado por ferramentas/gerar_icones.py -->\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/fundo_case" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n')


def web():
    pasta = RAIZ / 'web'
    salvar(desenhar(32), pasta / 'favicon.png')
    for lado in (192, 512):
        salvar(desenhar(lado), pasta / 'icons' / f'Icon-{lado}.png')
        # maskable: o navegador recorta a forma dele, então o fundo vai até a borda
        salvar(desenhar(lado, cantos=False), pasta / 'icons' / f'Icon-maskable-{lado}.png')


def main():
    salvar(desenhar(MESTRE), RAIZ / 'ferramentas' / 'icone-mestre.png')
    windows()
    macos()
    ios()
    android()
    web()
    print('ícones gerados para Windows, macOS, iOS, Android e web')


if __name__ == '__main__':
    main()
