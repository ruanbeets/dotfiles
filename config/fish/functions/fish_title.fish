function fish_title
    # Keep Konsole's tab title useful without starting a subprocess.
    printf '%s' (prompt_pwd --dir-length=1)
    if set -q argv[1]
        printf ' — %s' $argv[1]
    end
end
