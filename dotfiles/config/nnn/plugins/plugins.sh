#!/bin/bash
# Se for chamado com -h ou --help, mostra ajuda e sai
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Uso: $(basename "$0")

Descrição:

Fluxo:

Variáveis:

Dependências:

Exemplo de uso:
  ./$(basename "$0")
  ./$(basename "$0") -h   # mostra esta ajuda

EOF
    exit 0
fi

clear

# Cores
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

# Menu chamativo
echo -e "${YELLOW}Escolha plugin:${NC}"
echo -e "${RED}P)${NC} Copiar PWD para o clipboard"
echo -e "${RED}R)${NC} Rodar script"
echo -e "${RED}M)${NC} Criar novo modelo"
echo -e "${RED}T)${NC} Abre um Terminal em ${PWD}"
echo -e "${RED}X)${NC} Torna executável"
echo -e "${RED}K)${NC} Preview Markdown"
# Variaveis usadas pelo NNN
#echo -e "$NNN_FPATH $NNN_SEL $NNN_DIR $NNN_FLINK"

# Lê apenas 1 caractere
read -n1 -p "Digite a opção: " key
clear
echo -e "${YELLOW}plugin:${NC}"
FILE_SELECT=${PWD}/${1}
# Case para executar plugins
case "$key" in
    [Pp]) "$NNN_DIR_PLUG/copy-pwd-to-clipboard.sh" ;;
    [Rr]) "$NNN_DIR_PLUG/run_script.sh" ;;
    [Mm]) "$NNN_DIR_PLUG/model.sh" ;;
    [Tt]) "$NNN_DIR_PLUG/terminal-here.sh" ;;
    [Xx])
    if [[ -n "$FILE_SELECT" && -f "$FILE_SELECT" ]]; then
        chmod +x "$NNN_SEL"
        echo -e "${GREEN}Arquivo agora é executável:${NC} $FILE_SELECT"
    else
        echo -e "${RED}Nenhum arquivo selecionado ou arquivo não existe.${NC}"
    fi
;;
    [Kk]) "$NNN_DIR_PLUG/mk.sh" ;;

    *) echo "Opção inválida" ;;
esac
