#!/usr/bin/env nix
#! nix develop --impure --command nu

def get_latest_action [action: string] {
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

def parse_action [uses: string]: nothing -> string {
    $uses | split row "@" | first
}

def update_workflow_job_step_actions [step: record] {
    if "uses" in $step {
        let action = (parse_action $step.uses)
        let version = (get_latest_action $action)
        if $version != null {
            $step | upsert uses $"($action)@($version)"
        } else {
            $step
        }
    } else {
        $step
    }
}

def update_workflow_job_actions [job: record] {
    $job | update steps {
        each { |step|
            (update_workflow_job_step_actions $step)
        }
    }
}


def update_workflow_actions [workflow: record] {
    $workflow
    | update jobs {
        items { |$name, job|
            { $name: (update_workflow_job_actions $job) }
        }
        | into record
    }
}

def parse_image [image: string]: nothing -> string {
    $image | split row "/" | last | split row ":" | get 0
}

def get_skaffold_images []: nothing -> list<string> {
    open $"($env.FILE_PWD)/../../skaffold.yaml"
    | get build.artifacts
    | each { |artifact| $artifact.image }
    | each { |image| (parse_image $image) }
}

def update_workflow_packages [workflow: record] {
    print $"Processing packages configuration in ($workflow)..."
    let images = (get_skaffold_images)
    print $"Images: ($images | str join ', ')"
    $workflow | upsert jobs.packages.strategy.matrix.image $images
}

def update_workflow [name: string, workflow: record] {
    if $name == "packages.yaml" {
        update_workflow_actions (update_workflow_packages $workflow)
    } else {
        update_workflow_actions $workflow
    }
}

print "Updating GitHub Actions workflows..."
glob $"($env.FILE_PWD)/*.{yml,yaml}"
    | each { |workflow|
        update_workflow ($workflow | path basename) (open $workflow)
        | save --force $workflow
    }
    | ignore
