#!/bin/bash

# QuickNotes v2.0 - Criador e buscador de notas com Wofi
# Autor: Lucas Mateus
# Uso: ./quicknotes.sh [--help]

# ----------------------------
# Função help
# ----------------------------

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "QuickNotes - Criador e buscador de notas rápido"
    echo
    echo "Opções:"
    echo "  --help        Exibe esta ajuda"
    echo
    echo "Funcionalidades:"
    echo "  - Cria nota com DATA e HORA automaticamente"
    echo "  - Permite inserir TÍTULO e TAGS via Zenity"
    echo "  - Gera arquivo organizado por ano/mês"
    echo "  - Busca por conteúdo das notas diretamente pelo Wofi"
    echo
    echo "Configuração do editor de notas:"
    echo "  - Defina a variável de ambiente QUICK_NOTE para usar seu editor preferido"
    echo "    Exemplo:"
    echo "      export QUICK_NOTE=nano"
    echo "    Se a variável não estiver definida, o script usará xdg-open como fallback."
    echo
    echo "Dependências necessárias:"
    echo "  - zenity      → Para entrada de Título, Tags e Hora"
    echo "  - wofi        → Para menu principal e busca de notas"
    echo "  - xdg-open    → Para abrir arquivos em fallback"
    echo "  - notify-send → Para notificações de criação de nota"
    exit 0
fi
 
# ----------------------------
# Configurações
# ----------------------------
PASTA_NOTAS="$HOME/QuickNotes"
mkdir -p "$PASTA_NOTAS"

DATA=$(date '+%Y-%m-%d')
HORA=$(date '+%H:%M:%S')
ANO=$(date '+%Y')
MES=$(date '+%m')

PASTA_DATA="$PASTA_NOTAS/$ANO/$MES"
mkdir -p "$PASTA_DATA"

# ----------------------------
# Menu principal Wofi
# ----------------------------
OPCAO=$(echo -e "Criar Nota\nNota Rápida\nBuscar Nota" | wofi --dmenu --prompt "QuickNotes:")

# ----------------------------
# Criar nova nota
# ----------------------------
if [[ "$OPCAO" == "Criar Nota" ]]; then
    while true; do
    TITULO=$(zenity --entry \
                    --title="📒 QuickNotes" \
                    --text="Digite o título da nota:" \
                    --width=400)

    # Se vazio ou cancel, repete
    if [[ -n "$TITULO" ]]; then
        break
    fi
    done

    # Tags
    while true; do
    TAGS=$(zenity --entry \
                    --title="📒 QuickNotes" \
                    --text="Digite as tags (separadas por vírgula):" \
                    --width=400)

    [[ -n "$TAGS" ]] && break
    done


# ----------------------------
# Nota rápida (só data/hora)
# ----------------------------
elif [[ "$OPCAO" == "Nota Rápida" ]]; then
    TITULO=""
    TAGS=""

# ----------------------------
# Busca no conteúdo das notas
# ----------------------------
elif [[ "$OPCAO" == "Buscar Nota" ]]; then
    BUSCA=$(echo "" | wofi --dmenu --prompt "Pesquisar por palavra ou tag:")
    
    if [[ -z "$BUSCA" ]]; then
        exit 0
    fi

    # Encontrar notas que contenham a palavra-chave
    RESULTADOS=$(grep -ril "$BUSCA" "$PASTA_NOTAS")
    
    if [[ -z "$RESULTADOS" ]]; then
        notify-send "QuickNotes" "Nenhuma nota encontrada para: $BUSCA"
        exit 0
    fi

    # Mostrar lista de notas encontradas e abrir selecionada
    ESCOLHA=$(echo "$RESULTADOS" | wofi --dmenu --prompt "Notas encontradas:")
    if [[ -n "$ESCOLHA" ]]; then
        xdg-open "$ESCOLHA"
    fi
    exit 0

else
    exit 0
fi

# ----------------------------
# Criação do arquivo de nota
# ----------------------------
# Nome seguro do arquivo
NOME_ARQUIVO=$(echo "$TITULO" | tr -cd '[:alnum:]_-' | tr ' ' '_')
ARQUIVO="$PASTA_DATA/${DATA}_${NOME_ARQUIVO}.txt"

# Conteúdo da nota
{
    echo "[DATA]: $DATA"
    echo "[HORA]: $HORA"
    echo "[TAGS]: $TAGS"
    echo "[TÍTULO]: $TITULO"
    echo "[NOTA]:"
    echo "---"
    echo ""
} > "$ARQUIVO"

# Abrir no editor padrão
if [[ -n "$QUICK_NOTE" ]]; then
    "$QUICK_NOTE" "$ARQUIVO"
else
    xdg-open "$ARQUIVO"
fi

# Notificação de confirmação
notify-send "QuickNotes" "Nota criada: $ARQUIVO"
