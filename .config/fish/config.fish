if status is-interactive
    # Commands to run in interactive sessions can go here
    eval (zellij setup --generate-auto-start fish | string collect)
end

zoxide init fish | source

fzf --fish | source

starship init fish | source
