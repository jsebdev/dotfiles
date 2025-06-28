load_if_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        source "$file"
    else
        echo "Warning: '$file' not found. Skipping."
    fi
}
