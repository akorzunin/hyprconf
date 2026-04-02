def main [] {
    niri msg --json windows
    | from json
    | select id app_id title
    | sort
    | format pattern $'{title}(0..100 | each { " " } | str join){id}(^echo -ne '\0icon\x1f'){app_id},tablet-symbolic'
    | to text
    | fuzzel -d
    | niri msg action focus-window --id ($in | split row " " | last)
}
