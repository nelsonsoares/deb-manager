# 📦 DEB Uninstall Manager

> **🇧🇷 [Read in Portuguese](README.pt-BR.md)**

A Bash CLI tool to list and permanently uninstall programs installed via `.deb` files on **Ubuntu, Zorin OS, Linux Mint**, and other Debian-based distributions.

## 🤔 The Problem

When you install a program from a `.deb` file (by double-clicking it), the system opens the **Software Store** (GNOME Software / App Center) to handle the installation. However, after it's installed:

- The program **doesn't show up** in the Store's installed apps list;
- To uninstall it, you'd need to **download the .deb file again** and open it in the Store just to find the "Remove" button;
- Even when uninstalled via standard package managers, residual user configs and cache folders (`~/.config`, `~/.cache`, `~/.local/share`) remain behind on your disk.

## ✅ The Solution

This script automatically identifies **all locally installed packages** (outside official repositories) using the native package management system (`apt`/`dpkg`), and provides via terminal:

- **Clear listing** with name, version, and description;
- **100% Complete & Permanent Uninstallation** (`purge`): removes system binaries, system configurations in `/etc`, and orphaned dependencies;
- **User Data Cleanup**: detects and offers to delete leftover app data and caches located in your user's home directory (`~/.config`, `~/.cache`, `~/.local/share`, `~/.<app>`);
- **Safety warning** with mandatory confirmation (type `sim`/`yes`) before any deletion;
- **Error diagnostics** with practical fix suggestions if something goes wrong.

---

## 🚀 Installation

### 1. Clone the repository

You can clone it to any folder on your machine (e.g., your current directory or `Downloads`):

```bash
git clone https://github.com/nelsonsoares/deb-manager.git
cd deb-manager
```

### 2. Set up the target folder (`~/Documentos/deb-manager`)

The configured alias expects the script to be located in `~/Documentos/deb-manager/` (`$HOME/Documentos/deb-manager/`).

#### Option A: Via Terminal (Automated)
Run these commands from inside the cloned folder to create the destination directory and move the script there:

```bash
mkdir -p "$HOME/Documentos/deb-manager"
mv deb-manager.sh "$HOME/Documentos/deb-manager/"
chmod +x "$HOME/Documentos/deb-manager/deb-manager.sh"
```

#### Option B: Manually (Via File Manager)
1. Open your File Manager and navigate to your **Home** folder (`~/`).
2. Open or create the **`Documentos`** folder (if it doesn't already exist).
3. Inside `Documentos`, create a new folder named **`deb-manager`**.
4. Copy or move the file **`deb-manager.sh`** into `~/Documentos/deb-manager/`.
5. Ensure the file has execution permissions (Right-click `deb-manager.sh` → **Properties** → **Permissions** → check **"Allow executing file as program"**, or run `chmod +x ~/Documentos/deb-manager/deb-manager.sh` in the terminal).

---

### 3. Create a terminal alias (optional, recommended)

Open your shell configuration file using any text editor of your choice (we use `nano` as an example since it is pre-installed on most Linux distributions, but you can use `vim`, `gedit`, `vscode`, or any other editor):

For **Bash or ZSH**:
```bash
nano ~/.bashrc 
#or
nano ~/.zshrc

alias ger-deb="$HOME/Documentos/deb-manager/deb-manager.sh"

source ~/.bashrc 
#or 
source ~/.zshrc
```

---

## 💻 Usage

### Interactive menu

```bash
ger-deb
```

Displays the main menu:

```
======================================================================
             GERENCIADOR DE DESINSTALAÇÃO DE .DEB (CLI)
======================================================================

  1) Listar programas .deb instalados
  2) Desinstalar programa permanentemente (Purge)
  0) Sair
```

### Direct access (shortcuts)

| Command                     | Action                                      |
|-----------------------------|---------------------------------------------|
| `ger-deb`                   | Opens the interactive menu                  |
| `ger-deb --list`            | Lists all installed .deb packages           |
| `ger-deb -l`                | Shortcut for `--list`                       |
| `ger-deb --remove`          | Goes directly to the uninstall screen       |
| `ger-deb -r`                | Shortcut for `--remove`                     |

### Navigation

On **every screen** of the script:
- **`m`** → Go back to the main menu
- **`0`** → Exit the manager

---

## 🛡️ Safety & Complete Cleanup

Before and during uninstallation:

1. Displays a **critical warning** detailing everything that will be removed;
2. Requires explicit confirmation: typing **`sim`** to proceed;
3. Executes a system purge (`apt-get purge` and `autoremove --purge`);
4. Scans for remaining user folders (e.g., `~/.config/app`, `~/.cache/app`) and asks if you also want them deleted, guaranteeing **zero residual files**.

---

## 🔍 Error Diagnostics

If the uninstallation fails, the script automatically identifies the cause and suggests a fix:

| Detected Error                     | Suggested Fix                                                   |
|------------------------------------|-----------------------------------------------------------------|
| Permission denied                  | Check sudo access with `sudo -v`                                |
| Package manager locked             | Close the App Store and run `sudo dpkg --configure -a`          |
| Dependency conflict                | Fix with `sudo apt-get install -f`                              |
| Package not found                  | Check status with `dpkg -s package-name`                        |
| Generic error                      | Repair package system with `sudo dpkg --configure -a`           |

---

## 📋 Requirements

- **Operating System:** Ubuntu, Zorin OS, Linux Mint, or any Debian-based distro
- **Dependencies:** `bash`, `apt`, `dpkg`, `sudo` (pre-installed on all compatible systems)
- **Permissions:** `sudo` access to uninstall packages

---

## 📁 Project Structure

```
deb-manager/
├── deb-manager.sh       # Main script (CLI)
├── README.md            # Documentation (English)
└── README.pt-BR.md      # Documentation (Português)
```

---

## 📝 License

This project is free to use. Feel free to use, modify, and distribute.
