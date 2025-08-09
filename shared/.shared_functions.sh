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

