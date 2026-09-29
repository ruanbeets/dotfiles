# Applied by install.sh to Fish universal variables so Tide's complete visual
# configuration survives new shells and can be rebuilt from this repository.
set -U tide_left_prompt_items pwd git newline character
set -U tide_right_prompt_items status cmd_duration context jobs python
set -U tide_prompt_add_newline_before true
set -U tide_prompt_transient_enabled false
set -U tide_prompt_min_cols 40
set -U tide_left_prompt_frame_enabled true
set -U tide_right_prompt_frame_enabled false
set -U tide_left_prompt_prefix ''
set -U tide_left_prompt_suffix ''
set -U tide_right_prompt_prefix ''
set -U tide_right_prompt_suffix ''
set -U tide_prompt_color_frame_and_connection 6D115F
set -U tide_prompt_icon_connection ' '
set -U tide_prompt_color_separator_same_color 6D115F
set -U tide_pwd_bg_color 28083E
set -U tide_pwd_color_dirs C8C1CC
set -U tide_pwd_color_anchors F8ED43
set -U tide_pwd_icon ''
set -U tide_git_bg_color 3B104F
set -U tide_git_bg_color_unstable 4A163D
set -U tide_git_bg_color_urgent 541622
set -U tide_git_color_branch E8E6EA
set -U tide_git_color_dirty F6E72B
set -U tide_git_color_staged 8FCF9A
set -U tide_git_color_untracked D72AC0
set -U tide_git_icon ''
set -U tide_status_bg_color 28083E
set -U tide_status_bg_color_failure 541622
set -U tide_status_color F8ED43
set -U tide_status_color_failure FF6670
set -U tide_status_icon '✓'
set -U tide_status_icon_failure '✘'
set -U tide_cmd_duration_threshold 5000
set -U tide_cmd_duration_bg_color 28083E
set -U tide_cmd_duration_color F6E72B
set -U tide_cmd_duration_icon '󱎫'
set -U tide_context_color_ssh F8ED43
set -U tide_context_bg_color 28083E
set -U tide_jobs_bg_color 3B104F
set -U tide_jobs_color D72AC0
set -U tide_jobs_icon ''
set -U tide_python_bg_color 28083E
set -U tide_python_color F8ED43
set -U tide_python_icon ''
set -U tide_character_color D72AC0
set -U tide_character_color_failure FF6670
set -U tide_character_icon '❯'
