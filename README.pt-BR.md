# 📦 Gerenciador de Desinstalação .DEB

> **🇺🇸 [Leia em Inglês](README.md)**

Script em Bash para listar e desinstalar permanentemente programas instalados via arquivos `.deb` no **Ubuntu, Zorin OS, Linux Mint** e derivados do Debian.

## 🤔 O Problema

Quando você instala um programa a partir de um arquivo `.deb` (clicando duas vezes nele), o sistema abre a **Loja de Apps** (GNOME Software / App Center) para fazer a instalação. Porém, depois de instalado:

- O programa **não aparece na listagem** de apps da Loja;
- Para desinstalar, você precisaria **baixar o .deb novamente** e abri-lo na Loja apenas para localizar o botão "Remover";
- Mesmo usando comandos convencionais do sistema, pastas de dados do usuário e cache (`~/.config`, `~/.cache`, `~/.local/share`) continuam no seu disco.

## ✅ A Solução

Este script identifica automaticamente **todos os pacotes instalados localmente** (fora de repositórios oficiais) usando o próprio sistema de gerenciamento de pacotes (`apt`/`dpkg`), e oferece via terminal:

- **Listagem** clara e organizada com nome, versão e descrição;
- **Desinstalação 100% Permanente** (`purge`): remove binários do sistema, arquivos em `/etc` e dependências órfãs;
- **Limpeza de Dados do Usuário**: localiza e oferece remoção de arquivos e pastas residuais na sua home (`~/.config`, `~/.cache`, `~/.local/share`, `~/.<app>`);
- **Aviso de segurança** com confirmação obrigatória (digitar `sim`) antes de qualquer remoção;
- **Diagnóstico de erros** com sugestões práticas de correção caso algo falhe.

---

## 🚀 Instalação

### 1. Clone o repositório

Você pode clonar em qualquer diretório da sua máquina (ex: pasta atual ou `Downloads`):

```bash
git clone https://github.com/nelsonsoares/deb-manager.git
cd deb-manager
```

### 2. Configurar a pasta de destino (`~/Documentos/deb-manager`)

O alias configurado espera que o script esteja localizado em `~/Documentos/deb-manager/` (`$HOME/Documentos/deb-manager/`).

#### Opção A: Via Terminal (Rápido)
Execute estes comandos de dentro da pasta clonada para criar a pasta de destino e mover o script para lá:

```bash
mkdir -p "$HOME/Documentos/deb-manager"
mv deb-manager.sh "$HOME/Documentos/deb-manager/"
chmod +x "$HOME/Documentos/deb-manager/deb-manager.sh"
```

#### Opção B: Manualmente (Via Gerenciador de Arquivos)
1. Abra o Gerenciador de Arquivos e vá até a sua pasta **Home** (Pasta Pessoal).
2. Acesse ou crie a pasta **`Documentos`** (caso não exista).
3. Dentro de `Documentos`, crie uma nova pasta chamada **`deb-manager`**.
4. Copie ou mova o arquivo **`deb-manager.sh`** para dentro de `~/Documentos/deb-manager/`.
5. Garanta que o arquivo tenha permissão de execução (clique com o botão direito em `deb-manager.sh` → **Propriedades** → **Permissões** → marque **"Permitir execução do arquivo como programa"**, ou execute `chmod +x ~/Documentos/deb-manager/deb-manager.sh` no terminal).

---

### 3. Crie um alias no terminal (opcional, recomendado)

Abra o arquivo de configuração do seu shell usando o editor de texto de sua preferência (usamos o `nano` como exemplo por vir instalado por padrão na maioria das distribuições Linux, mas você pode usar `vim`, `gedit`, `vscode` ou qualquer outro de sua escolha):

Para **Bash ou ZSH**:
```bash
nano ~/.bashrc 
#ou
nano ~/.zshrc

alias ger-deb="$HOME/Documentos/deb-manager/deb-manager.sh"

source ~/.bashrc 
#ou 
source ~/.zshrc
```

---

## 💻 Como Usar

### Menu interativo

```bash
ger-deb
```

Exibe o menu principal com as opções:

```
======================================================================
             GERENCIADOR DE DESINSTALAÇÃO DE .DEB (CLI)
======================================================================

  1) Listar programas .deb instalados
  2) Desinstalar programa permanentemente (Purge)
  0) Sair
```

### Acesso direto (atalhos)

| Comando                     | Ação                                        |
|-----------------------------|---------------------------------------------|
| `ger-deb`                   | Abre o menu interativo                      |
| `ger-deb --list`            | Lista todos os pacotes .deb instalados      |
| `ger-deb -l`                | Atalho para `--list`                        |
| `ger-deb --remove`          | Vai direto para a tela de desinstalação     |
| `ger-deb -r`                | Atalho para `--remove`                      |

### Navegação

Em **todas as telas** do script:
- **`m`** → Volta ao menu principal
- **`0`** → Sai do gerenciador

---

## 🛡️ Segurança e Limpeza Completa

Durante o processo de desinstalação:

1. Exibe um **aviso crítico** detalhando tudo que será apagado;
2. Exige confirmação explícita digitando a palavra **`sim`**;
3. Efetua o purge completo do sistema (`apt-get purge` e `autoremove --purge`);
4. Escaneia e lista pastas residuais na pasta pessoal do usuário (`~/.config/app`, `~/.cache/app`, etc.) e pergunta se deseja excluí-las, garantindo **remoção 100% limpa**.

---

## 🔍 Diagnóstico de Erros

Caso a desinstalação falhe, o script identifica automaticamente a causa e sugere uma correção:

| Erro Detectado                     | Sugestão                                                        |
|------------------------------------|-----------------------------------------------------------------|
| Permissão negada                   | Verificar acesso sudo com `sudo -v`                             |
| Gerenciador de pacotes travado     | Fechar a Loja de Apps e executar `sudo dpkg --configure -a`     |
| Conflito de dependências           | Corrigir com `sudo apt-get install -f`                          |
| Pacote não encontrado              | Verificar status com `dpkg -s nome-do-pacote`                   |
| Erro genérico                      | Reparar sistema de pacotes com `sudo dpkg --configure -a`       |

---

## 📋 Requisitos

- **Sistema Operacional:** Ubuntu, Zorin OS, Linux Mint ou qualquer derivado Debian
- **Dependências:** `bash`, `apt`, `dpkg`, `sudo` (já pré-instalados em todos os sistemas compatíveis)
- **Permissão:** Acesso `sudo` para desinstalar pacotes

---

## 📁 Estrutura do Projeto

```
deb-manager/
├── deb-manager.sh       # Script principal (CLI)
├── README.md            # Documentação (English)
└── README.pt-BR.md      # Documentação (Português)
```

---

## 📝 Licença

Este projeto é de uso livre. Sinta-se à vontade para usar, modificar e distribuir.
