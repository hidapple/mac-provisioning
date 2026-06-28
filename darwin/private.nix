{ pkgs, ... }:
{
  # Private-only packages.
  environment.systemPackages = with pkgs; [
    flyctl
    postgresql # provides psql client
    turso-cli
  ];
}
