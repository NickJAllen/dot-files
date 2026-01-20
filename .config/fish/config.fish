if status is-interactive
    # Commands to run in interactive sessions can go here

    zoxide init fish | source

    fzf --fish | source

    bind ctrl-f fzf-file-widget
    bind -M insert ctrl-f fzf-file-widget

    starship init fish | source

    switch (uname)
        case Linux
            source ~/.config/fish/linux-config.fish
    end
end
