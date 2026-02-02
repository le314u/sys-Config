# ~/.bashrc – versão turbinada 🚀 

# Completar automaticamente nomes de comandos e arquivos
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Carregar alias personalizadas
if [ -f ~/.bash_alias ]; then
    source ~/.bash_alias
fi

# Carregar funções personalizadas
if [ -f ~/.bash_functions ]; then
    source ~/.bash_functions
fi

# Msg Boas vindas
if [ -f ~/.bash_hello ]; then
    source ~/.bash_hello
fi

# Carregar as parafernalhas
if [ -f ~/.bash_misc ]; then
    source ~/.bash_misc
fi

parse_git_branch() {
    # Verifica se estamos dentro de um repositório Git
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Pega o nome do branch atual
        git branch --show-current 2>/dev/null
    fi
}

# Mostrar hora e comando no histórico
PROMPT_COMMAND='history -a; history -c; history -r; echo -ne "\033]0;${PWD/#$HOME/~}\007"'
PS1='\n\[\e[1;36m\]\u@\h \[\e[1;34m\]\w\[\e[0m\]$(
    branch=$(parse_git_branch)
    [ -n "$branch" ] && echo -e "\[\e[1;32m\] [ $branch]\[\e[0m\]"
)\n\$ '


export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="/home/lucas/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/lucas/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
