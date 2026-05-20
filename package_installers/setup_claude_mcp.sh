#!/bin/bash

set -e

echo "Setting up Claude Code MCP servers..."

add_mcp_server() {
    local name="$1"
    local url="$2"

    if claude mcp list 2>/dev/null | grep -q "^$name:"; then
        echo "MCP server '$name' already configured. Skipping."
    else
        claude mcp add --transport http "$name" "$url"
        echo "Added MCP server '$name'."
    fi
}

add_mcp_server "jira-mach8" "https://mcp.atlassian.com/v1/mcpb"
add_mcp_server "jira-arena" "https://mcp.atlassian.com/v1/mcp"

echo "Claude Code MCP setup complete!"
