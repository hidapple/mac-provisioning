{ pkgs, ... }:
{
  # Private-only packages.
  environment.systemPackages = with pkgs; [
    flyctl
  ];
}
