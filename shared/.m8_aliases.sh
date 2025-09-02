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
    cdrc
    echo "Running linters and type checks for RallyClaim..."
    echo "----------------------------------------"
    echo "npm run lint (React)"
    docker compose run --rm react npm run lint
    echo "npm run typecheck (React)"
    docker compose run --rm react npm run typecheck
    echo "mypy (Django)"
    docker compose run --rm django mypy .
    echo "ruff (Django)"
    docker compose run --rm django ruff check . --fix
}

