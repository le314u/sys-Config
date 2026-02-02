#!/bin/sh
# nnn plugin: copia o diretório atual para o clipboard

# detecta se estamos no Wayland ou X11
if command -v wl-copy >/dev/null 2>&1; then
    echo "$PWD" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
    echo -n "$PWD" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
    echo -n "$PWD" | xsel --clipboard --input
else
    echo "Nenhum utilitário de clipboard encontrado (wl-copy, xclip ou xsel)" >&2
    exit 1
fi

# mensagem de notificação (opcional)
#if command -v notify-send >/dev/null 2>&1; then
#    notify-send "nnn" "Diretório copiado para o clipboard: $PWD"
#fi

