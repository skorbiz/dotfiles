#!/bin/bash
# Install zsh, oh-my-zsh, and plugins
set -euo pipefail

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck --external-sources "$0" || true
fi

# Install zsh
echo "Installing zsh, wget, git..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends zsh wget git curl

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "oh-my-zsh already installed"
fi

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

echo "Installing zsh plugins..."
[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ] && \
  git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"

# Install fzf
if [ ! -d "$HOME/.fzf" ]; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
else
  echo "fzf already installed"
fi

echo "Zsh installation complete!"
