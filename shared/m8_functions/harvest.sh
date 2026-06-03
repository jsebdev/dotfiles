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
