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

def export_arena_sourcing_db_url_and_connect_to_db() {
    [[ -z "$SOURCING_DB_PORT" ]] && export SOURCING_DB_PORT=5432
    [[ -z "$FLYWAY_SCHEMA" ]] && export FLYWAY_SCHEMA=sourcing
    if [[ -z "$SOURCING_DB_USER" ]]; then
        export SOURCING_DB_USER=$(aws ssm get-parameter --name "/catalyst-staging/shared/PGUSER" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    fi
    if [[ -z "$FLYWAY_DATABASE" ]]; then
        export FLYWAY_DATABASE=$(aws ssm get-parameter --name "/catalyst-staging/shared/PGDATABASE" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    fi
    if [[ -z "$SOURCING_DB_HOST" ]]; then
        export SOURCING_DB_HOST=$(aws ssm get-parameter --name "/catalyst-staging/shared/PGHOST" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    fi
    if [[ -z "$SOURCING_DB_PASSWORD" ]]; then
        export SOURCING_DB_PASSWORD=$(aws ssm get-parameter --name "/catalyst-staging/shared/PGPASSWORD" --region us-east-1 --with-decryption --query "Parameter.Value" --output text)
    fi
    export SOURCING_DATABASE_URL="postgresql://$SOURCING_DB_USER:$SOURCING_DB_PASSWORD@$SOURCING_DB_HOST:$SOURCING_DB_PORT/$FLYWAY_DATABASE"
    psql "$SOURCING_DATABASE_URL"
}
