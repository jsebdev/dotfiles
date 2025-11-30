
alias shiftsubs="python ~/coding/shift_subs/shift_subs.py"

# change directories
## personal
alias cddf="cd ~/coding/dotfiles/"

## work
alias cdsf="cd ~/coding/macheight/safefreight/repo/"

load_if_exists ~/.m8_aliases.sh


# jupyter notebooks
ipynb2jupy() {
  local file_to_convert="$1"
  if [[ -z "$file_to_convert" ]]; then
    echo "Usage: ipynb2jupy <notebook_file.ipynb>"
    return 1
  fi
  local filename_without_extension="${file_to_convert%.ipynb}"
  jupytext --to py:percent "$file_to_convert" -o "${filename_without_extension}.ju.py"
}
