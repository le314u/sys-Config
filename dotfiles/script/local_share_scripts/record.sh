#!/bin/bash
# Time
TIME=30
# Pasta de destino
OUTPUT_DIR="$HOME/Documentos/Videos"
mkdir -p "$OUTPUT_DIR"

# Nome do arquivo
FILENAME="$(date +'%Y-%m-%d_%H-%M-%S').mp4"

# Descobre o monitor padrão
MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

# Grava tela inteira por 30s usando timeout
timeout $TIME wf-recorder -o "$MONITOR" -f "$OUTPUT_DIR/$FILENAME"
