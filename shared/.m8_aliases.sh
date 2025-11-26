alias cdsw='cd /mnt/c/Users/sebas/coding/macheight/safefreight'
alias cdrc='cd ~/coding/macheight/onerallypoint/rallyclaim'

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
# rallyclaim_deploy_local_frontend_to_prod() {
#     docker compose run --rm react npm run build
#     aws s3 sync react/build/client/ s3://rally-claim-prod-frontend-6wsxt216
# }
