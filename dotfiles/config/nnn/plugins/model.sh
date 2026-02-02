#!/bin/bash

# Se for chamado com -h ou --help, mostra ajuda e sai
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Este script lista os arquivos de um diretório de origem usando fzf,
permite escolher um e copiar para o diretório atual com um novo nome.

Fluxo:
  1. Mostra os arquivos de \$SOURCE_DIR no fzf.
  2. Usuário escolhe o arquivo.
  3. Pergunta o novo nome (sugerindo o original).
  4. Copia para o diretório atual.

Variáveis:
  SOURCE_DIR  Diretório onde os arquivos estão (atual: \$HOME/.local/share/models)

Dependências:
  - fzf
  - bash

Exemplo de uso:
  ./$(basename "$0")
  ./$(basename "$0") -h   # mostra esta ajuda
EOF
    exit 0
fi

# Diretório de origem
SOURCE_DIR="$HOME/.local/share/models"

# Escolher arquivo com fzf
file=$(ls -1 "$SOURCE_DIR" | fzf --prompt="Arquivo: ")
[ -z "$file" ] && exit 1   # cancelou

# Perguntar novo nome (sugere o original)
read -rp "Novo nome [$file]: " newname
newname=${newname:-$file}

# Copiar para o diretório atual
cp "$SOURCE_DIR/$file" "./$newname"

echo "✅ Copiado: $file → $(pwd)/$newname"
