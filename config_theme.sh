#!/bin/bash

# ==========================================
# Script para instalar e ativar tema SDDM
# ==========================================

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "Execute este script como root: sudo $0"
    exit 1
fi

# Verifica se SDDM é o display-manager configurado
if ! readlink -f /etc/systemd/system/display-manager.service | grep -q "sddm.service"; then
    echo "Erro: Este script requer SDDM como display manager."
    exit 1
fi

THEME_NAME="pixie"
SOURCE_DIR="$PWD/themes/sddm/$THEME_NAME"
DEST_DIR="/usr/share/sddm/themes/$THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

echo "Instalando dependências..."
pacman -S --noconfirm qt5-graphicaleffects qt5-base qt5-declarative qt5-quickcontrols2

echo "Copiando tema para $DEST_DIR..."
mkdir -p "$DEST_DIR"
cp -r "$SOURCE_DIR/"* "$DEST_DIR/"

# Garante que o arquivo exista
touch "$SDDM_CONF"

# Garante seção [Theme]
if ! grep -q "^\[Theme\]" "$SDDM_CONF"; then
    echo -e "\n[Theme]" >> "$SDDM_CONF"
fi

# Remove qualquer Current antigo dentro da seção Theme
sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=$THEME_NAME/" "$SDDM_CONF"

# Se ainda não existir Current na seção, adiciona
if ! grep -A5 "^\[Theme\]" "$SDDM_CONF" | grep -q "^Current="; then
    sed -i "/^\[Theme\]/a Current=$THEME_NAME" "$SDDM_CONF"
fi

echo "Tema '$THEME_NAME' definido."

echo "Reiniciando SDDM..."
systemctl restart sddm

echo "Concluído! Tema aplicado com sucesso."
