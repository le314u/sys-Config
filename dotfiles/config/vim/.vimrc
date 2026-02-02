"====== CONFIGURAÇÕES BÁSICAS ======
set nocompatible              " Desativa compatibilidade com vi
set number                    " Mostra números das linhas
set cursorline                " Destaca linha atual
set showmatch                 " Mostra o par de parênteses/chaves
set smartindent               " Indentação inteligente
set tabstop=4                 " Largura de tab = 4 espaços
set shiftwidth=4              " Autoindent usa 4 espaços
set expandtab                 " Converte tab em espaços
set nowrap                    " Não quebra linhas automaticamente
set clipboard=unnamedplus     " Usa clipboard do sistema
set encoding=utf-8
syntax on                     " Ativa syntax highlight
filetype plugin indent on     " Detecta tipo de arquivo

" ====== BUSCA ======
set ignorecase                " Ignora maiúsculas/minúsculas
set smartcase                 " Mas respeita se tiver maiúsculas
set incsearch                 " Busca incremental
set hlsearch                  " Destaca resultados da busca

" ====== VISUAL ======
set termguicolors             " Cores verdadeiras (para terminais modernos)
colorscheme habamax           " Tema moderno (vem no Vim)

" ====== QUALIDADE DE VIDA ======
set mouse=a                   " Habilita mouse
set scrolloff=8               " Mantém margem ao rolar
set splitbelow splitright     " Splits abrem de forma previsível
set updatetime=300            " Atualiza plugins e diagnósticos mais rápido
set signcolumn=yes            " Mostra coluna de sinais (lint, git, etc.)

" ====== MAPEAMENTOS ======
nnoremap <SPACE> :noh<CR>     " SPACE limpa destaques da busca
inoremap jk <ESC>             " Sai do modo insert com 'jk'
nnoremap <C-s> :w<CR>         " Ctrl+S salva
inoremap <C-s> <ESC>:w<CR>    " Ctrl+S salva no insert
inoremap <C-q> <ESC>:q<CR>    " Ctrl+q sair
" Alternar número relativo
nnoremap <leader>rn :set relativenumber!<CR>
inoremap <C-d> <C-R>=strftime("%Y-%m-%d")<CR>    " Ctrl+D insere data

" Mover linhas visualmente (como no VSCode)
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

nnoremap <leader>us i<C-R>=$USER<CR><Esc>

" Inserir data/hora rapidamente
nnoremap <leader>dt i<C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR><Esc>

" === TEMA ===
colorscheme habamax

