#!/usr/bin/env nix
#! nix develop --impure --command nu

def detect_host_arch []: nothing -> string {
    let arch: string = (uname | get machine)
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
    let parts = split row "/"
    {os: ($parts | get 0), arch: ($parts | get 1)}
}

def parse_image []: string -> string {
    split row "/" | last | split row ":" | get 0
}

def format_arch []: string -> string {
    match $in {
        "amd64" => "x86_64"
        "arm64" => "aarch64"
        "arm32" => "armv7l"
        _ => $in
    }
}

def format_image [platform_parts: record]: record -> string {
    let formatted_arch = $platform_parts.arch | format_arch
    $"($in.image)-($formatted_arch)"
}

def format_nix_flake [image_name: string, platform_parts: record]: record -> string {
    let formatted_arch = $platform_parts.arch | format_arch
    $"($in.build_context)#packages.($formatted_arch)-($platform_parts.os).($image_name)"
}

def get_platforms []: nothing -> string {
    if ($env.PLATFORMS? | default "" | is-empty) {
        let detected: string = (detect_host_platform)
        print $"No PLATFORMS specified, detected host platform: ($detected)"
        $detected
    } else {
        $env.PLATFORMS
    }
}

def get_push_image []: nothing -> bool {
    $env.PUSH_IMAGE? | default "false" | into bool
}

def get_config []: nothing -> record {
    let platforms = (get_platforms)
    let push_image = (get_push_image)
    let config = {
        build_context: $env.BUILD_CONTEXT,
        image: $env.IMAGE,
        platforms: $platforms,
        push_image: $push_image
    }
    print $"Building configuration: image '($config.image)' for platforms ($config.platforms) from context '($config.build_context)' with push enabled: ($config.push_image)"
    $config
}

def load_docker_image []: string -> string {
    let docker_load_result: string = docker load -i $in | str trim

    # Try to parse "Loaded image:" format first
    let loaded_images = ($docker_load_result | parse "Loaded image: {image}")

    let image_name: string = if ($loaded_images | length) > 0 {
        $loaded_images | get image.0
    } else {
        # If that fails, try to parse the "already exists" format with more flexible regex
        let existing_images = ($docker_load_result | parse "The image {image} already exists")

        if ($existing_images | length) > 0 {
            $existing_images | get image.0
        } else {
            # Try to extract image name from the beginning of "already exists" messages
            let image_pattern = ($docker_load_result | parse --regex 'The image (?P<image>\S+:\S+) already exists')

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

def build_and_load_flake []: string -> string {
    nix build --accept-flake-config --print-out-paths $in.build_context str trim
    | load_docker_image
}

def build_platform_image [platform: string]: record -> string {
    let platform_parts = $platform | parse_platform
    let image_name = $in.image | parse_image

    print $"Building ($image_name) for ($platform)..."

    let flake_url = format_nix_flake $image_name $platform_parts
    let loaded_image = $flake_url | build_and_load_flake

    let image = format_image $platform_parts
    docker tag $loaded_image $image

    $image
}

def build_and_push_platform_image [platform: string]: record -> string {
    let image = build_platform_image $platform

    if $in.push_image {
        print $"Pushing ($image)..."
        docker push $image
    }

    $image
}

def build_and_push_all_platform_images []: record -> list<string> {
    $in.platforms
        | split row ","
        | par-each { |platform|
            build_and_push_platform_image $platform
        }
}

def create_and_push_manifest [manifest_images: list<string>]: record -> nothing {
    if ($manifest_images | length) > 0 {
        print $"Creating manifest for ($in.image)..."

        docker manifest rm $in.image

        docker manifest create $in.image ...$manifest_images

        if $in.push_image {
            print $"Pushing manifest for ($in.image)..."
            docker manifest push $in.image
        }
    }
}

let config = (get_config)
$config | create_and_push_manifest ($config | build_and_push_all_platform_images)
print "Build completed successfully"
