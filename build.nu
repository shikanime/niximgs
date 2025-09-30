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

def parse_platform [platform: string]: nothing -> record {
    let parts = ($platform | split row "/")
    {os: ($parts | get 0), arch: ($parts | get 1)}
}

def parse_image [image: string]: nothing -> string {
    $image | split row "/" | last | split row ":" | get 0
}

def format_arch [arch: string]: nothing -> string {
    match $arch {
        "amd64" => "x86_64"
        "arm64" => "aarch64"
        "arm32" => "armv7l"
        _ => $arch
    }
}

def format_image [config: record, platform_parts: record]: nothing -> string {
    let formatted_arch = (format_arch $platform_parts.arch)
    $"($config.image)-($formatted_arch)"
}

def format_nix_flake [config: record, image_name: string, platform_parts: record]: nothing -> string {
    let formatted_arch = (format_arch $platform_parts.arch)
    $"($config.build_context)#packages.($formatted_arch)-($platform_parts.os).($image_name)"
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

def load_docker_image [nix_output: string]: nothing -> string {
    let docker_load_result: string = (try {
        docker load -i $nix_output | str trim
    } catch { |err|
        print $"Error loading Docker image: ($err.msg)"
        exit 1
    })

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

def maybe_remove_existing_manifest [image: string]: nothing -> nothing {
    try {
        docker manifest rm $image
    } catch {
        # Ignore error if manifest doesn't exist
    }
}

def build_and_load_flake [flake_url: string]: nothing -> string {
    let nix_output: string = (try {
        nix build $flake_url --print-out-paths | str trim
    } catch { |err|
        print $"Error building Nix flake: ($err.msg)"
        exit 1
    })

    load_docker_image $nix_output
}

def build_platform_image [config: record, platform: string]: nothing -> string {
    let platform_parts = (parse_platform $platform)
    let image_name = (parse_image $config.image)

    print $"Building ($image_name) for ($platform)..."

    let flake_url = (format_nix_flake $config $image_name $platform_parts)
    let loaded_image = (build_and_load_flake $flake_url)

    let image = (format_image $config $platform_parts)
    docker tag $loaded_image $image

    $image
}

def build_and_push_platform_image [config: record, platform: string]: nothing -> string {
    let image = (build_platform_image $config $platform)

    if $config.push_image {
        print $"Pushing ($image)..."
        try {
            docker push $image
        } catch { |err|
            print $"Error pushing image ($image): ($err.msg)"
            exit 1
        }
    }

    $image
}

def build_and_push_all_platform_images [config: record]: nothing -> list<string> {
    $config.platforms
        | split row ","
        | each { |platform|
            build_and_push_platform_image $config $platform
        }
}

def create_and_push_manifest [config: record, manifest_images: list<string>]: nothing -> nothing {
    if ($manifest_images | length) > 0 {
        print $"Creating manifest for ($config.image)..."

        maybe_remove_existing_manifest $config.image

        docker manifest create $config.image ...$manifest_images

        if $config.push_image {
            print $"Pushing manifest for ($config.image)..."
            docker manifest push $config.image
        }
    }
}

let config = (get_config)
let manifest_images = (build_and_push_all_platform_images $config)
create_and_push_manifest $config $manifest_images
print "Build completed successfully"
