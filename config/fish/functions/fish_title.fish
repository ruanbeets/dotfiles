function fish_title
    # Override the vendor Pure title; no subprocess is needed.
    printf '%s' (prompt_pwd --dir-length=1)
    if set -q argv[1]
        printf ' — %s' $argv[1]
    end
end
