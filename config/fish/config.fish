# Batcomputer terminal: Fish + Tide, with local-only quality-of-life tools.
fish_add_path --global --move ~/.local/bin

if not status is-interactive
    return
end

set -g fish_greeting
set -g fish_color_normal E8E6EA
set -g fish_color_command B99FE6
set -g fish_color_param D8D2DC
set -g fish_color_quote 8FCF9A
set -g fish_color_redirection A68BD7
set -g fish_color_end F6E72B
set -g fish_color_error FF6670
set -g fish_color_comment 807682
set -g fish_color_operator 8A62C5
set -g fish_color_escape F6E72B
set -g fish_color_autosuggestion 716876
set -g fish_color_search_match --background=251938
set -g fish_color_selection --background=251938
set -g fish_pager_color_prefix F6E72B --bold
set -g fish_pager_color_completion E8E6EA
set -g fish_pager_color_description 9A8E9E
set -g fish_pager_color_selected_background --background=322543

abbr -a g git
abbr -a gs git status
abbr -a ga git add
abbr -a gc git commit
abbr -a gp git push
abbr -a gl git log --oneline --graph --decorate
abbr -a lg lazygit
abbr -a ff fastfetch
abbr -a bt btop
abbr -a gpu nvtop
abbr -a c clear
abbr -a ll 'eza --long --group-directories-first --icons=auto'
abbr -a la 'eza --all --long --group-directories-first --icons=auto'

set -gx COLORTERM truecolor
set -gx FZF_DEFAULT_OPTS '--height=45% --layout=reverse --border=rounded --info=inline --prompt=❯\  --pointer=▌ --marker=◆ --color=bg:#030405,bg+:#251938,fg:#c8c1cc,fg+:#f5f1f7,hl:#f6e72b,hl+:#f8ed43,border:#45335f,header:#a99bac,info:#807682,prompt:#8a62c5,pointer:#f6e72b,marker:#8a62c5,spinner:#f6e72b'
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
set -gx FZF_CTRL_T_OPTS '--preview "bat --color=always --style=numbers --line-range=:240 {} 2>/dev/null" --preview-window=right:60%:wrap'
set -gx FZF_ALT_C_OPTS '--preview "eza --tree --level=2 --icons=auto {} 2>/dev/null | head -200" --preview-window=right:60%'
if type -q fzf_key_bindings
    fzf_key_bindings
end
if type -q zoxide
    zoxide init fish | source
end

# Show one dashboard per terminal environment. Child Fish shells inherit the
# marker; new Konsole tabs/windows start from Konsole's own environment. tmux
# panes stay banner-free, so splits never repeat the dashboard.
if test -z "$TMUX"; and not set -q BATCOMPUTER_FASTFETCH_SHOWN; and type -q fastfetch
    fastfetch
    set -gx BATCOMPUTER_FASTFETCH_SHOWN 1
end

if test -r $__fish_config_dir/local.fish
    source $__fish_config_dir/local.fish
end
