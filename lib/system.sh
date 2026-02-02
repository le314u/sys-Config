#!/bin/bash

check_arch() {
    if ! grep -qi "arch" /etc/os-release; then
        echo "❌ Este script só funciona no Arch Linux"
        exit 1
    fi
}

update_system() {
    echo "🔄 Atualizando sistema..."
    if $AUTO_CONFIRM; then
        sudo pacman -Syu --noconfirm
    else
        sudo pacman -Syu
    fi
}

