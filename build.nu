#!/usr/bin/env nix
#! nix shell nixpkgs#buildah nixpkgs#nushell nixpkgs#skopeo --command nu

def detect_host_arch []: nothing -> string {
    let arch: string = uname | get machine
    match $arch {
        "x86_64" | "amd64" => "amd64"
        "aarch64" | "arm64" | "arm64e" => "arm64"
        "armv7l" => "arm32"
        _ => "amd64"  # Default fallback
    }
}

def detect_host_platform []: nothing -> string {
    $"linux/(detect_host_arch)"
}

def parse_platform []: string -> record {
    let parts = $in | split row "/"
    {os: ($parts | get 0), arch: ($parts | get 1)}
}

def parse_image []: string -> record {
    let parts = $in | split row "/" | last | split row ":"
    {image: ($parts | get 0), tag: ($parts | get 1)}
}

def format_arch []: string -> string {
    match $in {
        "amd64" => "x86_64"
        "arm64" => "aarch64"
        "arm32" => "armv7l"
        _ => $in
    }
}

def format_platform_image [ctx: record, platform: record]: nothing -> string {
    $"($ctx.image)_($platform.os)_($platform.arch)"
}

def format_nix_flake [ctx: record, platform: record]: nothing -> string {
    let formatted_arch = $platform.arch | format_arch
    let formatted_image = $ctx.image | parse_image
    $"($ctx.build_context)#packages.($formatted_arch)-($platform.os).($formatted_image.image)"
}

def get_platforms []: nothing -> string {
    if ($env.PLATFORMS? | default "" | is-empty) {
        let detected: string = detect_host_platform
        print $"No PLATFORMS specified, detected host platform: ($detected)"
        $detected
    } else {
        $env.PLATFORMS | split row ","
    }
}

def get_push_image []: nothing -> bool {
    $env.PUSH_IMAGE? | default "false" | into bool
}

def get_skaffold_context []: nothing -> record {
    let platforms = get_platforms
    let push_image = get_push_image
    let ctx = {
        build_context: $env.BUILD_CONTEXT,
        image: $env.IMAGE,
        platforms: $platforms,
        push_image: $push_image
    }
    print $"Building configuration: image '($ctx.image)' for platforms ($ctx.platforms) from context '($ctx.build_context)' with push enabled: ($ctx.push_image)"
    $ctx
}

def get_docker_host []: nothing -> string {
    if ($env.DOCKER_HOST? | default "" | is-empty) {
        if ("/var/run/docker.sock" | path exists) {
            "unix:///var/run/docker.sock"
        } else if ("$HOME/.docker/run/docker.sock" | path exists) {
            $"unix://($env.HOME)/.docker/run/docker.sock"
        } else if ($"/run/user/($env.USER_UID)/docker.sock" | path exists) {
            $"unix:///run/user/($env.USER_UID)/docker.sock"
        } else {
            "unix:///var/run/docker.sock"
        }
    } else {
        $env.DOCKER_HOST
    }
}

def build_flake []: string -> string {
    nix build --accept-flake-config --print-out-paths $in | str trim
}

def push_image_to_registry [docker_host: string, image: string]: binary -> error {
    (
        skopeo copy
            --dest-daemon-host $"($docker_host)"
            $"docker-archive:/dev/stdin"
            $"docker://($image)"
    )
}

def push_image_to_docker_daemon [docker_host: string, image: string]: binary -> error {
    (
        skopeo copy
            --dest-daemon-host $"($docker_host)"
            $"docker-archive:/dev/stdin"
            $"docker-daemon:($image)"
    )
}

def push_image [ctx: record, image: string]: string -> error {
    let docker_host = get_docker_host
    let image_stream = run-external $in
    if $ctx.push_image {
        $image_stream | push_image_to_registry $docker_host $image
    } else {
        $image_stream | push_image_to_docker_daemon $docker_host $image
    }
}

def build_platform_image [ctx: record]: string -> record {
    let platform = $in | parse_platform
    let flake_url = format_nix_flake $ctx $platform
    let image_name = format_platform_image $ctx $platform
    $flake_url | build_flake | push_image $ctx $image_name
    {name: $image_name, platform: $platform, flake: $flake_url}
}

def remove_manifest [ctx: record]: nothing -> nothing {
    try {
        buildah manifest rm $ctx.image
    } catch { |err|
        print $"Manifest removal failed for ($ctx.image): ($err.msg)"
    }
}

def annotate_manifest [ctx: record, image: record]: nothing -> nothing {
    (
        buildah manifest add
            --os $image.platform.os
            --arch $image.platform.arch
            $ctx.image $"docker://($image.name)"
    )
}

def create_manifest [ctx: record, images: list<record>]: nothing -> nothing {
    print $"Creating manifest for ($ctx.image)..."
    remove_manifest $ctx
    buildah manifest create $ctx.image
    $images | par-each { |image| annotate_manifest $ctx $image } | ignore
}

def push_manifest [ctx: record]: nothing -> error {
    if $ctx.push_image {
        buildah manifest push --all $ctx.image $"docker://($ctx.image)"
    }
}

def build_and_push_multiplatform_image [ctx: record]: nothing -> error {
    let images: list<record> = $ctx.platforms | par-each { |platform| $platform | build_platform_image $ctx }
    create_manifest $ctx $images
    push_manifest $ctx
}

def build_and_push_image [ctx: record]: nothing -> error {
    let platform = $ctx.platforms | first | parse_platform
    let flake_url = format_nix_flake $ctx $platform
    $flake_url | build_flake | push_image $ctx $ctx.image
}

def build [ctx: record]: nothing -> error {
    if (($ctx.platforms | length) == 1) {
        build_and_push_image $ctx
    } else {
        build_and_push_multiplatform_image $ctx
    }
}

build (get_skaffold_context)
