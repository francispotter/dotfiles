# DotFiles - Francis Potter

 Personal configurations for iTerm, ZSH, Git CLI, Python console, and Dyngle

## General contents

- Personal configurations for ZSH, Emacs, TMux, iTerm, Python console, and Dyngle
- Git-related aliases
- Developer workflow functions using the `glab` CLI
- Git, Python venv, and subshell information in the prompt where appropriate
- Key bindings, completions, and options that make sense to us
- Various other bits and pieces we find useful
- An `.editrc` file (symlink to your home) for MacOS Python console use
- A JSON file of iTerm key bindings (use the import button)
- A [Dyngle](https://pypi.org/project/dyngle/) config file (install Dyngle separately)

## ZSH

The package includes a self-edit-reload command `z` for zshrc. The command will

1. Pull this repo
2. Open the `.zshrc` file in an editor
3. Commit any changes back to the repo
4. Push the repo - but only if you have permission to push

So to take full advantage of the `z` command, most users would need to fork the original repo.


## Installation

```
curl https://gitlab.com/francispotter/dotfiles/-/raw/main/install.sh | sh
```

