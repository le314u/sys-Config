#!/bin/bash

AUTO_CONFIRM=false
ONLY_DOTFILES=false
ONLY_PACKAGES=false
NO_BACKUP=false
OUTPUT_ENABLED=false
LOG_ENABLED=false
LOG_FILE=""

show_help() {
    cat << EOF
Uso: $0 [opções]

Opções gerais:
  -h, --help              Mostra esta ajuda
  -y                      Instala sem pedir confirmação

Dotfiles / Pacotes:
  -d, --only-dotfiles     Processa apenas os dotfiles
  -p, --only-packages     Instala apenas os pacotes
      --nobackup          Não cria backup dos dotfiles

Output e Log:
  -v                      Ativa output verboso no terminal
      --log=ARQUIVO       Salva logs no arquivo especificado

Exemplos:
  $0 -v --log=install.log
  $0 -d -v
  $0 -p --log=/tmp/install.log
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;

            -y)
                AUTO_CONFIRM=true
                ;;

            -d|--only-dotfiles)
                ONLY_DOTFILES=true
                ;;

            -p|--only-packages)
                ONLY_PACKAGES=true
                ;;

            --nobackup)
                NO_BACKUP=true
                ;;

            -v)
                OUTPUT_ENABLED=true
                ;;

            --log=*)
                LOG_ENABLED=true
                LOG_FILE="${1#*=}"

                if [[ -z "$LOG_FILE" ]]; then
                    echo "❌ --log requer um arquivo"
                    exit 1
                fi
                ;;

            *)
                echo "❌ Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

check_flags() {
    if $ONLY_DOTFILES && $ONLY_PACKAGES; then
        echo "❌ Use apenas uma das opções: dotfiles OU packages"
        exit 1
    fi
}

