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


ecs_connect() {
    echo "Fetching ECS clusters..."
    local clusters_raw
    clusters_raw=$(aws ecs list-clusters --query 'clusterArns[]' --output text 2>&1)
    if echo "$clusters_raw" | grep -q "AccessDeniedException"; then
        echo "Error: Access denied. Log in first (e.g. run your MFA login command) and try again."
        return 1
    fi

    local cluster_arn
    cluster_arn=$(echo "$clusters_raw" | tr '\t' '\n' | fzf --prompt="Select cluster: " --height=40%)
    if [[ -z "$cluster_arn" ]]; then
        echo "No cluster selected."
        return 1
    fi
    echo "Selected cluster: ${cluster_arn##*/}"

    echo "Fetching services..."
    local service_arn
    service_arn=$(aws ecs list-services --cluster "$cluster_arn" --query 'serviceArns[]' --output text | tr '\t' '\n' | fzf --prompt="Select service: " --height=40%)
    if [[ -z "$service_arn" ]]; then
        echo "No service selected."
        return 1
    fi
    local service_name="${service_arn##*/}"
    echo "Selected service: $service_name"

    echo "Fetching tasks..."
    local task_arn
    task_arn=$(aws ecs list-tasks --cluster "$cluster_arn" --service-name "$service_name" --query 'taskArns[]' --output text | tr '\t' '\n' | fzf --prompt="Select task: " --height=40%)
    if [[ -z "$task_arn" ]]; then
        echo "No task selected."
        return 1
    fi
    echo "Selected task: ${task_arn##*/}"

    echo "Fetching containers..."
    local container_name
    container_name=$(aws ecs describe-tasks --cluster "$cluster_arn" --tasks "$task_arn" --query 'tasks[0].containers[].name' --output text | tr '\t' '\n' | fzf --prompt="Select container: " --height=40%)
    if [[ -z "$container_name" ]]; then
        echo "No container selected."
        return 1
    fi
    echo "Connecting to container '$container_name'..."

    aws ecs execute-command --cluster "$cluster_arn" --task "$task_arn" --container "$container_name" --interactive --command "/bin/bash"
}

rm_lines() {
  sed 's/^[[:space:]]*//' | grep -v '^$' | tr '\n' '\0' | xargs -0 rm
}

look_at_comments_in_current_pr() {
  local regex=""
  local reviewer=""
  local all_keys="false"

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
      --all|-a)
        all_keys="true"
        shift
        ;;
      --help)
        echo "Usage: look_comments_in_current_pr [--reviewer <username>] [--regex <pattern>] [--all|-a]"
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
    jq --arg regex "$regex" --arg reviewer "$reviewer" --arg all_keys "$all_keys" '
    [
      .[]
      | if ($regex == "") then . else select(.body | test($regex; "i")) end
      | if ($reviewer == "")
          then .
          else select(.user.login == $reviewer)
        end
      | if ($all_keys == "true")
          then .
          else {
            id,
            body,
            start_line,
            line,
            path,
            commit_id,
            user: .user.login
          }
        end
    ]'
}
