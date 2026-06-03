# OneRallyClaim
rallyclaim_login_using_keepass_mfa() {
    local otp="$1"
    if [[ -z "$otp" ]]; then
        echo "Usage: rallyclaim_login_using_keepass_mfa <one-time-password>"
        return 1
    fi
    local credentials
    credentials=$(aws sts get-session-token \
        --profile onerally \
        --serial-number arn:aws:iam::102282313732:mfa/keepass \
        --token-code "$otp")
    if [[ $? -ne 0 ]]; then
        echo "Failed to get session token."
        return 1
    fi
    export AWS_ACCESS_KEY_ID=$(echo "$credentials" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "$credentials" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "$credentials" | jq -r '.Credentials.SessionToken')
    echo "AWS credentials exported successfully."
}

rallyclaim_run_django_task_terminal() {
    local environment="test"
    local custom_command=""
    local output_file=""
    while getopts "e:c:o:" opt; do
        case $opt in
            e)
                environment="$OPTARG"
                ;;
            c)
                custom_command="$OPTARG"
                ;;
            o)
                output_file="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
        esac
    done
    OPTIND=1
    if [[ "$environment" != "test" && "$environment" != "stage" && "$environment" != "prod" ]]; then
        echo "Error: Invalid environment '$environment'. Usage: rallyclaim_run_django_task_terminal -e <test|stage|prod>"
        return 1
    fi
    echo "Opening Django task in $environment environment..."
    local cluster_name="rally-claim-$environment-cluster"
    echo "Cluster Name: $cluster_name"

    local service_name="rally-claim-$environment-service"
    echo "Service Name: $service_name"

    local task_id=$(aws ecs list-tasks \
        --cluster "$cluster_name" \
        --service-name "$service_name" \
        --query 'taskArns[0]' \
        --output text)
    echo "Task ID: $task_id"

    local container_name="rally-claim-$environment-app"
    echo "Container Name: $container_name"

    local command_to_run="/bin/bash"
    if [[ -n "$custom_command" ]]; then
        echo "Running custom command: $custom_command"
        command_to_run="$custom_command"
    fi

    if [[ -n "$output_file" ]]; then
        echo "Saving output to: $output_file"
        aws ecs execute-command \
          --cluster $cluster_name \
          --task $task_id \
          --container $container_name \
          --interactive \
          --command "$command_to_run" > "$output_file" 2>&1
    else
        aws ecs execute-command \
          --cluster $cluster_name \
          --task $task_id \
          --container $container_name \
          --interactive \
          --command "$command_to_run"
    fi
}

# check one rally point lint:
rallyclaim_lints() {
    local service="${1:-all}"
    if [[ "$service" != "all" && "$service" != "react" && "$service" != "django" ]]; then
        echo "Invalid service. Use 'all', 'react', or 'django'."
        return 1
    fi
    cdrc
    echo "Running linters and type checks for RallyClaim. service=$service"
    echo "----------------------------------------"

    if [[ "$service" == "all" || "$service" == "react" ]]; then
        echo "npm run lint (React)"
        docker compose run --rm --no-deps react npm run lint:quiet:fix
        echo "npm run typecheck (React)"
        docker compose run --rm --no-deps react npm run typecheck
    fi 
    if [[ "$service" == "all" || "$service" == "django" ]]; then
        echo "mypy (Django)"
        docker compose run --rm django mypy .
        echo "flake8 (Django)"
        docker compose run --rm django ruff check . --fix
    fi
}

# deploy local frontend to prod:
rallyclaim_deploy_local_frontend_to_test() {
    docker compose run --rm react npm run build
    aws s3 sync react/build/client/ s3://rally-claim-test-frontend-XXXXXXXXXXXXXXXXXXX
}

# rallyclaim_deploy_local_frontend_to_prod() {
#     docker compose run --rm react npm run build
#     aws s3 sync react/build/client/ s3://rally-claim-prod-frontend-6wsxt216
# }
#

# Harvest
harvest_start_timer() {
    if [[ -z "$M8_HARVEST_ACCOUNT_ID" || -z "$M8_HARVEST_PERSONAL_ACCESS_TOKEN" ]]; then
        echo "Error: M8_HARVEST_ACCOUNT_ID and M8_HARVEST_PERSONAL_ACCESS_TOKEN must be set."
        return 1
    fi

    local base_url="https://api.harvestapp.com/api/v2"
    local account_header="Harvest-Account-ID: $M8_HARVEST_ACCOUNT_ID"
    local auth_header="Authorization: Bearer $M8_HARVEST_PERSONAL_ACCESS_TOKEN"
    local agent_header="User-Agent: m8-dotfiles"

    echo "Fetching current timer..."
    local running_response
    running_response=$(curl -s \
        -H "$account_header" \
        -H "$auth_header" \
        -H "$agent_header" \
        "$base_url/time_entries?is_running=true")

    local running_entry_id running_project_id running_task_id
    running_entry_id=$(echo "$running_response" | jq -r '.time_entries[0].id // empty')
    running_project_id=$(echo "$running_response" | jq -r '.time_entries[0].project.id // empty')
    running_task_id=$(echo "$running_response" | jq -r '.time_entries[0].task.id // empty')

    local today
    today=$(date +%Y-%m-%d)

    echo "Fetching project assignments and today's entries..."
    local assignments_response today_response
    assignments_response=$(curl -s \
        -H "$account_header" \
        -H "$auth_header" \
        -H "$agent_header" \
        "$base_url/users/me/project_assignments?per_page=100")
    today_response=$(curl -s \
        -H "$account_header" \
        -H "$auth_header" \
        -H "$agent_header" \
        "$base_url/time_entries?from=$today&to=$today&per_page=100")

    local today_entries
    today_entries=$(echo "$today_response" | jq '.time_entries')

    local fzf_input
    fzf_input=$(echo "$assignments_response" | jq -r \
        --argjson running_pid "${running_project_id:-0}" \
        --argjson running_tid "${running_task_id:-0}" \
        --argjson today_entries "$today_entries" '
        [.project_assignments[] |
        . as $pa |
        .task_assignments[] |
        . as $ta |
        ($today_entries | map(select(.project.id == $pa.project.id and .task.id == $ta.task.id)) | first // null) as $today_entry |
        {
            sort_key: (if $today_entry then 0 else 1 end),
            line: (
                (if ($pa.project.id == $running_pid and $ta.task.id == $running_tid) then "▶ " else "  " end) +
                $pa.project.name + " — " + $ta.task.name +
                (if $today_entry then " (" + ($today_entry.hours | tostring) + "h today)" else "" end) +
                "\t" + ($pa.project.id | tostring) +
                "\t" + ($ta.task.id | tostring) +
                "\t" + ($today_entry.id // "" | tostring)
            )
        }] | sort_by(.sort_key) | .[].line
    ')

    if [[ -z "$fzf_input" ]]; then
        echo "No project assignments found."
        return 1
    fi

    local fzf_header="Select a project and task to start timing"
    if [[ -n "$running_entry_id" ]]; then
        fzf_header="▶ = currently running  |  $fzf_header"
        fzf_input="⏹  Stop current timer	stop	stop	"$'\n'"$fzf_input"
    fi

    local selected
    selected=$(echo "$fzf_input" | fzf \
        --prompt="Harvest: " \
        --height=50% \
        --delimiter=$'\t' \
        --with-nth=1 \
        --header="$fzf_header")

    if [[ -z "$selected" ]]; then
        echo "No selection made."
        return 0
    fi

    local selected_display selected_project_id selected_task_id selected_entry_id
    selected_display=$(echo "$selected" | cut -f1)
    selected_project_id=$(echo "$selected" | cut -f2)
    selected_task_id=$(echo "$selected" | cut -f3)
    selected_entry_id=$(echo "$selected" | cut -f4)

    if [[ "$selected_project_id" == "stop" ]]; then
        echo "Stopping current timer..."
        curl -s -X PATCH \
            -H "$account_header" \
            -H "$auth_header" \
            -H "$agent_header" \
            "$base_url/time_entries/$running_entry_id/stop" > /dev/null
        echo "Timer stopped."
        return 0
    fi

    if [[ "$selected_project_id" == "$running_project_id" && "$selected_task_id" == "$running_task_id" ]]; then
        echo "Timer already running: ${selected_display:2}"
        return 0
    fi

    if [[ -n "$running_entry_id" ]]; then
        echo "Stopping current timer..."
        curl -s -X PATCH \
            -H "$account_header" \
            -H "$auth_header" \
            -H "$agent_header" \
            "$base_url/time_entries/$running_entry_id/stop" > /dev/null
    fi

    local start_response
    if [[ -n "$selected_entry_id" ]]; then
        start_response=$(curl -s -X PATCH \
            -H "$account_header" \
            -H "$auth_header" \
            -H "$agent_header" \
            "$base_url/time_entries/$selected_entry_id/restart")
    else
        start_response=$(curl -s -X POST \
            -H "$account_header" \
            -H "$auth_header" \
            -H "$agent_header" \
            -H "Content-Type: application/json" \
            -d "{\"project_id\": $selected_project_id, \"task_id\": $selected_task_id, \"spent_date\": \"$today\"}" \
            "$base_url/time_entries")
    fi

    if echo "$start_response" | jq -e '.id' > /dev/null 2>&1; then
        echo "Timer started: ${selected_display:2}"
    else
        echo "Error starting timer: $(echo "$start_response" | jq -r '.message // "Unknown error"')"
        return 1
    fi
}

def connect_to_local_rallyclaim_db() {
    psql postgres://postgres:\$local-password@127.0.0.1:5432/rallyclaim
}

# Arena.io

def connect_to_local_arena_client_config_db() {
    PGPASSWORD=postgres psql -h 127.0.0.1 -p 5010 -U postgres -d client_config
}

def connect_to_local_arena_sourcing_db() {
    PGPASSWORD='postgres' psql \
        --host=127.0.0.1 \
        --port=5440 \
        --username=postgres \
        --dbname=model_view \
}

def execute_command_in_arena_person_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_person_service <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep person | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/person-service && $command"
}

def execute_command_in_arena_client_config() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_client_config <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep client-config | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/client-config && $command"
}

def login_in_arena_questionnaire_v2_service() {
    docker exec -it -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash
    # docker exec -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/questionnaire-v2 && bash"
}

def execute_command_in_arena_questionnaire_v2_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_questionnaire_v2_service <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/questionnaire-v2 && $command"
}

def execute_command_in_arena_platform_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_platform_service <command>"
        return 1
    fi
    # docker exec -u node  $(docker ps | grep platform | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/platform && $command"
    docker exec -w /workspaces/platform -u node  $(docker ps | grep platform | awk '{print $NF}') bash -c "$command"
}

def execute_command_in_arena_agents_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_agents_service <command>"
        return 1
    fi
    docker exec -w /workspaces/agents -u vscode  $(docker ps | grep agents | awk '{print $NF}') bash -c "$command"
}

def connect_to_local_arena_questionnaire_v2_db() {
    mongosh "mongodb://user:pass@localhost:27050/questionnaire?authSource=admin"
}

def export_arena_client_config_db_url_and_connect_to_db() {
    if [[ -z "$PGPASSWORD" ]]; then
        echo "Error: PGPASSWORD environment variable is not set."
        echo "Please make sure to source the appropriate file that sets the database credentials before running this command."
        echo "E.G. source ./.config/catalyst-staging.sh"
        return 1
    fi
    export DATABASE_URL="postgresql://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE?sslmode=verify-ca&sslrootcert=$PGSSLROOTCERT"
    psql "$DATABASE_URL"
}
