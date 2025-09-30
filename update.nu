#!/usr/bin/env nix
#! nix develop --impure --command nu

# Update gitignore
gitnr create repo:github/gitignore/refs/heads/main/Nix.gitignore repo:shikanime/gitignore/refs/heads/main/Devenv.gitignore tt:jetbrains+all tt:linux tt:macos tt:terraform tt:vim tt:visualstudiocode tt:windows | save --force .gitignore

# Update workflows
print "[workflows] Updating GitHub Actions workflows..."
nu $"($env.FILE_PWD)/.github/workflows/update.nu"
    | lines
    | each { |line|
        print $"[workflows] ($line)"
    }
    | ignore
