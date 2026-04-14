# Dotfiles
Small personal dotfiles setup.
Include setup for shell, git, qtile and vs-code.

## Setup
The setup is for use both in ubuntu with full window manager replacement and more locally in wsl, vs-code decontainer or other terminal based setups.

### Ubuntu (full window manager)
Todo

```
ln -s <path>/dotfiles/.zshrc .zshrc
ln -s  <path>/.bash_aliases .bash_aliases
```

###
When using the VS Code Dev Containers extension, set this repo as your dotfiles repository. VS Code will clone/update it automatically, and your setup will re-run when you reload/rebuild the container.


In VS Code settings, set:

```json
{
   "dotfiles.repository": "skorbiz/dotfiles",
   "dotfiles.targetPath": "~/dotfiles",
}
```

![vs-code settings](docs/vscode.png)

The vs-code integration is inspired by: [kaspertofte/dotfiles](https://github.com/kaspertofte/dotfiles/tree/main)



## Tools

### Zsh

### Bash

### Qtile

### Picom
