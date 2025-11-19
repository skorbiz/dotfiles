#!/bin/bash
# set -euo pipefail

#------------------- INSTALL INSTRUCTION ---------------------- #
#
# Create symlink by:
# ln -s ~/Dropbox/workspaces/dotfiles/.bash_aliases "$HOME" 
# echo "source "$HOME/.bash_aliases" > .zshrc 
#


#------------------- Stuff to be included ------------------ #


# export PATH="$PATH:/home/johl/Apps/balena-cli/"
# export PATH="$PATH:/usr/local/go/bin"
# source "$HOME/Dropbox/workspaces/jsl_tools/env.bash"


# fzf playground
# ============================

# ctrl+r	Swoosh through history
# alt+c		Find any dir or file
# cmd **<tab>	Autocomplete anything


items=("aa" "bb" "cc" "dd")
function fzf-ppp(){ 
	echo "Your word is: $(printf "%s\n" "${items[@]}" | fzf -q "$1" --prompt "hi> ")"
}


# print -z pushes command to command-line as opposed to eval which evalues directly 
function fzf-eval(){ 
	print -z "cat $(ls | fzf)"
}


function fzf-preview(){ 
	#fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
	fzf --preview 'cat {}'
}


function fzf-env-vars() {
  local out
  out=$(env | fzf)
  echo $(echo $out | cut -d= -f2)
}


export PATH="/home/johl/Apps/git-fuzzy/bin:$PATH"

function man2(){
  export FZF_DEFAULT_COMMAND=echo
  man ssh | fzf --multi --preview="
                           echo plus {+};
                           echo quey {q};
                           echo file {f};
                           echo n    {n};
                           echo n+   {+n};
                           echo 1.10 {1..10};                           
	  		   man ssh | less +{n};
                           "
}


function try(){
  export FZF_DEFAULT_COMMAND=echo
  fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}



# Based on comments here:
# https://www.reddit.com/r/commandline/comments/174t7y4/play_tui_playground_for_your_favorite_programs/
# Useage example: try cat ~/.bashrc | grep HIST <Enter>
# Type the search quiry and see how it changes in realtime  

# GIT #############################################################################

# Makes git branch and other not use less the message can be displayed on an entire screen.
# https://stackoverflow.com/questions/48341920/git-branch-command-behaves-like-less
export LESS=-FRX

function git_repo_info()
{
 (set -x; git remote show origin)
}

function git_push_force_safer(){
  (set -x;  git push --force-with-lease)
}

function git_get_branch_name(){
  (set -x; git rev-parse --abbrev-ref HEAD)
}

function git_log_folder(){
  (set -x; git log -- .)
}

# %h  ref
# %cr time
# %s  msg
# %an author
# %d  merge

function git_log_short(){
  (set -x; git log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short)
}

function git_log_stat(){
  (set -x; git log --numstat --oneline)
}

function git_log_graph(){
  (set -x; git log --graph --abbrev-commit --decorate \
                   --pretty=format:'%C(bold blue)%h %C(reset)- %C(bold green)%cr %C(reset)%C(white)%s %C(reset)%C(white dim)%an %C(reset)%C(bold yellow)%d %C(reset)' -50)
}

function git_log_graph_first_parent(){
  (set -x; git log --graph --abbrev-commit --decorate --first-parent \
                   --pretty=format:'%C(bold blue)%h %C(reset)- %C(bold green)%cr %C(reset)%C(white)%s %C(reset)%C(white dim)%an %C(reset)%C(bold yellow)%d %C(reset)' -25)
}

function git_log_graph_standart_color(){
  (set -x; git log --graph --oneline --decorate -30)
}

function git_previous_comit(){
  (set -x; git log -p -1)
}

function git_compare(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git log $1..$branch)
}

function git_compare_log(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git log -p $1..$branch)
}

function git_compare_diff(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git diff $1..$branch)
}

function git_diff(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git diff $1..$branch)
}

function git_diff_stat(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git diff --stat $1..$branch)
}

function git_diff_file(){
  branch=$(git rev-parse --abbrev-ref HEAD)
  (set -x; git diff $1..$branch -- $2)
}

function git_difftool(){
  (set -x; git difftool -d $1)
}

function git_stash_diff(){
  (set -x; git stash show -p stash@{$1})
}

function git_stash_difftool(){
  (set -x; git difftool -d stash)
}

function git_local_ignore(){
  (set -x; gedit ~/mir/.git/info/exclude)
}



# OTHER #############################################################################


function m_jupyter(){
  pushd .
  cd ~/Dropbox/Workspaces/Jupyter
  jupyter-notebook
  popd
}


function q(){
  python3 "Dropbox/workspaces/python/tifingersystem.py"
}


# CONVINIENCE ###########################################################################
alias c='clear'

function v(){
  container=$(docker ps | grep vsc- | grep -oE "[^ ]+$")
  #set container (docker container ls | grep -m 1 'vsc' | cut -d " " -f 1)
  echo "container: " $container
  docker exec -it -w /workspaces/ $container zsh
}

# Open application and exit terminal - todo: missing auto-complete features
function o(){
  set -x
  nohup "$@" &> /dev/null &
  disown 
  exit -1
}


# Something dosnt completely work
# Run 'complete -p cd' to e.g. see what function cd autocompletes with 
# complete -o bashdefault -o default -o nospace -F _bash o
# complete -F _executables o
# compdef o=bash
complete -c o

# Open application in thread, keep terminal alive - todo: missing auto-complete features
function oo(){
  set -x
  nohup "$@" &> /dev/null & 
  disown 
}


# https://stackoverflow.com/questions/3455625/linux-command-to-print-directory-structure-in-the-form-of-a-tree
function tree_impl(){
 ls -aR | grep ":$" | perl -pe 's/:$//;s/[^-][^\/]*\//    /g;s/^    (\S)/└── \1/;s/(^    |    (?= ))/│   /g;s/    (\S)/└── \1/'
}

alias m_cmdline_shorten="(set -x; PS1='\u:\W\$ ')"	## Shortning the commandline path
alias m_cmdline_trim="(set -x; PROMPT_DIRTRIM=3)"	## Alternative for trimming the commandline path
alias m_cmdline_wrap_disable="(set -x; tput rmam)"
alias m_cmdline_wrap_enable="(set -x; tput smam)"

alias egrep='egrep --color'
alias fgrep='fgrep --color'

## Colorize the ls output ##
alias ls='ls --color=auto'
## Use a long listing format ##
alias ll='ls -la'
## Show hidden files ##
alias l.='ls -d .* --color=auto'
## a quick way to get out of current directory ##
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

#4: Start calculator with math support
alias bc='bc -l'

#colorscript -r
