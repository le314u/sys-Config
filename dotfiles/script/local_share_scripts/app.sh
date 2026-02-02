#!/bin/bash

# --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0") [FLAG]

Sem FLAG: mostra todos os arquivos
-app    Mostra apenas arquivos .desktop
-sh     Mostra apenas scripts .sh
-file   Mostra apenas outros arquivos
EOF
    exit 0
fi

# Determina filtro
FILTER="$1"

# Diretórios
paths=("$HOME/.local/share/scripts" "$HOME/.local/share/applications")

# Exclusões
exclude_files=("wofi.sh" "wofi_path.sh" "model.sh")
exclude_patterns=("_nnn")

should_exclude() {
    local fname="$1"
    for pattern in "${exclude_patterns[@]}"; do
        [[ "$fname" == *"$pattern"* ]] && return 0
    done
    return 1
}

declare -A files_map
list=""

for dir in "${paths[@]}"; do
    for f in "$dir"/*; do
        [[ ! -f "$f" ]] && continue
        name=$(basename "$f")
        [[ " ${exclude_files[*]} " == *" $name "* ]] && continue
        should_exclude "$name" && continue

        name_no_ext="${name%.*}"

        # Determina tipo
        if [[ "$f" == *.sh ]]; then
            type="sh"
            prefix_visual="<span foreground='red'>[SH]</span> "
            prefix_search="sh:"
        elif [[ "$f" == *.desktop ]]; then
            type="app"
            prefix_visual="<span foreground='blue'>[APP]</span> "
            prefix_search="app:"
        else
            type="file"
            prefix_visual="<span foreground='green'>[FILE]</span> "
            prefix_search="file:"
        fi

        # Aplica filtro
        if [[ -n "$FILTER" && "$FILTER" != "-$type" ]]; then
            continue
        fi

        # Adiciona ao menu
        display_name="${prefix_visual}${name_no_ext}"
        list+="$display_name\n"

        # Salva no mapa
        files_map["${prefix_search}${name_no_ext,,}"]="$f"
        files_map["${name_no_ext,,}"]="$f"
    done
done

# Menu Wofi
MENU=$(echo -e "$list" | wofi --dmenu --allow-markup --insensitive --prompt="Abrir: ")

# Remove markup
CHOICE=$(echo "$MENU" | sed 's/<[^>]*>//g' | sed 's/^\[[A-Z]*\] //')
CHOICE_LC="${CHOICE,,}"

# Busca arquivo no mapa
if [[ "$CHOICE_LC" == sh:* || "$CHOICE_LC" == app:* || "$CHOICE_LC" == file:* ]]; then
    PREFIX="${CHOICE_LC%%:*}:"
    NAME="${CHOICE_LC#*:}"
    FILE="${files_map[$PREFIX$NAME]}"
else
    FILE="${files_map[$CHOICE_LC]}"
fi

# Executa
if [[ -n "$FILE" ]]; then
    if [[ "$FILE" == *.desktop ]]; then
        APP=$(basename "$FILE" .desktop)
        gtk-launch "$APP" 2>/dev/null || dex "$FILE"
    elif [[ -x "$FILE" ]]; then
        "$FILE"
    else
        xdg-open "$FILE"
    fi
fi
