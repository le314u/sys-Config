#!/bin/bash
# markdown-preview.sh - Preview de arquivos Markdown no nnn
# Coloque este script em ~/.config/nnn/plugins/markdown-preview.sh

# Ajuda
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0") [arquivo]

Descrição:
  Faz preview de arquivos Markdown selecionados no nnn.
  Se 'glow' estiver instalado, mostra no terminal.
  Se 'grip' estiver instalado, abre no navegador.

Variáveis usadas:
  NNN_SEL  -> Caminho completo do arquivo selecionado no nnn.

Exemplo de uso:
  Dentro do nnn, selecione um arquivo .md e rode o plugin.

Dependências (uma das duas):
  - glow (preview no terminal)
  - grip (preview no navegador)

EOF
    exit 0
fi

FILE="$NNN_SEL"

if [[ -z "$FILE" ]]; then
    echo "Nenhum arquivo selecionado."
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "Arquivo inválido: $FILE"
    exit 1
fi

case "$FILE" in
    *.md|*.markdown)
        if command -v glow >/dev/null 2>&1; then
            glow "$FILE"
        elif command -v

