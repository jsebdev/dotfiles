alias cdsw='cd /mnt/c/Users/sebas/coding/macheight/safefreight'
alias cdrc='cd ~/coding/macheight/onerallypoint/rallyclaim'

alias lrcst="aws ecs list-tasks --cluster rally-claim-cluster-staging"
alias lrcpt="aws ecs list-tasks --cluster rally-claim-cluster-prod"

rallyclaim_run_django_task_terminal() {
    local environment="${1:-staging}"
    if [[ "$environment" != "staging" && "$environment" != "prod" ]]; then
        echo "Invalid environment. Use 'staging' or 'prod'."
        return 1
    fi
    echo "Opening Django task in $environment environment..."
    local task_id=$(aws ecs list-tasks --cluster rally-claim-cluster-staging --query 'taskArns[0]' --output text)
    echo "Task ID: $task_id"
    aws ecs execute-command \
      --cluster rally-claim-cluster-$environment \
      --task $task_id \
      --container django-app \
      --interactive \
      --command "/bin/bash"
}

# check one rally point lint:
rallyclaim_lints() {
    cdrc
    docker compose run --rm react npm run lint
    docker compose run --rm react npm run typecheck
    docker compose run --rm django mypy .
    docker compose run --rm django ruff check .
}

