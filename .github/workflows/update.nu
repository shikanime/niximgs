#!/usr/bin/env nix
#! nix develop --impure --command nu

def parse_action_line [line: string]: string -> record {
    let action_match = ($line | parse --regex 'uses:\s+([^@]+)@([^\s]+)')

    if ($action_match | length) > 0 {
        {
            action: ($action_match | get capture0 | get 0)
            current_version: ($action_match | get capture1 | get 0)
        }
    } else {
        null
    }
}

def get_latest_action_version [action: string] {
    try {
        gh api $"repos/($action)/tags"
        | from json
        | get name
        | where ($it =~ '^v[0-9]+$')
        | first
    } catch {
        null
    }
}

def update_action [workflow: string, action: string, old_version: string, new_version: string] {
    print $"Updating ($action) from ($old_version) to ($new_version) in ($workflow)"

    open --raw $workflow
    | str replace --all $"uses: ($action)@($old_version)" $"uses: ($action)@($new_version)"
    | save --force $workflow
}

def update_actions [workflow: string] {
    print $"Checking ($workflow) for updates..."

    open --raw $workflow
    | lines
    | where ($it | str contains "uses: ")
    | where ($it | str contains "@")
    | each { |line|
        let parsed = (parse_action_line $line)
        if $parsed != null {
            let latest_version = (get_latest_action_version $parsed.action)
            if ($latest_version != null and $latest_version != $parsed.current_version) {
                update_action $workflow $parsed.action $parsed.current_version $latest_version
            }
        }
    }
    | compact  # Remove null values from actions that weren't updated
}

print "[workflows] Updating GitHub Actions workflows..."
glob $"($env.FILE_PWD)/*.{yml,yaml}"
    | each { |workflow|
        update_actions $workflow
    }
    | ignore
