export EDITOR=nvim
eval "$(zoxide init zsh)"

if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
  exec fish
fi
