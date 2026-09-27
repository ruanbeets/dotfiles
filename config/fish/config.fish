# Batcomputer: explicit native configuration, no shell framework.
# Global scope keeps PATH changes out of the universal-variable state file.
fish_add_path --global --move ~/.local/bin

if not status is-interactive
    return
end

set -g fish_greeting
set -g fish_color_normal c7ced1
set -g fish_color_command 36cfe0
set -g fish_color_param c7ced1
set -g fish_color_quote 81bfae
set -g fish_color_redirection 72b8cb
set -g fish_color_end 36cfe0
set -g fish_color_error e27881
set -g fish_color_comment 829199
set -g fish_color_operator 36cfe0
set -g fish_color_escape cba66b
set -g fish_color_autosuggestion 68777e
set -g fish_color_search_match --background=203b43
set -g fish_color_selection --background=203b43
set -g fish_pager_color_prefix 36cfe0 --bold
set -g fish_pager_color_completion c7ced1
set -g fish_pager_color_description 829199
set -g fish_pager_color_selected_background --background=203b43

# Built-in git prompt: tracked edits only, no untracked scan or network work.
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showuntrackedfiles 0
set -g __fish_git_prompt_showstashstate 0
set -g __fish_git_prompt_showupstream none
set -g __fish_git_prompt_char_dirtystate '*'
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_color 829199

abbr -a g git
abbr -a gs git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gp git push
abbr -a gl git log --oneline --graph --decorate
abbr -a c clear
abbr -a ll eza --long --group-directories-first --icons=auto
abbr -a la eza --all --long --group-directories-first --icons=auto
abbr -a lg lazygit

set -gx FZF_DEFAULT_OPTS '--height=45% --layout=reverse --border=sharp --info=inline --prompt=❯\  --pointer=▌ --marker=+ --color=bg:#080b0d,bg+:#17262d,fg:#c7ced1,fg+:#e3e9ec,hl:#36cfe0,hl+:#36cfe0,border:#30444e,header:#829199,info:#829199,prompt:#36cfe0,pointer:#36cfe0,marker:#2aa198,spinner:#36cfe0'
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
if type -q fzf
    fzf_key_bindings
end
if type -q zoxide
    zoxide init fish | source
end

# Machine-local additions are intentionally outside Git.
if test -r ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
