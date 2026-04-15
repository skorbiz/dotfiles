
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
