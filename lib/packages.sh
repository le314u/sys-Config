#!/bin/bash

PKGS=(git peek vim chromium code nodejs php python wofi nautilus fzf btop)

install_packages() {
    echo "📦 Instalando pacotes..."
    for pkg in "${PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            echo "✔ $pkg já instalado"
        else
            echo "➡ Instalando $pkg"
            if $AUTO_CONFIRM; then
                sudo pacman -S --noconfirm "$pkg"
            else
                sudo pacman -S "$pkg"
            fi
        fi
    done
}

