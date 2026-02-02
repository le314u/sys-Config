#!/usr/bin/env bash
set -euo pipefail

LINKS_FILE="$HOME/.local/share/scripts/site.map"

# Ajuda
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Lê links de: $LINKS_FILE
Formato: Nome|URL
EOF
    exit 0
fi

# Verifica arquivo
if [[ ! -f "$LINKS_FILE" ]]; then
    echo "Arquivo $LINKS_FILE não encontrado!" >&2
    exit 1
fi

# Gera lista de nomes (remove linhas vazias e CRs, faz trim)
names=$(awk -F'|' '{
    gsub("\r","")                       # remove CR (caso Windows)
    name=$1
    gsub(/^[ \t]+|[ \t]+$/,"",name)     # trim
    if (name != "") print name
}' "$LINKS_FILE")

if [[ -z "$names" ]]; then
    echo "Nenhuma entrada válida em $LINKS_FILE" >&2
    exit 1
fi

# Escolha via wofi (dmenu mode)
choice=$(printf "%s\n" "$names" | wofi --insensitive --dmenu -p "Abrir link:")

# Se não escolheu (Esc), sai silencioso
[[ -z "$choice" ]] && exit 0

# Procura a URL correspondente (case-insensitive) e retorna apenas a primeira ocorrência
url=$(awk -F'|' -v name="$choice" '
{
    gsub("\r","")
    key=$1
    gsub(/^[ \t]+|[ \t]+$/,"",key)
    if (tolower(key) == tolower(name)) {
        out=$2
        for(i=3;i<=NF;i++) out = out "|" $i   # caso a URL contenha |
        print out
        exit
    }
}
' "$LINKS_FILE")

if [[ -z "$url" ]]; then
    echo "URL não encontrada para: $choice" >&2
    exit 1
fi

# Abre sem bloquear o terminal
xdg-open "$url" >/dev/null 2>&1 &

exit 0
