{ base, pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "vaultwarden";
  tag = pkgs.vaultwarden.version;
  fromImage = base;

  config = {
    Entrypoint = [
      "${pkgs.vaultwarden}/bin/vaultwarden"
    ];
    ExposedPorts = {
      "80/tcp" = { }; # Vaultwarden default port
    };
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/shikanime/niximgs";
      "org.opencontainers.image.description" = pkgs.vaultwarden.meta.description;
      "org.opencontainers.image.licenses" = pkgs.vaultwarden.meta.license.spdxId;
    };
    Env = [
      "ROCKET_ADDRESS=0.0.0.0"
      "ROCKET_PORT=80"
    ];
    User = "1000:1000";
  };
}
