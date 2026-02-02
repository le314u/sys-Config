
# ===============================
# Funções úteis
# ===============================

please() {
    local last_cmd
    # Pega o último comando sem o número do history
    last_cmd="$(history -p !!)"

    # Ignora se o último comando já começou com sudo ou com 'please'
    if [[ "$last_cmd" == sudo* ]]; then
        echo "Já tem sudo!"
        return
    elif [[ "$last_cmd" == please* ]]; then
        echo "O último comando já foi 'please', nada a fazer."
        return
    fi

    # Executa com sudo
    sudo $last_cmd
}



# Criar diretório e entrar nele
mkcd () {
    mkdir -p "$1" && cd "$1"
}

# ⬆ Sobe N diretórios (ex: up 2 → ../../)
up() {
    local n=${1:-1}
    local path=""
    for ((i=0; i<n; i++)); do path+="../"; done
    cd "$path" || return
}


# ✅ Mostra ✔️ se o último comando deu certo, ❌ se falhou
status() {
    if [ $? -eq 0 ]; then
        echo "${GREEN}✔${RESET}"
    else
        echo "${RED}✘${RESET}"
    fi
}

# Compactar diretório em .tar.gz
backupdir () {
    local dir="${1:-.}"
    local name=$(basename "$dir")
    tar -czf "${name}_$(date +%Y%m%d_%H%M%S).tar.gz" "$dir"
    echo "📦 Backup criado: ${name}_$(date +%Y%m%d_%H%M%S).tar.gz"
}

# Subir um servidor HTTP local (na pasta atual)
serve () {
    local port=${1:-8000}
    echo "🌐 Servindo em http://localhost:$port"
    python3 -m http.server "$port"
}

# Mostrar uso de disco organizado por tamanho
dusage () {
    du -h --max-depth=1 2>/dev/null | sort -hr
}


# Buscar rapidamente dentro de arquivos
ftext () {
    grep -Rni "$1" .
}

# Mostrar IP público
myip () {
    curl -s ifconfig.me && echo
    curl -4 -s ifconfig.me && echo
}


# Ver histórico de pacotes instalados recentemente
recentpkgs () {
    grep -A1 "\[ALPM\] installed" /var/log/pacman.log | tail -n 20
}

# Mostrar infos do sistema (resumo rápido)
sysinfo () {
    echo "🖥️ Sistema: $(lsb_release -d | cut -f2)"
    echo "🧠 Memória: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo "⚙️ Kernel: $(uname -r)"
    echo "📦 Pacotes: $(pacman -Q | wc -l)"
    echo "🔌 Uptime: $(uptime -p)"
}

# Recarregar o .bashrc rapidamente
reload () {
    source ~/.bashrc && echo "✅ .bashrc recarregado!"
}

# Adiciona função para mostrar hotkeys do Kitty
# ==========================
# FUNÇÃO SHORTCUT - KITTY PRO
# ==========================
shortcut() {
  echo -e "\e[1;35m🔥 Hotkeys do Kitty Pro-Level 🔥\e[0m\n"

  echo -e "\e[1;33m🔹 Janelas / Abas\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+Enter\e[0m → Nova janela"
  echo -e "  \e[1;36mCtrl+Shift+T\e[0m → Nova aba"
  echo -e "  \e[1;36mCtrl+Shift+W\e[0m → Fechar janela/aba\n"

  echo -e "\e[1;33m🔹 Navegação\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+H\e[0m → Janela anterior"
  echo -e "  \e[1;36mCtrl+Shift+L\e[0m → Próxima janela\n"

  echo -e "\e[1;33m🔹 Splits\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+V\e[0m → Split vertical"
  echo -e "  \e[1;36mCtrl+Shift+B\e[0m → Split horizontal\n"

  echo -e "\e[1;33m🔹 Fonte & Aparência\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+↑\e[0m → Aumentar fonte"
  echo -e "  \e[1;36mCtrl+Shift+↓\e[0m → Diminuir fonte"
  echo -e "  \e[1;36mCtrl+Shift+F11\e[0m → Tela cheia\n"

  echo -e "\e[1;33m🔹 Scroll & Histórico\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+K\e[0m → Scroll linha para cima"
  echo -e "  \e[1;36mCtrl+Shift+J\e[0m → Scroll linha para baixo"
  echo -e "  \e[1;36mCtrl+Shift+U\e[0m → Scroll meia página para cima"
  echo -e "  \e[1;36mCtrl+Shift+D\e[0m → Scroll meia página para baixo"
  echo -e "  \e[1;36mCtrl+Shift+F\e[0m → Pesquisar no histórico\n"

  echo -e "\e[1;33m🔹 Clipboard\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+C\e[0m → Copiar"
  echo -e "  \e[1;36mCtrl+Shift+V\e[0m → Colar\n"

  echo -e "\e[1;33m🔹 Screenshots\e[0m"
  echo -e "  \e[1;36mCtrl+Shift+S\e[0m → Screenshot de área selecionada\n"

  echo -e "\e[1;32m💡 Dica: Todos os atalhos usam Ctrl+Shift como prefixo por padrão.\e[0m"
}
