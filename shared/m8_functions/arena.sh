connect_to_local_arena_client_config_db() {
    PGPASSWORD=postgres psql -h 127.0.0.1 -p 5010 -U postgres -d client_config
}

connect_to_local_arena_sourcing_db() {
    PGPASSWORD='postgres' psql \
        --host=127.0.0.1 \
        --port=5440 \
        --username=postgres \
        --dbname=model_view
}

execute_command_in_arena_person_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_person_service <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep person | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/person-service && $command"
}

execute_command_in_arena_client_config() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_client_config <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep client-config | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/client-config && $command"
}

login_in_arena_questionnaire_v2_service() {
    docker exec -it -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash
    # docker exec -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/questionnaire-v2 && bash"
}

execute_command_in_arena_questionnaire_v2_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_questionnaire_v2_service <command>"
        return 1
    fi
    docker exec -u vscode  $(docker ps | grep questionnaire-v2 | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/questionnaire-v2 && $command"
}

execute_command_in_arena_platform_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_platform_service <command>"
        return 1
    fi
    # docker exec -u node  $(docker ps | grep platform | awk '{print $NF}') bash -c "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\" && cd /workspaces/platform && $command"
    docker exec -w /workspaces/platform -u node  $(docker ps | grep platform | awk '{print $NF}') bash -c "$command"
}

execute_command_in_arena_agents_service() {
    local command="$*"
    if [[ -z "$command" ]]; then
        echo "Usage: execute_command_in_arena_agents_service <command>"
        return 1
    fi
    docker exec -w /workspaces/agents -u vscode  $(docker ps | grep agents | awk '{print $NF}') bash -c "$command"
}

connect_to_local_arena_questionnaire_v2_db() {
    mongosh "mongodb://user:pass@localhost:27050/questionnaire?authSource=admin"
}

export_arena_client_config_db_url_and_connect_to_db() {
    local environment="catalyst-staging"
    local psql_command=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo "Usage: export_arena_client_config_db_url_and_connect_to_db [-h|--help] [--env <environment>] [-c|--command <psql_command>]"
                echo ""
                echo "Fetches client-config DB credentials from AWS SSM for the given environment,"
                echo "exports them as PG* / DATABASE_URL, and connects via psql."
                echo ""
                echo "Options:"
                echo "  -h, --help            Show this help message and return"
                echo "  --env <environment>   SSM parameter prefix environment (default: catalyst-staging)"
                echo "  -c, --command <sql>   Run a single psql command instead of an interactive session"
                return 0
                ;;
            --env)
                environment="$2"
                shift 2
                ;;
            -c|--command)
                psql_command="$2"
                shift 2
                ;;
            *)
                echo "Unknown argument: $1"
                return 1
                ;;
        esac
    done
    local ssm_prefix="/$environment/client-config-api"
    export PGUSER=$(aws ssm get-parameter --name "$ssm_prefix/PGUSER" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export PGPASSWORD=$(aws ssm get-parameter --name "$ssm_prefix/PGPASSWORD" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export PGHOST=$(aws ssm get-parameter --name "$ssm_prefix/PGHOST" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export PGPORT=$(aws ssm get-parameter --name "$ssm_prefix/PGPORT" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export PGDATABASE=$(aws ssm get-parameter --name "$ssm_prefix/PGDATABASE" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export DATABASE_URL="postgresql://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE?sslmode=require"
    if [[ -n "$psql_command" ]]; then
        psql "$DATABASE_URL" -c "$psql_command"
    else
        psql "$DATABASE_URL"
    fi
}

export_arena_sourcing_db_url_and_connect_to_db() {
    local environment="catalyst-staging"
    local psql_command=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo "Usage: export_arena_sourcing_db_url_and_connect_to_db [-h|--help] [--env <environment>] [-c|--command <psql_command>]"
                echo ""
                echo "Fetches sourcing DB credentials from AWS SSM for the given environment,"
                echo "exports them as SOURCING_DB_* / FLYWAY_* / SOURCING_DATABASE_URL, and connects via psql."
                echo ""
                echo "Options:"
                echo "  -h, --help            Show this help message and return"
                echo "  --env <environment>   SSM parameter prefix environment (default: catalyst-staging)"
                echo "  -c, --command <sql>   Run a single psql command instead of an interactive session"
                return 0
                ;;
            --env)
                environment="$2"
                shift 2
                ;;
            -c|--command)
                psql_command="$2"
                shift 2
                ;;
            *)
                echo "Unknown argument: $1"
                return 1
                ;;
        esac
    done
    local ssm_prefix="/$environment/shared"
    export SOURCING_DB_PORT=5432
    export FLYWAY_SCHEMA=sourcing
    export SOURCING_DB_USER=$(aws ssm get-parameter --name "$ssm_prefix/PGUSER" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export FLYWAY_DATABASE=$(aws ssm get-parameter --name "$ssm_prefix/PGDATABASE" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export SOURCING_DB_HOST=$(aws ssm get-parameter --name "$ssm_prefix/PGHOST" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export SOURCING_DB_PASSWORD=$(aws ssm get-parameter --name "$ssm_prefix/PGPASSWORD" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    export SOURCING_DATABASE_URL="postgresql://$SOURCING_DB_USER:$SOURCING_DB_PASSWORD@$SOURCING_DB_HOST:$SOURCING_DB_PORT/$FLYWAY_DATABASE"
    if [[ -n "$psql_command" ]]; then
        psql "$SOURCING_DATABASE_URL" -c "$psql_command"
    else
        psql "$SOURCING_DATABASE_URL"
    fi
}
