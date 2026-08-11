# Dotfiles

Small personal dotfiles setup.
Include setup for shell, git, qtile and vs-code.

## Setup

The setup is for use both in ubuntu with full window manager replacement and more locally in wsl, vs-code devcontainer or other terminal based setups.

### Manual Installation

Run the installation script:

```bash
cd ~/dotfiles
./install.sh
```

This will:

1. Install zsh and all plugins (oh-my-zsh, powerlevel10k, fzf, etc.)
2. Create symlinks for config files
3. Set up your environment

Then restart your shell (or log out and back in).

### VS Code Dev Containers

When using the VS Code Dev Containers extension, set this repo as your dotfiles repository. VS Code will clone/update it automatically, and your setup will re-run when you reload/rebuild the container.

In VS Code settings, set:

```json
{
   "dotfiles.repository": "skorbiz/dotfiles",
   "dotfiles.targetPath": "~/dotfiles",
}
```

![vs-code settings](docs/vscode.png)

#### Devcontainer Sudo Configuration

The installation scripts require sudo access to install zsh and related packages. For devcontainers, add this to your Dockerfile to allow the dev user to run apt without a password:

```dockerfile
# Allow dev user to run apt/apt-get without password for dotfiles installation
RUN echo 'dev ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get' >> /etc/sudoers

# Or, for full passwordless sudo for a less secure but more flexible setup:
# RUN echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

```

If sudo is not available, the installation will continue with pre-installed packages.

#### Testing Changes Without Rebuilding

To test zsh configuration changes without committing and rebuilding your container, create a `~/.zshrc.local` file in your devcontainer. This file will be sourced automatically at the end of `.zshrc`, allowing you to override settings or add temporary configurations. Once you've verified your changes work, move them to the dotfiles repository.

#### Credits

The vs-code integration is inspired by: [kaspertofte/dotfiles](https://github.com/kaspertofte/dotfiles/tree/main)

## Tools

### Zsh

- **oh-my-zsh** - Framework for managing zsh configuration
- **powerlevel10k** - Fast, customizable prompt theme
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting for commands
- **zsh-z** - Directory jumper
- **fzf** - Fuzzy finder for command history and file search

### Bash

- Custom aliases in `.bash_aliases`

### VS Code

Automatic extension installation for devcontainers and VS Code Remote environments. Extensions are managed in `vscode/extensions.txt` and installed automatically during dotfiles setup. See [vscode/README.md](vscode/README.md) for details.

### Qtile

Window manager configuration (for full Ubuntu installations)

### Picom

Compositor configuration
