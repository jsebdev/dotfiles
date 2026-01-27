load_if_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        source "$file"
    else
        echo "Warning: '$file' not found. Skipping."
    fi
}

load_all_shared_scripts() {
    # Load all shared scripts that are symlinked in the home directory
    load_if_exists ~/.dotfiles_shared.sh
    load_if_exists ~/.shared_aliases.sh
    load_if_exists ~/.shared_functions.sh
    load_if_exists ~/.m8_aliases.sh
    load_if_exists ~/.m8_functions.sh
}
