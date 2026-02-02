#!/usr/bin/env bash
set -euo pipefail

# Variáveis
USER_BIN="$HOME/.local/bin"
TMP_VOID="/tmp/void"
LINK_VOID="$HOME/void"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# Criar diretórios necessários
mkdir -p "$USER_BIN" "$TMP_VOID" "$SYSTEMD_USER_DIR"

# Criar link simbólico
if [ ! -L "$LINK_VOID" ]; then
    ln -s "$TMP_VOID" "$LINK_VOID"
    echo "✅ Link criado: $LINK_VOID -> $TMP_VOID"
else
    echo "ℹ️ Link já existe: $LINK_VOID"
fi

# Detectar systemd
if command -v systemctl >/dev/null 2>&1 && pidof systemd >/dev/null 2>&1; then
    echo "ℹ️ systemd detectado. Criando serviço de monitoramento..."

    # void.service
    cat > "$SYSTEMD_USER_DIR/void.service" <<'EOF'
[Unit]
Description=Recria /tmp/void e link ~/void
Wants=void.path

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash -c '
mkdir -p /tmp/void
ln -sf /tmp/void "$HOME/void"
'
EOF

    # void.path
    cat > "$SYSTEMD_USER_DIR/void.path" <<'EOF'
[Unit]
Description=Monitora ~/void e dispara void.service se não existir

[Path]
PathExistsGlob=%h/void

[Install]
WantedBy=default.target
EOF

    # Recarregar systemd e habilitar serviço
    systemctl --user daemon-reload
    systemctl --user enable --now void.path

    echo "✅ void.service e void.path criados e ativados!"
    echo "   /tmp/void e ~/void serão recriados automaticamente se deletados."
else
    echo "⚠️ systemd não detectado. Apenas o link foi criado."
fi
