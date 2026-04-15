# VS Code Extensions

Automatically installs VS Code extensions in devcontainers and remote environments.

## Usage

Edit `extensions.txt` to add extension IDs (one per line). Extensions install automatically when running `install.sh` in VS Code contexts.

To find an extension ID, look in the VS Code marketplace URL: `publisher.extension-name`

## Manual Install

```bash
bash ~/dotfiles/vscode/install-extensions.sh
```

Gracefully skips if VS Code CLI is not available.
