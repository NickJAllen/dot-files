if status is-interactive
    # Commands to run in interactive sessions can go here

    zoxide init fish | source

    fzf --fish | source

    bind ctrl-f fzf-file-widget
    bind -M insert ctrl-f fzf-file-widget

    starship init fish | source

    fish_add_path $HOME/bin
    set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgrep
    set -gx EDITOR nvim

    switch (uname)
        case Linux
            source ~/.config/fish/linux-config.fish
        case Darwin
            source ~/.config/fish/macos-config.fish
    end
end
