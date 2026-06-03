_m8_functions_dir="$(dirname "$(realpath "$HOME/.m8_functions.sh")")/m8_functions"
for _m8_file in "$_m8_functions_dir"/*.sh; do
    [[ -f "$_m8_file" ]] && source "$_m8_file"
done
unset _m8_functions_dir _m8_file
