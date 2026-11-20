#!/bin/sh
# Barra build de release com miniaturas de terceiros dentro do app.
# A pasta assets/blocos_terceiros/ é declarada no pubspec e o Flutter embarca
# TUDO o que estiver nela; para loja, só pode ter o LEIAME.txt.
# Uso: ferramentas/verificar_release.sh && flutter build <plataforma> --release
set -eu
raiz=$(cd "$(dirname "$0")/.." && pwd)
pasta="$raiz/assets/blocos_terceiros"
intrusos=$(find "$pasta" -type f ! -name LEIAME.txt | sort)
if [ -n "$intrusos" ]; then
  echo "ERRO: release com arquivos de terceiros em assets/blocos_terceiros/:" >&2
  echo "$intrusos" | sed 's/^/  /' >&2
  echo "Publique a partir de um clone limpo (git clone) ou apague esses arquivos." >&2
  exit 1
fi
echo "ok: nenhum arquivo de terceiros será embarcado."
