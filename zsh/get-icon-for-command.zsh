
# Return an icon for a command (to show in a terminal title)
# List mostly from:
# https://github.com/joshmedeski/tmux-nerd-font-window-name/blob/main/bin/defaults.yml#L6
get_icon_for_command() {
    # echo "icon for $1"
    case "$1" in
        nvim|v|n)
            echo ' '
            ;;
        vim|vi|lvim)
            echo ' '
            ;;
        python|python3|python2)
            echo ' '
            ;;
        apt)
            echo " "
            ;;
        caffeinate)
            echo " "
            ;;
        cargo)
            echo " "
            ;;
        beam.smp)
            echo " "
            ;;
        beam)
            echo " "
            ;;
        brew)
            echo " "
            ;;
        cfdisk)
            echo " "
            ;;
        dnf)
            echo " "
            ;;
        docker)
            echo " "
            ;;
        dpkg)
            echo " "
            ;;
        emacs)
            echo " "
            ;;
        fdisk)
            echo " "
            ;;
        git)
            echo "󰊢 "
            ;;
        gitui)
            echo "󰊢 "
            ;;
        go)
            echo " "
            ;;
        htop)
            echo " "
            ;;
        java)
            echo " "
            ;;
        kubectl)
            echo "󱃾 "
            ;;
        lazydocker)
            echo " "
            ;;
        lazygit)
            echo "󰊢 "
            ;;
        lf)
            echo " "
            ;;
        lfcd)
            echo " "
            ;;
        nala)
            echo " "
            ;;
        node)
            echo " "
            ;;
        pacman)
            echo " "
            ;;
        parted)
            echo " "
            ;;
        paru)
            echo " "
            ;;
        ranger)
            echo " "
            ;;
        ruby)
            echo " "
            ;;
        rustc)
            echo " "
            ;;
        rustup)
            echo " "
            ;;
        tig)
            echo " "
            ;;
        tmux)
            echo " "
            ;;
        top)
            echo " "
            ;;
        topgrade)
            echo "󰚰 "
            ;;
        yay)
            echo " "
            ;;
        yum)
            echo " "
            ;;
        zsh|bash|sh|tcsh|fish)
            echo '  '
            ;;
        *)
            echo ''
            ;;
    esac
}

