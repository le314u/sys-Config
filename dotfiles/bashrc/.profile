
# ~/.profile — configurações de sessão de login

# Evita recarregar se já foi carregado
[ -n "$PROFILE_LOADED" ] && return
export PROFILE_LOADED=1

# =============================================
# Alias gerais (válidos para todo shell login)
# =============================================
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -A'
alias grep='grep --color=auto'

# =============================================
# Variáveis de ambiente
# =============================================
export EDITOR=vim
export VISUAL=code
export BROWSER=chromium
export TERMINAL=kitty

# =============================================
# Configurações de linguagem
# =============================================
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# =============================================
# Configurações Personalizada
# =============================================
export QUICK_NOTE=code

# =============================================
# PATH — caminhos extras
# =============================================
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# =============================================
# Carregar ~/.bashrc se existir
# =============================================
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

PS1='\[\e[1;36m\]\u@\h \[\e[1;34m\]\w\[\e[1;32m\]$(branch=$(parse_git_branch); [ -n "$branch" ] && echo " [ $branch]")\[\e[0m\]\n\$ '
