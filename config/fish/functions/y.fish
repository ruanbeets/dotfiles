function y --description 'Open Yazi and return to the last directory on exit'
    set -l cwd_file (command mktemp -t yazi-cwd.XXXXXX)
    command yazi $argv --cwd-file="$cwd_file"
    set -l yazi_status $status
    if test -r "$cwd_file"
        set -l cwd (string collect < "$cwd_file")
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            cd -- "$cwd"
        end
    end
    command rm -f -- "$cwd_file"
    return $yazi_status
end
