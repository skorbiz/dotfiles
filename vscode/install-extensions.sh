#!/bin/bash
# Install VS Code extensions from extensions.txt

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"

# Check if CLI is actually usable (not just present)
is_cli_usable() {
    local cli="$1"
    local output
    
    output=$("$cli" --list-extensions 2>&1 || true)
    if echo "$output" | grep -q "Command is only available in WSL or inside a Visual Studio Code terminal."; then
        return 1
    fi
    
    return 0
}

# Find usable VS Code CLI
find_code_cli() {
    # Try regular code command
    if command -v code >/dev/null 2>&1; then
        local cli=$(command -v code)
        if is_cli_usable "$cli"; then
            echo "$cli"
            return 0
        fi
    fi
    
    # Try code-server (devcontainer) - note the linux-x64 in path
    local code_server
    code_server=$(ls -1d /vscode/vscode-server/bin/linux-x64/*/bin/code-server 2>/dev/null | sort | tail -n 1)
    if [ -n "$code_server" ] && is_cli_usable "$code_server"; then
        echo "$code_server"
        return 0
    fi
    
    return 1
}

# Wait for CLI (useful during container startup)
wait_for_cli() {
    echo "Waiting for VS Code CLI to become available..."
    for i in {1..60}; do
        if CODE_CLI=$(find_code_cli); then
            echo "Found usable VS Code CLI: $CODE_CLI"
            echo "$CODE_CLI"
            return 0
        fi
        sleep 1
    done
    return 1
}

# Find CLI or wait for it
CODE_CLI="${1:-}"
if [ -z "$CODE_CLI" ]; then
    if ! CODE_CLI=$(find_code_cli); then
        if ! CODE_CLI=$(wait_for_cli); then
            echo "VS Code CLI not available, skipping extensions"
            exit 0
        fi
    fi
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Extensions file not found: $EXTENSIONS_FILE"
    exit 1
fi

echo "Installing VS Code extensions..."

# Install each extension
while IFS= read -r ext || [ -n "$ext" ]; do
    # Skip empty lines and comments
    [[ -z "$ext" || "$ext" =~ ^[[:space:]]*# ]] && continue
    
    ext=$(echo "$ext" | xargs)  # Trim whitespace
    echo "Installing: $ext"
    "$CODE_CLI" --install-extension "$ext" --force 2>&1 || echo "  Warning: Failed to install $ext"
done < "$EXTENSIONS_FILE"

echo "Extension installation complete!"
