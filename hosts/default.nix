# This Nix expression must be a attribute set where the keys are device
# hostnames and the keys are modules with a device-specific configuration.
{
  fabriq-mohamed-mbp = ./mohamed;
  fabriq-yacine-mbp-byob = ./yacine;
  fabriq-david-mbp = ./david;
  fabriq-remy-mbp = ./remy;
}
