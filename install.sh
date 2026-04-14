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
CERROR="\e[31m"
CWARNING="\e[33m"
CINFO="\e[34m"
CRESET="\e[0m"

# The user must not be root
# ============================
if [ "$(whoami)" == "root" ]; then
    echo "This script should not be run as root"
    exit 1
fi

# Install symlinks
# ============================

ln -sf ~/dotfiles/.bash_aliases ~/.bash_aliases
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# # Append source line to existing .bashrc if not already present
# # ============================

# if ! grep -q "source ~/dotfiles/bashrc" ~/.bashrc 2>/dev/null; then
#     echo "" >> ~/.bashrc
#     echo "# Source personal dotfiles" >> ~/.bashrc
#     echo "source ~/dotfiles/bashrc" >> ~/.bashrc
# fi


# # Source things
# # ============================

# extension="bash"
# if [ -n "$ZSH_VERSION" ]; then
#   extension="zsh"
# fi

# source_if_available() {
#   if [ -f "$1" ]; then
#     # shellcheck disable=SC1090
#     source "$1"
#     echo -e $CGOOD "Sourced: $1" $CRESET

#   else
#     echo -e $CERROR "\e[31mNot able to source: $1" $CRESET
#   fi

# }

# source_if_available "${SOFTWARE_ROOT}"/poc/mez_tools/env.bash


# # Ask to update bashrc and zshrc
# # ============================
# echo "Do you want to source dti_tools in your bashrc and zshrc?"
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes ) 
#             source_dti_tools_in_file "$HOME/.bashrc"; 
#             source_dti_tools_in_file "$HOME/.zshrc"; break;;
#         No ) 
#             break;;
#     esac
# done


# Reset the fail-hard flags
set +euo pipefail




