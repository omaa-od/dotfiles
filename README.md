# Dotfiles

Configurations personnelles pour mes machines Linux et Windows.

## Structure

- `bash/` : configuration Bash
- `git/` : configuration Git
- `tmux/` : configuration tmux
- `niri/` : configuration Niri
- `windows/` : scripts Windows
- `install.sh` : installation Linux avec GNU Stow
- `install.ps1` : installation Windows

## Linux

Sur une nouvelle machine, installer Git et GitHub CLI puis s'authentifier :

```bash
gh auth login
gh auth setup-git
