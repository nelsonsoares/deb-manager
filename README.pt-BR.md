# 📦 Gerenciador de Desinstalação .DEB

> **🇺🇸 [Read in English](README.md)**

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

```bash
git clone https://github.com/nelsonsoares/gerenciador-deb.git
cd gerenciador-deb
```

### 2. Dê permissão de execução

```bash
chmod +x gerenciador-deb.sh
```

### 3. Crie um alias no terminal (opcional, recomendado)

Para **Zsh** (padrão no Zorin OS 18+):
```bash
echo 'alias deb-uninstall="$HOME/Documentos/gerenciador-deb/gerenciador-deb.sh"' >> ~/.zshrc
source ~/.zshrc
```

Para **Bash**:
```bash
nano ~/.bashrc 
#ou
nano ~/.zshrc

alias deb-uninstall="$HOME/Documentos/gerenciador-deb/gerenciador-deb.sh"

source ~/.bashrc 
#ou 
source ~/.zshrc
```

---

## 💻 Como Usar

### Menu interativo

```bash
deb-uninstall
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
| `deb-uninstall`             | Abre o menu interativo                      |
| `deb-uninstall --list`      | Lista todos os pacotes .deb instalados      |
| `deb-uninstall -l`          | Atalho para `--list`                        |
| `deb-uninstall --remove`    | Vai direto para a tela de desinstalação     |
| `deb-uninstall -r`          | Atalho para `--remove`                      |

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
gerenciador-deb/
├── gerenciador-deb.sh   # Script principal (CLI)
├── README.md            # Documentação (English)
└── README.pt-BR.md      # Documentação (Português)
```

---

## 📝 Licença

Este projeto é de uso livre. Sinta-se à vontade para usar, modificar e distribuir.
