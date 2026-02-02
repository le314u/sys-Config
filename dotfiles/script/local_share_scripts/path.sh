#!/usr/bin/env bash
set -euo pipefail

DIRS_FILE="$HOME/.local/share/scripts/path.map"

# Ajuda
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Este script abre um menu (wofi --dmenu) com atalhos para diretórios definidos em:
  $DIRS_FILE

Formato do arquivo:
  Nome Bonito|/caminho/real

Observações:
  - Variáveis como \$HOME e \$USER são aceitas.
  - O caractere ~ também é expandido.

Dependências:
  - wofi
  - kitty
  - nnn
EOF
    exit 0
fi

# Verifica arquivo
if [[ ! -f "$DIRS_FILE" ]]; then
    echo "Arquivo $DIRS_FILE não encontrado!" >&2
    exit 1
fi

# Extrai só os nomes
names=$(awk -F'|' '{
    gsub("\r","")
    name=$1
    gsub(/^[ \t]+|[ \t]+$/,"",name)
    if (name != "") print name
}' "$DIRS_FILE")

if [[ -z "$names" ]]; then
    echo "Nenhum diretório válido encontrado em $DIRS_FILE" >&2
    exit 1
fi

# Escolha via wofi
choice=$(printf "%s\n" "$names" | wofi --dmenu --insensitive -p "Abrir no nnn:")

[[ -z "$choice" ]] && exit 0

# Recupera caminho correspondente
raw_path=$(awk -F'|' -v name="$choice" '
{
    gsub("\r","")
    key=$1
    gsub(/^[ \t]+|[ \t]+$/,"",key)
    path=$2
    gsub(/^[ \t]+|[ \t]+$/,"",path)
    if (tolower(key) == tolower(name)) {
        print path
        exit
    }
}' "$DIRS_FILE")

# Expande variáveis e ~
expanded_path=$(eval echo "$raw_path")

# Valida diretório
if [[ ! -d "$expanded_path" ]]; then
    echo "Diretório não encontrado: $expanded_path" >&2
    exit 1
fi

# Abre no nnn dentro do kitty
kitty -e nnn "$expanded_path"


