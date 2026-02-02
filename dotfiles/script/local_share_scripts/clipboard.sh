#!/bin/bash

# --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Menu wofi para copiar textos pré-definidos para a área de transferência.

Funcionalidades:
  - Copia o texto correspondente à opção escolhida.
  - Limpa a área de transferência após 10 segundos.
  - Mostra notificações se notify-send estiver disponível.

Dependências:
  - wofi
  - wl-clipboard (ou xclip / xsel)
  - notify-send (opcional)

Exemplo de uso:
  ./$(basename "$0")
EOF
    exit 0
fi

# Opções no formato NomeBonito|TextoCopiad
options="
LABEL|Text
"

# Mostra só os nomes no wofi
choice=$(echo "$options" | cut -d'|' -f1 | sed '/^$/d' | wofi --show dmenu -p "Copiar:")

# Sai se não escolheu nada
[[ -z "$choice" ]] && exit 0

# Pega o texto correspondente de forma segura
value=$(awk -F'|' -v c="$choice" '$1==c {print $2}' <<< "$options")

# Função para copiar para clipboard
copy_to_clipboard() {
    local text="$1"
    if command -v wl-copy &>/dev/null; then
        echo -n "$text" | wl-copy
    elif command -v xclip &>/dev/null; then
        echo -n "$text" | xclip -selection clipboard
    elif command -v xsel &>/dev/null; then
        echo -n "$text" | xsel --clipboard --input
    else
        echo "Nenhum comando de clipboard encontrado (instale wl-clipboard, xclip ou xsel)."
        exit 1
    fi
}

# Copia
copy_to_clipboard "$value"

# Notificação inicial
if command -v notify-send &>/dev/null; then
    notify-send "Copiado para a área de transferência!" "$choice"
fi

# Espera 10s e limpa
sleep 10
copy_to_clipboard ""

# Notificação final
if command -v notify-send &>/dev/null; then
    notify-send "Área de transferência limpa" "Ué... o que estava copiando mesmo?"
fi
