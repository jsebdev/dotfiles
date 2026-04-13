pkill() {
  for argument in "$@"; do
    if [[ "$argument" == "." ]]; then
      echo "pkill: argument '.' is too broad and has been blocked to prevent killing all processes."
      return 1
    fi
  done
  command pkill "$@"
}

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


look_comments_in_current_pr() {
  local regex=""
  local reviewer=""

  # --- Parse arguments ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --reviewer)
        reviewer="$2"
        shift 2
        ;;
      --regex|-E)
        regex="$2"
        shift 2
        ;;
      --help)
        echo "Usage: look_comments_in_current_pr [--reviewer <username>] [--regex <pattern>]"
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done

  # --- Resolve PR number ---
  local pr_number
  pr_number=$(gh pr view --json number -q '.number') || {
    echo "Error: Not in a PR context or unable to determine PR number."
    return 1
  }

  # --- Resolve repo ---
  local repo
  repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner') || {
    echo "Error: Unable to determine repository."
    return 1
  }

  # --- Fetch + filter ---
  gh api "repos/${repo}/pulls/${pr_number}/comments" --paginate |
    jq --arg regex "$regex" --arg reviewer "$reviewer" '
      .[]
      | if ($regex == "") then . else select(.body | test($regex; "i")) end
      | if ($reviewer == "")
          then .
          else select(.user.login == $reviewer)
        end
      | {body, start_line, line, path, user: .user.login}
    '
}
