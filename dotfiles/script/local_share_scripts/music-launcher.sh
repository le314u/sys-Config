#!/bin/bash

# --- Wrapper para abrir em terminal separado ---
if [ -z "$TERMINAL_WRAPPER" ]; then
    export TERMINAL_WRAPPER=1
    # escolha seu terminal preferido (alacritty, kitty, gnome-terminal, xfce4-terminal etc.)
    exec kitty -e "$0" "$@"
fi
# -----------------------------------------------

# Pasta onde estão suas músicas
MUSIC_DIR="$HOME/Documentos/Music"

# Se for chamado com -h ou --help, mostra ajuda e sai
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Este script permite escolher e tocar músicas usando fzf e mpv.

Fluxo:
  1. Lista arquivos de áudio em:
     $MUSIC_DIR
  2. Mostra um menu interativo (fzf) para selecionar a música.
  3. Abre a música escolhida com mpv (sem vídeo).

Formatos suportados:
  - mp3, flac, wav, ogg

Dependências:
  - mpv (player de áudio/vídeo)
  - fzf (menu interativo no terminal)

Exemplos:
  $(basename "$0")          # roda normalmente
  $(basename "$0") -h       # mostra esta ajuda
EOF
    exit 0
fi

# Verifica se mpv e fzf estão instalados
command -v mpv >/dev/null 2>&1 || { echo "mpv não encontrado! Instale com: sudo pacman -S mpv"; exit 1; }
command -v fzf >/dev/null 2>&1 || { echo "fzf não encontrado! Instale com: sudo pacman -S fzf"; exit 1; }

# Entra na pasta de músicas
cd "$MUSIC_DIR" || { echo "Diretório $MUSIC_DIR não encontrado."; exit 1; }

# Usa find para listar músicas e fzf para selecionar
SELECTED=$(find . -type f \( -iname "*.mp3" -o -iname "*.flac" -o -iname "*.wav" -o -iname "*.ogg" \) \
    | sed 's|^\./||' \
    | fzf --prompt="🎵 Selecione a música: " --height=40% --border --ansi)

# Se usuário cancelou, sai
[ -z "$SELECTED" ] && exit 0

# Toca a música escolhida
mpv --no-video "$MUSIC_DIR/$SELECTED"
