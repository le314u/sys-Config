#!/bin/bash

# =========================
# Plugin nnn: Abrir terminal na pasta atual
# =========================

# Se chamado com -h ou --help, mostra ajuda
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF

$(basename "$0") - Plugin nnn

Descrição:
  Este plugin abre um terminal diretamente no diretório atual do nnn.

Fluxo:
  1. Navegue até a pasta desejada no nnn
  2. Pressione ; e selecione este plugin
  3. Um terminal será aberto na pasta atual

Variáveis disponíveis:
  \$NNN_DIR   - Diretório atual no nnn
  \$PWD       - Diretório atual do shell (fallback)

Dependências:
  kitty       - terminal utilizado (altere se usar outro)

Exemplo de uso:
  ./$(basename "$0")
  ./$(basename "$0") -h   # Mostra esta ajuda

EOF
    exit 0
fi

# =========================
# Executa o plugin
# =========================

# Determina o diretório alvo
TARGET_DIR="${NNN_DIR:-$PWD}"

# Abre o terminal na pasta alvo
kitty --directory "$TARGET_DIR" &
