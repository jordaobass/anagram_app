#!/bin/sh
# Confere a arte antes de um build de release. Desde a decisão A12 só existe a
# versão com a arte da pedaleira (a mesma da tela da Anagram), e só ela: as
# miniaturas de anagramanswers.com (A2) não vão para o público.
# Entram as fotos dos gabinetes do Suite (dg_cab_*.webp, A13) e os presets de
# fábrica que o Suite traz embutidos (fabrica.json, U18).
# A pasta assets/blocos_terceiros/ é declarada no pubspec e o Flutter embarca
# TUDO o que estiver nela, por isso ela tem de sair de um clone limpo:
#   git clone … && cd mobile
#   python3 ferramentas/baixar_arte_pedaleira.py
#   ferramentas/verificar_release.sh && flutter build <plataforma> --release
set -eu
raiz=$(cd "$(dirname "$0")/.." && pwd)
pasta="$raiz/assets/blocos_terceiros"
minimo=100

falhar() {
  echo "ERRO: $1" >&2
  echo "Em um clone limpo, rode: python3 ferramentas/baixar_arte_pedaleira.py" >&2
  exit 1
}

[ -f "$pasta/indice.json" ] || falhar "falta assets/blocos_terceiros/indice.json (arte da pedaleira ausente)."

pedaleira=$(find "$pasta" -type f -name 'dg_*.png' | wc -l)
[ "$pedaleira" -ge "$minimo" ] || falhar "só $pedaleira imagens da pedaleira (dg_*.png); esperado pelo menos $minimo."

intrusos=$(find "$pasta" -type f ! -name 'dg_*.png' ! -name 'dg_*.webp' ! -name indice.json ! -name fabrica.json ! -name LEIAME.txt | sort)
if [ -n "$intrusos" ]; then
  echo "$intrusos" | sed 's/^/  /' >&2
  falhar "arquivos que não são arte da pedaleira em assets/blocos_terceiros/ (acima)."
fi

if grep -q '"origem": *"anagramanswers\|anagramanswers.com/threads' "$pasta/indice.json"; then
  falhar "indice.json ainda aponta miniaturas de anagramanswers.com."
fi

echo "ok: $pedaleira imagens da pedaleira, nenhum arquivo de terceiros além delas."
