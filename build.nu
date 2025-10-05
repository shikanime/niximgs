#!/usr/bin/env nix
#! nix develop --impure --command nu

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

def parse_image []: string -> string {
    $in | split row "/" | last | split row ":" | get 0
}

def format_arch []: string -> string {
    match $in {
        "amd64" => "x86_64"
        "arm64" => "aarch64"
        "arm32" => "armv7l"
        _ => $in
    }
}

def format_image [ctx: record, platform_parts: record]: nothing -> string {
    let formatted_arch = $platform_parts.arch | format_arch
    $"($ctx.image)-($formatted_arch)"
}

def format_nix_flake [ctx: record, image_name: string, platform_parts: record]: nothing -> string {
    let formatted_arch = $platform_parts.arch | format_arch
    $"($ctx.build_context)#packages.($formatted_arch)-($platform_parts.os).($image_name)"
}

def get_platforms []: nothing -> string {
    if ($env.PLATFORMS? | default "" | is-empty) {
        let detected: string = detect_host_platform
        print $"No PLATFORMS specified, detected host platform: ($detected)"
        $detected
    } else {
        $env.PLATFORMS
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

def load_docker_image []: string -> string {
    let docker_load_result: string = docker load -i $in | str trim

    # Try to parse "Loaded image:" format first
    let loaded_images = $docker_load_result | parse "Loaded image: {image}"

    let image_name: string = if ($loaded_images | length) > 0 {
        $loaded_images | get image.0
    } else {
        # If that fails, try to parse the "already exists" format with more flexible regex
        let existing_images = $docker_load_result | parse "The image {image} already exists"

        if ($existing_images | length) > 0 {
            $existing_images | get image.0
        } else {
            # Try to extract image name from the beginning of "already exists" messages
            let image_pattern = $docker_load_result | parse --regex 'The image (?P<image>\S+:\S+) already exists'

            if ($image_pattern | length) > 0 {
                $image_pattern | get image.0
            } else {
                print $"Error: Could not parse loaded image from Docker output: ($docker_load_result)"
                exit 1
            }
        }
    }

    $image_name
}

def build_flake []: string -> string {
    nix build --accept-flake-ctx --print-out-paths $in | str trim
}

def build_platform_image [ctx: record]: string -> string {
    let platform_parts = $in | parse_platform
    let image_name = $ctx.image | parse_image

    print $"Building ($image_name) for ($in)..."

    let flake_url = format_nix_flake $ctx $image_name $platform_parts
    let loaded_image = $flake_url | build_flake | load_docker_image

    let image = format_image $ctx $platform_parts
    docker tag $loaded_image $image

    $image
}

def push_image [ctx: record]: string -> nothing {
    if $ctx.push_image {
        docker push $in
    }
}

def build_all_platform_images [ctx: record]: nothing -> list<string> {
    $ctx.platforms
        | split row ","
        | par-each { |platform|
            $platform | build_platform_image $ctx
        }
}

def push_all_platform_images [ctx: record, manifest_images: list<string>]: nothing -> list<nothing> {
    $manifest_images
    | par-each { |image| $image | push_image $ctx }
}

def remove_manifest [ctx: record]: nothing -> nothing {
    try {
        docker manifest rm $ctx.image
    } catch { |err|
        print $"Manifest removal failed for ($ctx.image): ($err.msg)"
    }
}

def create_manifest [ctx: record, manifest_images: list<string>]: nothing -> nothing {
    if ($manifest_images | length) > 0 {
        print $"Creating manifest for ($ctx.image)..."
        remove_manifest $ctx
        docker manifest create $ctx.image ...$manifest_images
    }
}

def push_manifest [ctx: record]: nothing -> nothing {
    if $ctx.push_image {
        docker manifest push $ctx.image
    }
}

def build_multiplatform_image [ctx: record]: nothing -> nothing {
    let manifest_images = build_all_platform_images $ctx
    push_all_platform_images $ctx $manifest_images
    create_manifest $ctx $manifest_images
    push_manifest $ctx
}

let ctx = get_skaffold_context
build_multiplatform_image $ctx
