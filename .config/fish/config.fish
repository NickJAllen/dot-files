if status is-interactive
    # Commands to run in interactive sessions can go here

    zoxide init fish | source

    fzf --fish | source

    starship init fish | source

    switch (uname)
        case Linux
            source ~/.config/fish/linux-config.fish
    end
end
