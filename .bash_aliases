#!/bin/bash
# set -euo pipefail

#------------------- INSTAKK INSTRUCTION ---------------------- #
#
# Create symlink by:
# ln -s ~/Dropbox/workspaces/dotfiles/.bash_aliases "$HOME" 
# echo "source "$HOME/.bash_aliases" > .zshrc 
#


#------------------- Stuff to be included ------------------ #

export PATH="$PATH:/home/johl/Apps/balena-cli/"
export PATH="$PATH:/usr/local/go/bin"

source "$HOME/Dropbox/workspaces/jsl_tools/env.bash"

# TRY #############################################################################

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

# Function to open application and close terminal - todo: missing auto-complete features
function o(){
  set -x
  nohup "$@" &> /dev/null &
  
  disown 
  exit -1
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




# ROS1 ############################################################################

function remote_ros() {
  export ROS_MASTER_URI=http://$1:11311
  export ROS_HOSTNAME=$(ifconfig wlp3s0 | sed -n '2s/[^:]*:\([^ ]*\).*/\1/p')
  export ROS_IP=""
  ssh -t mirex@$1 "export ROS_HOSTNAME=\$(ifconfig wlp2s0 | sed -n '2s/[^:]*:\([^ ]*\).*/\1/p')"

  echo "ROS_MASTER_URI: $ROS_MASTER_URI" # http://192.168.12.20:11311
  echo "ROS_HOSTNAME:   $ROS_HOSTNAME"   # 192.168.16.22
  echo "ROS_IP:         $ROS_IP"         # 192.168.16.254

  echo "Restart ros on remote if on mir_robot wify"
  echo "  use 'roslaunch mirCommon mir_bringup.launch' as ROS_HOSTNAME is overriden by 'service mir_service start')" 
 
  # ROS_IP - if you are specifying an IP #address, 
  # ROS_HOSTNAME - if you are specifying a host name. 
  # The options are mutually exclusive, ROS_HOSTNAME takes precedence. 
}

alias m_catkin_config_release='catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release'
alias m_catkin_config_relwithdebinfo='catkin config --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo'

# ------------ vs-code auto-complete -------------#
# mir_cd
# mir_ros_make -DCMAKE_EXPORT_COMPILE_COMMANDS=1
# find ./robot/ros/build -type f -name 'compile_commands.json' -exec cat {} \; > compile_commands.json
# sed -i 's/\]\[/,/g' compile_commands.json
#
# Open c_cpp_properties.json and add
#  "compileCommands":"/usr/local/mir/software/compile_commands.json"
#


#colorscript -r
