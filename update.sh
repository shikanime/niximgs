#!/usr/bin/env nix
#! nix develop --impure --command bash

set -o errexit
set -o nounset
set -o pipefail

# Update gitignore
gitnr create \
  repo:github/gitignore/refs/heads/main/Nix.gitignore \
  repo:shikanime/gitignore/refs/heads/main/Devenv.gitignore \
  tt:jetbrains+all \
  tt:linux \
  tt:macos \
  tt:terraform \
  tt:vim \
  tt:visualstudiocode \
  tt:windows >.gitignore

# Update workflows
bash "$(dirname "$0")"/.github/workflows/update.sh 2>&1 |
  sed 's/^/['workflows'] /'
