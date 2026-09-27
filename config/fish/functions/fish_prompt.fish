function fish_prompt --description 'Batcomputer: directory, Git, and command failures'
    set -l previous $status $pipestatus
    set -l last_status $previous[1]
    set -l last_pipe $previous[2..]
    set -l cyan (set_color 36cfe0)
    set -l grey (set_color 829199)
    set -l normal (set_color normal)

    if set -q SSH_CONNECTION; or set -q SSH_TTY
        printf '%s%s@%s  ' $grey $USER (prompt_hostname)
    end
    printf '%s%s' $cyan (prompt_pwd --dir-length=0)
    printf '%s' (fish_git_prompt '   %s')

    if test $last_status -ne 0
        printf '  %s[%s]' (set_color e27881) $last_status
    else
        for code in $last_pipe
            if test "$code" -ne 0
                printf '  %s[pipe %s]' (set_color e27881) (string join '|' $last_pipe)
                break
            end
        end
    end
    printf '\n%s❯ %s' $cyan $normal
end
