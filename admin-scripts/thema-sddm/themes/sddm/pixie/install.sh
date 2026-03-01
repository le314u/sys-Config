#!/bin/bash

# ==========================================
# Script para instalar e ativar tema SDDM
# ==========================================

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "Execute este script como root: sudo $0"
    exit 1
fi

if ! systemctl is-active --quiet sddm; then
    echo "Erro: Este script requer SDDM como display manager."
    exit 1
fi



# Nome do tema
THEME_NAME="pixie"

# Caminho de origem do tema (alterar para onde você baixou o tema)
SOURCE_DIR="$(pwd)/themes/sddm/$THEME_NAME"

# Caminho de destino do SDDM
DEST_DIR="/usr/share/sddm/themes/$THEME_NAME"

# 1. Instala dependência
echo "Instalando qt5-graphicaleffects..."
sudo pacman -S --noconfirm qt5-graphicaleffects qt5-base qt5-declarative qt5-quickcontrols2

# 2. Copia tema para o diretório do SDDM
echo "Copiando arquivos do tema para $DEST_DIR..."
mkdir -p "$DEST_DIR"
cp -r "$SOURCE_DIR/"* "$DEST_DIR/"

# 3. Atualiza /etc/sddm.conf
SDDM_CONF="/etc/sddm.conf"

if ! grep -q "\[Theme\]" "$SDDM_CONF"; then
    echo -e "\n[Theme]" >> "$SDDM_CONF"
fi

# Define o tema
sed -i "/^\[Theme\]/,/^\[/ s/^Current=.*/Current=$THEME_NAME/" "$SDDM_CONF"

# Caso não exista Current, adiciona
if ! grep -q "^Current=$THEME_NAME" "$SDDM_CONF"; then
    echo "Current=$THEME_NAME" >> "$SDDM_CONF"
fi

echo "Tema '$THEME_NAME' definido no SDDM."

# 4. Reinicia SDDM
echo "Reiniciando SDDM para aplicar o tema..."
systemctl restart sddm

echo "Concluído! O tema '$THEME_NAME' deve estar ativo na tela de login."

