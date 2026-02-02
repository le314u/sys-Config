#!/bin/bash

# ================================
# FLAGS (default)
# ================================

OUTPUT_ENABLED="${OUTPUT_ENABLED:-true}"     # mostra no terminal
LOG_ENABLED="${LOG_ENABLED:-true}"  # salva no arquivo
LOG_FILE="${LOG_FILE:-./log.txt}" # Arquivo de log (configurável)

# ================================
# HEX → ANSI (24-bit color)
# ================================
hex_to_ansi() {
    local hex="${1#\#}"

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    echo -e "\033[38;2;${r};${g};${b}m"
}

# ================================
# output <hex> <mensagem>
# ================================
output() {
    [[ "$OUTPUT_ENABLED" != "true" ]] && return

    local color="$1"
    shift
    local text="$*"

    local ansi
    ansi="$(hex_to_ansi "$color")"

    echo -e "${ansi}${text}\033[0m"
}


# ================================
# log <mensagem>
# ================================
log() {
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # -------- Arquivo --------
    if [[ "$LOG_ENABLED" == "true" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "[$timestamp] $message" >> "$LOG_FILE"
    fi

    # -------- Terminal --------
    output "#DDDDDD" "$message"
}


# ================================
# error <mensagem>
# ================================
error() {
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Sempre loga erro se LOG estiver ativo
    if [[ "$LOG_ENABLED" == "true" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "[$timestamp] ERROR: $message" >> "$LOG_FILE"
    fi

    # Terminal (stderr)
    [[ "$VERBOSE" == "true" ]] && \
        echo -e "$(hex_to_ansi "#E06666")$message\033[0m" >&2
}
