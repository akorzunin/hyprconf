def main [
    name: string,      # App name to focus
    command?: string   # Optional launch command
] {
    let windows = (niri msg --json windows | from json)
    let matches = ($windows | where {|w|
    (
      ($w.app_id? | default "" | str contains --ignore-case $name) or
      ($w.title? | default "" | str contains --ignore-case $name)
    )
    })
    match ($matches | length) {
        0 => { if ($command | is-empty) { error make {msg: $"No '($name)' window"} } else { ^$command } }
        1 => { niri msg action focus-window --id ($matches.0.id) }
        _ => {
            let focused = (niri msg --json focused-window | from json)
            let next = ($matches | where id != $focused.id | first)
            niri msg action focus-window --id (if ($next | is-empty) { $matches.0.id } else { $next.id })
        }
    }
}
