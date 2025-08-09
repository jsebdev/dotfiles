[ -f ~/.dotfiles_utils.sh ] && source ~/.dotfiles_utils.sh

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/sebastian/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/sebastian/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/sebastian/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/sebastian/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# AWS options
export AWS_PROFILE=mach8




# Set the environment variables to use the LLVM installed by Homebrew. (asked by chatgpt)
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
export PKG_CONFIG_PATH="/usr/local/opt/llvm/lib/pkgconfig"

# postgres
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

#MQL5 folder alias
export MQLD="/Users/sebastian/Library/Application Support/net.metaquotes.wine.metatrader5/drive_c/Program Files/MetaTrader 5/MQL5"


[ -f "/Users/sebastian/.ghcup/env" ] && . "/Users/sebastian/.ghcup/env" # ghcup-env


export AWS_PROFILE=sebastian-onerallypoint

load_if_exists ~/.dotfiles_shared.sh

load_if_exists ~/.zsh_secrets.sh
load_if_exists ~/.zsh_aliases.sh
