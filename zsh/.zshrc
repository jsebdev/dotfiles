[ -f ~/.dotfiles_utils.sh ] && source ~/.dotfiles_utils.sh

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Set the environment variables to use the LLVM installed by Homebrew. (asked by chatgpt)
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
export PKG_CONFIG_PATH="/usr/local/opt/llvm/lib/pkgconfig"

# postgres
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"


#MQL5 folder alias
export MQLD="$HOME/Library/Application Support/net.metaquotes.wine.metatrader5/drive_c/Program Files/MetaTrader 5/MQL5"


[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env


load_all_shared_scripts

load_if_exists ~/.zsh_secrets.sh
load_if_exists ~/.zsh_aliases.sh

# fzf configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export PATH="$HOME/.local/bin:$PATH"

# avoid special character being part of a word
export WORDCHARS=""
