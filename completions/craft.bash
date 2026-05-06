_craft_sh() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local date_words="today tomorrow yesterday"
    local lang_words="bash python javascript typescript json yaml sql go rust c cpp java kotlin swift php ruby"

    case "$cur" in
        --date=*)
            COMPREPLY=($(compgen -W "--date=today --date=tomorrow --date=yesterday" -- "$cur"))
            return
            ;;
        --due=*)
            COMPREPLY=($(compgen -W "--due=today --due=tomorrow --due=yesterday" -- "$cur"))
            return
            ;;
        --language=*)
            local lang_opts
            lang_opts=$(printf -- "--language=%s " $lang_words)
            COMPREPLY=($(compgen -W "$lang_opts" -- "$cur"))
            return
            ;;
    esac

    COMPREPLY=($(compgen -W "
        -h --help
        --version
        -d --debug
        --dry-run
        --date=
        --due=
        --language=
        -c --code
        -t --task
        -l --list
    " -- "$cur"))
}

complete -F _craft_sh craft.sh
complete -F _craft_sh craft
