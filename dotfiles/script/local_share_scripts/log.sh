#!/bin/bash

# Arquivo de log
LOG="$HOME/program_time.log"

# Se for chamado com -h ou --help, mostra ajuda e sai
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    cat <<EOF
Uso: $(basename "$0") <programa> [argumentos]

Este script executa um programa, mede quanto tempo ele ficou aberto
e registra a informação em um arquivo de log.

Arquivo de log:
  $LOG

Opções:
  -h, --help   Mostra esta mensagem de ajuda e sai

Exemplos:
  $(basename "$0") firefox
  $(basename "$0") gedit meu_arquivo.txt
  $(basename "$0") nvim script.sh
EOF
    exit 0
fi

# Nome do programa + argumentos
PROG="$@"

# Marca o início
START=$(date +%s)
START_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')

# Abre o programa
$PROG &
PID=$!

# Espera até o programa fechar
wait $PID

# Marca o fim
END=$(date +%s)
END_HUMAN=$(date '+%Y-%m-%d %H:%M:%S')

# Calcula duração em segundos
DURATION=$((END-START))

# Salva no log
echo "$START_HUMAN -> $END_HUMAN | $PROG ficou aberto por $DURATION segundos" >> "$LOG"
