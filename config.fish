set normal (set_color normal)
set magenta (set_color magenta)
set yellow (set_color yellow)
set green (set_color green)
set red (set_color red)
set gray (set_color -o black)

### GIT STUFF
set -g fish_color_git_clean green
set -g fish_color_git_branch magenta
set -g fish_color_git_remote green

set -g fish_color_git_staged yellow
set -g fish_color_git_conflicted red
set -g fish_color_git_changed blue
set -g fish_color_git_untracked $fish_color_normal

set -g fish_prompt_git_remote_ahead_of "↑"
set -g fish_prompt_git_remote_behind  "↓"

set -g fish_prompt_git_status_staged "●"
set -g fish_prompt_git_status_conflicted '✖'
set -g fish_prompt_git_status_changed '✚'
set -g fish_prompt_git_status_untracked "…"
set -g fish_prompt_git_status_clean "✔"

set -g fish_prompt_git_show_count_staged "true"
set -g fish_prompt_git_show_count_conflicted "true"
set -g fish_prompt_git_show_count_changed "true"
set -g fish_prompt_git_show_count_untracked "false"
set -g fish_prompt_git_show_count_clean "true"

set -g fish_prompt_git_status_git_dir "*"
set -g fish_prompt_git_remote_space ""

set -g fish_prompt_git_status_order staged conflicted changed untracked

function __informative_git_prompt --description 'Write out the git prompt'

    set -l is_inside_work_tree (git rev-parse --is-inside-work-tree ^/dev/null )

    if test -z $is_inside_work_tree
        return
    end

    if test "true" = $is_inside_work_tree
        set git_status_info (___fish_git_print_status_info)
    else
        set git_status_info (set_color -o $fish_color_git_clean)$fish_prompt_git_status_git_dir(set_color $fish_color_normal)
    end

    printf " (%s|%s)" (___fish_git_print_branch_info) $git_status_info

end

function ___fish_git_print_branch_info

    set -l color_branch (set_color -o $fish_color_git_branch)
    set -l color_normal (set_color $fish_color_normal)

    set -l branch (git symbolic-ref -q HEAD | cut -c 12-)
    set -l remote_info

    if test -z $branch
        set -l hash (git rev-parse --short HEAD | cut -c 2-)
        set branch ":"$hash
    else
        set remote_info (___fish_git_print_remote_info $branch)
    end

    echo "$color_branch$branch$color_normal$remote_info"

end

function ___fish_git_print_status_info

    set -l color_normal (set_color $fish_color_normal)
    set -l color_git_clean (set_color -o $fish_color_git_clean)

    set -l changedFiles (git diff --name-status | cut -c 1-2)
    set -l stagedFiles (git diff --staged --name-status | cut -c 1-2)

    set -l changed (math (count $changedFiles) - (count (echo $changedFiles | grep "U")))
    set -l conflicted (count (echo $stagedFiles | grep "U"))
    set -l staged (math (count $stagedFiles) - $conflicted)
    set -l untracked (count (git ls-files --others --exclude-standard))

    if [ (math $changed + $conflicted + $staged + $untracked) = 0 ]
        set git_status $color_git_clean$fish_prompt_git_status_clean$color_normal
    else
        for i in $fish_prompt_git_status_order
            if [ $$i != "0" ]
                set -l color_name fish_color_git_$i
                set -l status_name fish_prompt_git_status_$i
                set -l color (set_color $$color_name)
                set -l visible fish_prompt_git_show_count_$i
                set -l info
                if [ "true" = $$visible ]
                    set info $$status_name$$i
                else
                    set info $$status_name
                end
                set git_status "$git_status$color$info"
            end
        end
    end

    echo $git_status$color_normal

end

function ___fish_git_print_remote_info

    set color_remote (set_color -o $fish_color_git_remote)
    set color_normal (set_color $fish_color_normal)

    set -l branch $argv[1]
    set -l remote (____fish_git_remote_info $branch)
    set -l ahead $remote[1]
    set -l behind $remote[2]
    set -l remote_info


    if [ $ahead != "0" ]
        set remote_info $color_remote$fish_prompt_git_remote_ahead_of$color_normal$ahead
    end

    if [ $behind != "0" ]
        set remote_info $remote_info$color_remote$fish_prompt_git_remote_behind$color_normal$behind
    end

    if test -n "$remote_info"
        echo "$fish_prompt_git_remote_space$remote_info"
    end

end

function ____fish_git_remote_info

    set -l branch $argv[1]
    set -l remote_name  (git config branch.$branch.remote)

    if test -n "$remote_name"
        set merge_name (git config branch.$branch.merge)
        set merge_name_short (echo $merge_name | cut -c 12-)
    else
        set remote_name "origin"
        set merge_name "refs/heads/$branch"
        set merge_name_short $branch
    end

    if [ $remote_name = '.' ]  # local
        set remote_ref $merge_name
    else
        set remote_ref "refs/remotes/$remote_name/$merge_name_short"
    end

    set -l rev_git (eval "git rev-list --left-right $remote_ref...HEAD" ^/dev/null)
    if test $status != "0"
        set rev_git (eval "git rev-list --left-right $merge_name...HEAD" ^/dev/null)
    end

    for i in $rev_git
        if echo $i | grep '>' >/dev/null
           set isAhead $isAhead ">"
        end
    end

    set -l remote_diff (count $rev_git)
    set -l ahead (count $isAhead)
    set -l behind (math $remote_diff - $ahead)

    echo $ahead
    echo $behind

end
### END GIT STUFF

### START !!, !$ bash support
function bind_bang
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function bind_dollar
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

function fish_user_key_bindings
  bind ! bind_bang
  bind '$' bind_dollar
end
## END !!, !$ bash support


function user_hostname_prompt --description "Displays the username and the hostname"
    echo -n "$USER@"
    echo -n (hostname)
    echo -n " "
end

function prompt_long_pwd --description 'Print the current working directory'
    echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/private||'
end

function fish_prompt
  # User + hostname
  set last_status $status
  set_color magenta
  printf '%s' (user_hostname_prompt)
  
  # CWD
  set_color $fish_color_cwd
  printf '%s' (prompt_long_pwd)
  
  # Git status
  __informative_git_prompt
  
  # End prompt
  set_color normal
  echo -n "> "
end

function emphasize_text
  set_color $argv[1]; printf $argv[2]; set_color normal  
end

function __health_check_results
  printf "\n%s\n" (emphasize_text magenta 'Status report!!')
  
  # Ping
  set NET_CMD "nc -zw1 google.com 80 2>/dev/null"
  if test -e "/etc/redhat-release"
    set NET_CMD "nc -w1 google.com 80 --send-only </dev/null 2>/dev/null"
  end
  eval $NET_CMD

  if [ $status = 0 ]
    printf ' %s Your internet connection looks %s, dood!\n' (emphasize_text green '✓') (emphasize_text green 'OK')
  else
    printf ' %s Your internet connection looks %s, dood.\n' (emphasize_text red '✗') (emphasize_text red 'degraded')
  end

  # Space
  set CAPACITY_PCT (df / | awk '{print $5}' | tail -n 1 | sed 's/%//')
  if [ $CAPACITY_PCT -lt 80 ]
    printf ' %s You have %s on / (%s full)!\n' (emphasize_text green '✓') (emphasize_text green 'plenty of space') (emphasize_text green "$CAPACITY_PCT%%")
  else
    printf " %s You're %s on / (%s% full)!\n" (emphasize_text red '✗') (emphasize_text red "runnin' out of space") (emphasize_text red "$CAPACITY_PCT%%") 
  end

  # Time
  set TIME_HOUR (date +%H)
  if [ $TIME_HOUR -gt 23 ]
    printf ' %s %s. You should go to bed.\n' (emphasize_text red '✗') (emphasize_text red "It's late")
  else if [ $TIME_HOUR -lt 5 ]
    printf ' %s %s. You should go to bed.\n' (emphasize_text red '✗') (emphasize_text red "It's late")
  else
    printf " %s It's %s!\n" (emphasize_text green '✓') (emphasize_text green "a good day for science")
  end
end

function __plugin_results
  for file in ~/.config/fish/plugins/*.py
    if [ $file != './plugins/plugin_helpers.py' ]
      eval (python $file)
    end
  end
end

function welcome_text
  if [ $FISHRC_NEXT_HEADER_UTIME ]
    if [ (python -c "import time; print(int(time.time()*1000))") -lt $FISHRC_NEXT_HEADER_UTIME ]
      # Don't print header again
      return
    end
  end

  cat ~/.config/fish/cat_header
  printf 'Yo! Welcome to %s on %s, %s!\n' (emphasize_text blue 'ＣＡＴＥＬＡＢ') (emphasize_text magenta (hostname)) (emphasize_text blue (whoami))
  printf 'It\'s currently %s.\n' (emphasize_text green (date))
  __health_check_results
  __plugin_results
  printf '\n'
  echo ''
  printf 'What will your %s be?\n' (emphasize_text magenta 'first sequence of the day')

  # Add 
  export FISHRC_NEXT_HEADER_UTIME=(math (python -c "import time; print(int(time.time()*1000))") + 100)
end

set fish_greeting ""  # No greet
welcome_text
