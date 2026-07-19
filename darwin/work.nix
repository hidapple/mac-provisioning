{ pkgs, ... }:
{
  # Work-only packages.
  environment.systemPackages = with pkgs; [
    # GNU coreutils as g-prefixed commands (gcsplit, gls, ...) like Homebrew.
    coreutils-prefixed
    # Expose GNU sed as `gsed` (like Homebrew) so it doesn't shadow BSD sed.
    (runCommand "gsed" { } ''
      mkdir -p $out/bin
      ln -s ${gnused}/bin/sed $out/bin/gsed
    '')
    kubectl
    yq-go
    # gcloud's component manager is disabled under Nix; declare components
    # via withExtraComponents instead.
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];
}
