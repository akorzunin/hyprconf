#!/usr/bin/env nu

# One UI writer (flock in todo.sh); use per-store locking if more writers are added.
def task-file [] {
    let base = ($env.XDG_DATA_HOME? | default ($env.HOME | path join '.local/share'))
    $base | path join 'waybar-todo/tasks.json'
}

def load-tasks [] {
    let file = (task-file)
    if not ($file | path exists) { return [] }
    let tasks = (open --raw $file | from json)
    if ($tasks | describe) !~ '^(list|table)' {
        error make {msg: 'Invalid TODO file: expected a list'}
    }
    for task in $tasks {
        if ($task.text? | describe) != 'string' or ($task.done? | describe) != 'bool' {
            error make {msg: 'Invalid TODO task: expected text and done fields'}
        }
    }
    $tasks
}

def store-tasks [tasks: list] {
    let file = (task-file)
    mkdir ($file | path dirname)
    let temp = $'($file).tmp'
    $tasks | to json | save --force $temp
    mv --force $temp $file
    # Status also polls, so a missing Waybar process is harmless.
    do { ^pkill -RTMIN+11 -x waybar } | complete | ignore
}

def choose [items: list, prompt: string] {
    try { $items | input list $prompt } catch { null }
}

def edit-text [text: string] {
    let temp = (^mktemp --suffix=.txt | str trim)
    try {
        $text | save --force $temp
        let editor = ($env.EDITOR? | default 'nvim')
        # Use sh to support EDITOR values containing arguments; pass the path separately.
        ^sh -c ('exec ' + $editor + ' "$1"') todo-editor $temp
        let code = $env.LAST_EXIT_CODE
        let edited = if $code == 0 { open --raw $temp } else { null }
        rm --force $temp
        $edited
    } catch {|err|
        rm --force $temp
        error make {msg: $err.msg}
    }
}

def ui [] {
    $env.WAYBAR_TODO_SCRIPT = ($env.FILE_PWD | path join 'todo.nu')
    mut tasks = (load-tasks)
    mut cursor = 0
    loop {
        clear
        let pending = ($tasks | where done == false | length)
        let rows = ($tasks | enumerate | each {|entry|
            let mark = if $entry.item.done { '' } else { '' }
            {label: $'($mark) ($entry.item.text | str replace --all "\n" " ↵ " | str replace --all "\r" " " | str replace --all "\t" " ")', action: 'task', index: $entry.index}
        })
        let menu = ($rows | append [
            {label: '+ Add task', action: 'add', index: -1}
            {label: 'Clear all', action: 'clear', index: -1}
            {label: 'Quit', action: 'quit', index: -1}
        ])
        let result = ($menu | enumerate | each {|entry|
            $'($entry.index)(char tab)($entry.item.label)'
        } | str join "\n" | ^fzf --no-sort --disabled --delimiter '\t' --with-nth '2..'
            --header $'TODO — ($pending) pending · j/k: down/up · Space: toggle · e: edit · y: copy · d: delete · a: add · f: search · p: preview · Enter: actions · q/Esc: quit'
            --prompt 'Tasks> '
            --preview 'nu --no-config-file "$WAYBAR_TODO_SCRIPT" preview {1}'
            --preview-window 'down,50%,wrap,hidden'
            --bind 'j:down,k:up,q:abort,p:toggle-preview,alt-up:preview-up,alt-down:preview-down'
            --bind 'space:print(space)+accept,e:print(e)+accept,y:print(y)+accept,d:print(d)+accept,a:print(a)+accept,enter:print(enter)+accept'
            --bind 'f:enable-search+unbind(space,e,y,d,a,f,p,j,k,q)+change-prompt(Search> )+change-header(Type to search · Enter: actions for matching task · Esc: quit)'
            --bind ('start:pos(' + (($cursor + 1) | into string) + ')') | complete)
        if $result.exit_code in [1 130] { break }
        if $result.exit_code != 0 {
            error make {msg: $'fzf failed: ($result.stderr | str trim)'}
        }
        let output = ($result.stdout | split row "\n")
        let key = ($output | first)
        $cursor = ($output | get 1 | split row (char tab) | first | into int)
        let selected = if $key == 'a' { {action: 'add', index: -1} } else { $menu | get $cursor }
        if $key not-in ['enter' 'a'] and $selected.action != 'task' { continue }
        match $selected.action {
            'quit' => { break }
            'add' => {
                let text = (edit-text '')
                if $text != null and ($text | str trim | is-not-empty) {
                    $tasks = ($tasks | append {text: ($text | str trim), done: false})
                    store-tasks $tasks
                }
            }
            'clear' => {
                if ($tasks | is-not-empty) and (choose ['Cancel' 'Clear all tasks'] 'Delete every task?') == 'Clear all tasks' {
                    $tasks = []
                    store-tasks $tasks
                }
            }
            'task' => {
                let index = $selected.index
                let task = ($tasks | get $index)
                let action = (match $key {
                    'space' => { 'Toggle done' }
                    'e' => { 'Edit' }
                    'y' => { 'Copy' }
                    'd' => { 'Delete' }
                    _ => { choose ['Toggle done' 'Edit' 'Copy' 'Delete' 'Back'] $task.text }
                })
                match $action {
                    'Toggle done' => {
                        $tasks = ($tasks | update $index {text: $task.text, done: (not $task.done)})
                        store-tasks $tasks
                    }
                    'Edit' => {
                        let text = (edit-text $task.text)
                        if $text != null and ($text | str trim | is-not-empty) {
                            $tasks = ($tasks | update $index {text: ($text | str trim), done: $task.done})
                            store-tasks $tasks
                        }
                    }
                    'Copy' => {
                        $task.text | ^wl-copy
                    }
                    'Delete' => {
                        $tasks = ($tasks | enumerate | where index != $index | get item)
                        store-tasks $tasks
                    }
                }
            }
        }
    }
}

def main [command: string = 'ui', index: int = -1] {
    match $command {
        'preview' => {
            let tasks = (load-tasks)
            if $index >= 0 and $index < ($tasks | length) {
                print --no-newline ($tasks | get $index | get text)
            }
        }
        'status' => {
            try {
                let tasks = (load-tasks)
                let pending = ($tasks | where done == false | length)
                if $pending == 0 {
                    return ({text: ' ', class: 'todo'} | to json --raw)
                }
                let rows = ($tasks | each {|task|
                    let mark = if $task.done { '' } else { '' }
                    let text = ($task.text | str replace --all '&' '&amp;' | str replace --all '<' '&lt;' | str replace --all '>' '&gt;')
                    $'($mark) ($text)'
                })
                let tooltip = ([$'TODO: ($pending) pending / ($tasks | length) total'] | append $rows | str join "\n")
                {text: $'  ($pending)', tooltip: $tooltip, class: 'todo'} | to json --raw
            } catch {
                {text: '  !', tooltip: 'Cannot read TODO file; open to inspect the error', class: 'error'} | to json --raw
            }
        }
        'ui' => {
            try { ui } catch {|err|
                print --stderr $err.msg
                input 'Press Enter to close…' | ignore
            }
        }
        _ => { error make {msg: 'Usage: todo.nu [status|ui|preview INDEX]'} }
    }
}
