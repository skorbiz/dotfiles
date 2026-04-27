#!/bin/bash

# ============================================================================
# BASH/ZSH ALIASES AND FUNCTIONS
# ============================================================================
# Custom aliases and functions for both bash and zsh
# Installed automatically by install.sh
# ============================================================================

# ============================================================================
# ENVIRONMENT CONFIGURATION
# ============================================================================

# Makes git branch and other commands not use less when output fits on screen
# https://stackoverflow.com/questions/48341920/git-branch-command-behaves-like-less
export LESS=-FRX

# Add custom paths to PATH if they exist
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# FZF UTILITIES
# ============================================================================
# Keybindings: ctrl+r (history), alt+c (cd), cmd **<tab> (autocomplete)

# Interactive command playground - type and see results in real-time
# Usage: try cat ~/.bashrc | grep HIST <Enter>
# Based on: https://www.reddit.com/r/commandline/comments/174t7y4/
function try() {
  export FZF_DEFAULT_COMMAND=echo
  fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

# Fuzzy search environment variables
function fzf-env-vars() {
  local out
  out=$(env | fzf)
  echo "${out#*=}"
}
# ============================================================================
# GIT FUNCTIONS
# ============================================================================
# Convenient git shortcuts and pretty log formats

# Show remote repository information
function git_repo_info() {
  git remote show origin
}

# Safer force push (checks remote hasn't changed)
function git_push_force_safer() {
  git push --force-with-lease
}

# Get current branch name
function git_get_branch_name() {
  git rev-parse --abbrev-ref HEAD
}

# Log commits in current directory
function git_log_folder() {
  git log -- .
}

# Compact log with dates
function git_log_short() {
  git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short
}

# Log with file statistics
function git_log_stat() {
  git log --numstat --oneline
}

# Pretty graph log (last 50 commits)
function git_log_graph() {
  git log --graph --abbrev-commit --decorate \
    --pretty=format:'%C(bold blue)%h %C(reset)- %C(bold green)%cr %C(reset)%C(white)%s %C(reset)%C(white dim)%an %C(reset)%C(bold yellow)%d %C(reset)' -50
}

# Graph log showing only first parent (cleaner for merge-heavy repos)
function git_log_graph_first_parent() {
  git log --graph --abbrev-commit --decorate --first-parent \
    --pretty=format:'%C(bold blue)%h %C(reset)- %C(bold green)%cr %C(reset)%C(white)%s %C(reset)%C(white dim)%an %C(reset)%C(bold yellow)%d %C(reset)' -25
}

# Simple colored graph
function git_log_graph_standard() {
  git log --graph --oneline --decorate -30
}

# Show last commit with changes
function git_previous_commit() {
  git log -p -1
}

# Compare branches: commits
function git_compare() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git log "$1..$branch"
}

# Compare branches: commits with diffs
function git_compare_log() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git log -p "$1..$branch"
}

# Compare branches: unified diff
function git_compare_diff() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git diff "$1..$branch"
}

# Diff between two branches
function git_diff() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git diff "$1..$branch"
}

# Diff statistics between branches
function git_diff_stat() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git diff --stat "$1..$branch"
}

# Diff specific file between branches
# Usage: git_diff_file <branch> <file_path>
function git_diff_file() {
  local branch=$(git rev-parse --abbrev-ref HEAD)
  git diff "$1..$branch" -- "$2"
}

# Open difftool for visual comparison
function git_difftool() {
  git difftool -d "$1"
}

# Show diff for specific stash
# Usage: git_stash_diff 0
function git_stash_diff() {
  git stash show -p "stash@{${1:-0}}"
}

# Open difftool for latest stash
function git_stash_difftool() {
  git difftool -d stash
}

# ============================================================================
# DOCKER UTILITIES
# ============================================================================

# Enter VS Code devcontainer (tries zsh, falls back to bash)
function v() {
  local containers
  containers=$(docker ps | grep vsc- | grep -oE "[^ ]+$")
  
  if [ -z "$containers" ]; then
    echo "No VS Code devcontainer found"
    return 1
  fi
  
  local container
  local count=$(echo "$containers" | awk 'END {print NR}')
  
  if [ "$count" -eq 1 ]; then
    container="$containers"
  else
    echo "Multiple devcontainers found:"
    echo "$containers" | nl
    printf "Select container (1-$count): "
    read choice
    container=$(echo "$containers" | sed -n "${choice}p")
  fi
  
  echo "Connecting to container: $container"
  # Try zsh first, fallback to bash if not available
  if docker exec -w /workspaces/ --user dev "$container" sh -c 'command -v zsh' >/dev/null 2>&1; then
    docker exec -it -w /workspaces/ --user dev "$container" zsh
  else
    docker exec -it -w /workspaces/ --user dev "$container" bash
  fi
}

# ============================================================================  
# APPLICATION LAUNCHERS
# ============================================================================

# Open application and exit terminal
function o() {
  nohup "$@" &> /dev/null &
  disown 
  exit 0
}

# Open application in background, keep terminal alive
function oo() {
  nohup "$@" &> /dev/null & 
  disown 
}

# Autocomplete with command names for both functions
if [[ -n "$BASH_VERSION" ]]; then
  complete -c o
  complete -c oo
elif [[ -n "$ZSH_VERSION" ]]; then
  compdef _command o
  compdef _command oo
fi

# ============================================================================
# FILE SYSTEM NAVIGATION
# ============================================================================

alias c='clear'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../..'
alias ....='cd ../../../..'
alias .....='cd ../../../../..'

# ============================================================================
# LS ALIASES
# ============================================================================

alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias l.='ls -d .* --color=auto'

# ============================================================================
# GREP ALIASES
# ============================================================================

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# ============================================================================
# UTILITIES
# ============================================================================

# Calculator with math support
alias bc='bc -l'

# Tree-like directory structure (if tree command not available)
function tree_impl() {
  ls -aR | grep ":$" | perl -pe 's/:$//;s/[^-][^\/]*\//    /g;s/^    (\S)/└── \1/;s/(^    |    (?= ))/│   /g;s/    (\S)/└── \1/'
}
