{ pkgs, ... }:
{
  # Work-only packages.
  environment.systemPackages = with pkgs; [
    kubectl
    # gcloud's component manager is disabled under Nix; declare components
    # via withExtraComponents instead.
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];
}
