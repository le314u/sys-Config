#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Carrega módulos
source "$SCRIPT_DIR/lib/output.sh"
source "$SCRIPT_DIR/lib/args.sh"
source "$SCRIPT_DIR/lib/system.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/dotfiles.sh"

main() {
    parse_args "$@"
    check_flags
    check_arch

    if ! $ONLY_DOTFILES; then
        update_system
        install_packages
    fi

    if ! $ONLY_PACKAGES; then
        copy_dotfiles "$DOTFILES_DIR"
    fi

    echo ""
    log "Setup finalizado com sucesso!"
}

main "$@"
