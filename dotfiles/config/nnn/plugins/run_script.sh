#!/bin/bash
# Plugin mínimo para nnn
# Recebe o arquivo selecionado como $1

# Se nenhum arquivo foi selecionado, sai
if [ -z "$1" ]; then
    echo "Nenhum arquivo selecionado."
    read -p "Pressione Enter para continuar..."
    exit 1
fi

# Aqui você chama seu script principal, passando o arquivo
 bash "$1"
