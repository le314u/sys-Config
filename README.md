# sys-Config


**sys-Config** é um gerenciador modular de configuração de sistema (dotfiles, scripts e ajustes de ambiente), focado em **clareza, previsibilidade e segurança**.

Ele foi criado para resolver um problema comum: aplicar configurações sem misturar módulos, sem copiar arquivos errados e sem comportamentos implícitos e facilmente configurável.


> Configuração de sistema deve ser **reprodutível**, **legível** e **controlada**.



---








##  Estrutura de diretórios e o papel dos README

Todo o sistema gira em torno de uma pasta raiz chamada dotfiles/ e do uso obrigatório de arquivos README.

A pasta **dotfiles/** é o ponto de entrada único do sys-Config e nada fora de dotfiles/ é processado.

Ela existe para:

1. Delimitar claramente o que faz parte da configuração do sistema

2. Evitar que arquivos fora do escopo sejam aplicados acidentalmente

3. Permitir processamento previsível e reprodutível

4. Manter todas as configurações versionadas e auditáveis



No sys-Config, o **README** não é documentação passiva.
Ele é o contrato do módulo.

* Um diretório só é considerado módulo se tiver um README

* O README define como aquele módulo deve ser aplicado

* Sem README, nada é copiado, linkado ou executado

* Isso elimina ambiguidades e efeitos colaterais.


### Módulo vs Wrapper

A distinção entre módulo e wrapper é fundamental:

* **Diretório com `README` → módulo real**

Pode copiar ou criar links

Pode executar scripts

Pode declarar dependências

* **Diretório sem `README` → wrapper (apenas organização)**

Serve apenas para organizar subdiretórios

Nunca é aplicado diretamente

Wrappers existem para estrutura, não para efeito colateral.

---

## Estrutura de diretórios

Exemplo de estrutura válida:

```
dotfiles/
├── modulo_unico/
│   └── README
│
├── modulo_multiplo/
│   ├── README
│   ├── modulo_A/...
│   └── modulo_B/...
│
├── wrapper/
│   ├── modulo_unico1/
│   │   └── README
│   └── modulo_unico1/
│       └── README
│
└── script/
    ├── only-script.sh
    └── README
```

##  README do módulo (configuração declarativa)

Cada módulo define seu comportamento no arquivo `README`.

### Exemplo

```ini
MODE=link
SOURCE=~/.myConf/hypr
TARGET=~/.config/hypr
BACKUP=false
CLEAN=false
PACKAGE=hyprland
EXEC=post-install.sh
```

### Campos suportados

| Campo   | Descrição                               |
| ------- | --------------------------------------- |
| MODE    | `copy` ou `link`                        |
| SOURCE  | Diretório fonte                         |
| TARGET  | Diretório destino                       |
| BACKUP  | Cria backup antes de aplicar            |
| CLEAN   | Remove SOURCE e TARGET antes de aplicar |
| PACKAGE | Pacote necessário para o módulo         |
| EXEC    | Script opcional pós-instalação          |

📌 O arquivo `README` **é copiado mas não é linkado**.

---

## Fluxo de processamento

1. Percorre os diretórios recursivamente
2. Se encontrar `README` → trata como **módulo**
3. Se não encontrar `README` → trata como **wrapper**


---

## Uso

```
./install.sh [opções]
```

### Opções disponíveis

| Flag                    | Descrição                           |
| ----------------------- | ----------------------------------- |
| `-d`, `--only-dotfiles` | Processa apenas dotfiles            |
| `-p`, `--only-packages` | Processa apenas pacotes             |
| `--nobackup`            | Desativa criação de backup          |
| `-v`                    | Verbose (mostra output no terminal) |
| `--log=arquivo`         | Salva log em arquivo                |
| `-h`, `--help`          | Mostra ajuda                        |

---

## Output e Log
* Output e log são independentes

---

## Status do projeto

Projeto em evolução, usado em ambiente real.
Mudanças priorizam previsibilidade, segurança e simplicidade.

---

## Licença

MIT
