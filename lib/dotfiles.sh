#!/bin/bash

copy_dotfiles() {
    local DOTFILES_DIR="$1"

    [[ ! -d "$DOTFILES_DIR" ]] && {
        echo "⚠ Pasta dotfiles não encontrada"
        return
    }

    log "⏳ Processando dotfiles..."

    for module in "$DOTFILES_DIR"/*; do
        [[ ! -d "$module" ]] && continue
        process_descend "$module"
        log "---"
    done
}



is_wrapper() {
    local dir="$1"

    # Se tiver README → módulo real
    if [[ -f "$dir/README" ]]; then
        return 0   # status 0 → módulo
    fi

    # Caso contrário → wrapper
    return 1       # status 1 → wrapper
}


process_descend() {
    local dir="$1"

    if is_wrapper "$dir"; then
        log "Módulo detectado: $(basename "$dir")"
        process_module "$dir"
    else
        log "Wrapper detectado: $(basename "$dir")"
        local found_sub="false"
        # desce recursivamente
        for nested in "$dir"/*; do
            [[ ! -d "$nested" ]] && continue
            found_sub="true"
            process_module "$nested"
        done

        if ! $found_sub; then
            log "⚠ Ignorando $(basename "$dir") – sem README e sem subdiretórios"
        else
            log "Wrapper processado: $(basename "$dir")"
        fi
    fi

}


process_module() {
    local module="$1"
    local name="$(basename "$module")"
    local readme="$module/README"

    set_defaults "$module" "$name"
    read_readme "$readme"
    check_package || return

    log "Módulo: $name"
    log "Mode   : $MODE"
    log "Source : $SOURCE"
    log "Target : $TARGET"

    backup_target
    prepare_dirs
    apply_module "$module"
    run_exec "$module"

    log "Módulo aplicado!"

    return 
}

set_defaults() {
    local module="$1"
    local name="$2"

    MODE="copy"
    SOURCE="$HOME/.myConf/$name"
    TARGET="$HOME/$name"
    BACKUP="false"
    CLEAN="false"
    EXEC=""
    PKG_REQUIRE=""
}


read_readme() {
    local readme="$1"

    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        key=$(echo "$key" | tr -d ' ' | tr '[:lower:]' '[:upper:]')
        value=$(echo "$value" | sed "s/^'//;s/'$//" | tr -d ' ')

        case "$key" in
            MODE)    MODE="$value" ;;
            SOURCE)  SOURCE="${value/#\~/$HOME}" ;;
            TARGET)  TARGET="${value/#\~/$HOME}" ;;
            BACKUP)  BACKUP="$value" ;;
            CLEAN)   CLEAN="$value" ;;
            EXEC)    EXEC="$value" ;;
            PACKAGE) PKG_REQUIRE="$value" ;;
        esac
    done < "$readme"
}

check_package() {
    [[ -z "$PKG_REQUIRE" ]] && return 0

    if ! pacman -Qi "$PKG_REQUIRE" &>/dev/null; then
        log "⚠ Pulando (pacote $PKG_REQUIRE não instalado)"
        return 1
    fi
}

backup_target() {
    [[ "$BACKUP" != "true" || "$NO_BACKUP" == "true" ]] && return
    [[ ! -e "$TARGET" ]] && return

    local BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    log "⏳ Backup → $BACKUP_DIR"
    mv "$TARGET" "$BACKUP_DIR/"
}

prepare_dirs() {
    # -------- Clean (remover SOURCE e TARGET) --------
    if [[ "$CLEAN" == "true" ]]; then
        log "⏳ Limpando SOURCE e TARGET..."
        safe_remove "$SOURCE"
        safe_remove "$TARGET"
    fi
    mkdir -p "$(dirname "$SOURCE")"
    mkdir -p "$TARGET"
}

apply_module() {
    local module="$1"

    case "$MODE" in
        link) apply_link "$module" ;;
        copy|*) apply_copy "$module" ;;
    esac
}

apply_link() {
    local module="$1"

    mkdir -p "$SOURCE"
    
    shopt -s dotglob
    for item in "$module"/*; do
        local name="$(basename "$item")"
        [[ "$name" == "README" ]] && continue
        #Deleta com segurança
        [[ -e "$TARGET/$name" ]] && safe_remove "$TARGET/$name"
        log "      cp $item → $SOURCE/$name"
        cp -r "$item" "$SOURCE/$name"
        # Não cria o link do README mas o copia
        [[ "$name" == "README" ]] && continue
        log "      ln $SOURCE/$name → $TARGET/$name"
        ln -sfn "$SOURCE/$name" "$TARGET/$name"
    done
    shopt -u dotglob
}


apply_copy() {
    local module="$1"

    log "  ⏳ Copiando arquivos..."
    for item in "$module"/*; do
        [[ "$(basename "$item")" == "README" ]] && continue
        cp -r "$item" "$TARGET/"
    done
}

run_exec() {
    local module="$1"
    [[ -z "$EXEC" ]] && return

    local script="$module/$EXEC"
    if [[ -x "$script" ]]; then
        log "  ⚡ Executando $EXEC"
        "$script"
    else
        log "  ⚠ EXEC definido mas inválido"
    fi
}

safe_remove() {
    local path="$1"
    if command -v gio &>/dev/null; then
        gio trash "$path"
    else
        mkdir -p "$HOME/.trash"
        mv "$path" "$HOME/.trash/"
    fi
}

