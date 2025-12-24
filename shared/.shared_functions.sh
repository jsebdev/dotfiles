compile_cpp() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: compile_cpp filename.cpp"
    return 1
  fi

  input="$1"

  if [[ ! -f "$input" ]]; then
    echo "Error: '$input' does not exist."
    return 1
  fi

  if [[ "$input" != *.cpp ]]; then
    echo "Error: Input file must have a .cpp extension."
    return 1
  fi

  output="${input%.cpp}"
  g++ -std=c++17 "$input" -o "$output"

  if [[ $? -eq 0 ]]; then
    echo "Compiled successfully to: $output"
  else
    echo "Compilation failed."
  fi
}

search_s3_file() {
  local filename="$1"

  if [[ -z "$filename" ]]; then
    echo "Usage: search_s3_file <filename-or-pattern>" >&2
    return 1
  fi

  aws s3api list-buckets --query 'Buckets[].Name' --output text \
  | tr '\t' '\n' \
  | while read -r bucket; do
      aws s3 ls "s3://$bucket" --recursive 2>/dev/null \
      | grep -F "$filename" \
      | awk -v b="$bucket" '{ print "s3://" b "/" $4 }'
    done
}

backup_claude_config() {
  ~/.dotfiles_scripts/backup_ignored_claude_config.sh
}
