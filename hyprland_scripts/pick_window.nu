def main [] {
    hyprctl clients -j
    | from json
    | select address class title workspace.id
    | each {|e| insert id { $e.'workspace.id' | math abs }}
    | sort-by id
    | format pattern $'{title}(0..1 | each { " " } | str join){address}(^echo -ne '\0icon\x1f'){class},tablet-symbolic'
    | to text
    | fuzzel -d
    | hyprctl dispatch focuswindow $"address:($in | split row ' ' | last)";
    hyprctl dispatch bringactivetotop;
}
