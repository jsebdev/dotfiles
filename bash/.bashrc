[ -f ~/.dotfiles_utils.sh ] && source ~/.dotfiles_utils.sh
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Installing pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

alias code='/mnt/c/Users/sebas/AppData/Local/Programs/Microsoft\ VS\ Code/bin/code'



# Make sure the ssh-agent is always running
if ! pgrep ssh-agent > /dev/null; then
	eval "$(ssh-agent -s)"
fi


# Set up the OpenAI API key and the Anthropic API key
export OPENAI_API_KEY=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
export ANTHROPIC_API_KEY=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

LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS

export LESS='-iFRX'

# forward volition staging db to localport in 5432
volition_toggle_staging_db_forwarding() {
    local pid=$(ps aux | grep -E "viq-staging.*juliana" | grep -v grep | awk '{print $2}')

    if ps -p $pid > /dev/null 2>&1; then
        kill -9 $pid
        echo "Closed SSH tunnel with PID: $pid"
        return 0
    fi

    ssh viq-staging -N -f -L 5432:juliana-test-db.cncuapehhqhq.us-east-1.rds.amazonaws.com:5432 2>/tmp/f_volition_staging_db_error.log
    local pid=$(ps aux | grep -E "viq-staging.*juliana" | grep -v grep | awk '{print $2}')

    if [ -s /tmp/f_volition_staging_db_error.log ]; then
        echo "Something happened while trying to establish the SSH tunnel"
        cat /tmp/f_volition_staging_db_error.log
        if ps -p $pid > /dev/null 2>&1; then
            kill -9 $pid
            echo "Process with PID $pid was started and immediately killed."
            return 1
        fi
    fi

    echo "SSH tunnel established with PID: $pid"
}

# check one rally point lint:
rallyclaim_lints() {
    cd /home/ubuntu/coding/macheight/onerallypoint/rallyclaim
    docker compose run --rm react npm run lint
    docker compose run --rm react npm run typecheck
    docker compose run --rm django mypy .
    docker compose run --rm django ruff check .
}

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

. "$HOME/.cargo/env"


complete -C /usr/bin/terraform terraform

export AWS_PROFILE=default

load_if_exists ~/.dotfiles_shared.sh
load_if_exists ~/.bash_aliases.sh
