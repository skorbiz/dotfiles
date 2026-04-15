#!/bin/bash

# This file installes the various dotfiles. 
# Its mostly developed with vs-code in mind.
# So it may need adjustment down the line.



# shellcheck disable=SC1091
#set -x # Prints all line before execution
set -euo pipefail # Fail hard

# Convinience, checking this script with shellcheck
# ============================
if [ -x "$(command -v shellcheck)" ]; then
 shellcheck --external-sources "$0"
fi

# COLORS
# ============================

CGOOD="\e[32m"
CINFO="\e[34m"
CRESET="\e[0m"
#CERROR="\e[31m"
#CWARNING="\e[33m"

# Get the directory where this script is located
# ============================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The user must not be root
# ============================
if [ "$(whoami)" == "root" ]; then
    echo "This script should not be run as root"
    exit 1
fi

# Install zsh and plugins
# ============================
if command -v zsh >/dev/null 2>&1; then
    echo -e "${CINFO}Zsh already installed, skipping installation${CRESET}"
else
    echo -e "${CINFO}Installing zsh...${CRESET}"
    bash "$SCRIPT_DIR/zsh/install-zsh.sh"
fi

# Install symlinks
# ============================

echo -e "${CINFO}Creating symlinks...${CRESET}"
ln -sf "$SCRIPT_DIR/.bash_aliases" ~/.bash_aliases
ln -sf "$SCRIPT_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$SCRIPT_DIR/zsh/.p10k.zsh" ~/.p10k.zsh

echo -e "${CGOOD}Symlinks created successfully${CRESET}"

echo ""
echo -e "${CGOOD}========================================${CRESET}"
echo -e "${CGOOD}Installation complete!${CRESET}"
echo -e "${CGOOD}========================================${CRESET}"
echo -e "${CINFO}Restart your shell to apply changes.${CRESET}"






