{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "vaultwarden";
  tag = pkgs.vaultwarden.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.vaultwarden}/bin/vaultwarden"
    ];
    Env = [
      "PATH=${pkgs.vaultwarden}/bin"
      "ROCKET_ADDRESS=0.0.0.0"
      "ROCKET_PORT=80"
    ];
    ExposedPorts = {
      "80/tcp" = { }; # Vaultwarden default port
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.vaultwarden.meta.description;
      "org.opencontainers.image.licenses" = pkgs.vaultwarden.meta.license.spdxId;
    };
    User = "1000:1000";
  };
  fakeRootCommands = ''
    mkdir -p ./var/lib/vaultwarden
    chown 1000:1000 ./var/lib/vaultwarden
  '';
}
