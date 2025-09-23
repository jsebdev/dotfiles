alias cdsw='cd /mnt/c/Users/sebas/coding/macheight/safefreight'
alias cdrc='cd ~/coding/macheight/onerallypoint/rallyclaim'

rallyclaim_run_django_task_terminal() {
    local environment="${1:-test}"
    if [[ "$environment" != "test" && "$environment" != "stage" ]]; then
        echo "Invalid environment. Use 'test' or 'stage'."
        return 1
    fi
    echo "Opening Django task in $environment environment..."
    local cluster_name="rally-claim-$environment-cluster"
    echo "Cluster Name: $cluster_name"

    local task_id=$(aws ecs list-tasks \
        --cluster "$cluster_name" \
        --query 'taskArns[0]' \
        --output text)
    echo "Task ID: $task_id"

    local container_name="rally-claim-$environment-app"
    echo "Container Name: $container_name"

    aws ecs execute-command \
      --cluster $cluster_name \
      --task $task_id \
      --container $container_name \
      --interactive \
      --command "/bin/bash"
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
        docker compose run --rm react npm run lint
        echo "npm run typecheck (React)"
        docker compose run --rm react npm run typecheck
    fi 
    if [[ "$service" == "all" || "$service" == "django" ]]; then
        echo "mypy (Django)"
        docker compose run --rm django mypy .
        echo "flake8 (Django)"
        docker compose run --rm django ruff check . --fix
    fi
}

