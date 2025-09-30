<!-- markdownlint-disable first-line-heading -->

![header.png](https://raw.githubusercontent.com/shikanime/shikanime/main/assets/github-header.png)

<!-- markdownlint-enable first-line-heading -->

## niximgs

Hey 🌸 I'm Shikanime Deva, this is a repository of well-known applications containerized using nixpkgs.

This repository provides Docker images for popular applications built with Nix, ensuring reproducible and reliable container builds.

### Available Applications

- **jellyfin** - Media server for managing and streaming media
- **postgresql** - Advanced open-source relational database
- **radarr** - Movie collection manager for Usenet and BitTorrent users
- **redis** - In-memory data structure store
- **sonarr** - TV series collection manager for Usenet and BitTorrent users
- **syncthing** - Continuous file synchronization program
- **uv** - Fast Python package installer and resolver
- **vaultwarden** - Unofficial Bitwarden compatible server written in Rust
- **whisparr** - Adult movie collection manager

### Usage

All images are built using Nix and published to GitHub Container Registry. You can pull them using:

```bash
docker pull ghcr.io/shikanime/<application>:latest
```

### Building

To build the images locally:

```bash
nix develop --impure -c skaffold build
```
