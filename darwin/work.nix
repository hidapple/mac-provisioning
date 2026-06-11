{ pkgs, ... }:
{
  # Work-only packages.
  environment.systemPackages = with pkgs; [
    kubectl
    google-cloud-sdk
    # gcloud's component manager is disabled under Nix; declare components here
    # instead. To add some, replace `google-cloud-sdk` above with e.g.:
    #   (google-cloud-sdk.withExtraComponents [
    #     google-cloud-sdk.components.gke-gcloud-auth-plugin
    #   ])
  ];
}
