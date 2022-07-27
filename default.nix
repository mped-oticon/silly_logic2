{
  # Lock all nix-package versions to that which is released atomically together
  pkgs ? (import (builtins.fetchTarball {
           # Release '22.05' is a tag which points to ce6aa13369b667ac2542593170993504932eb836
           url = "https://github.com/nixos/nixpkgs/tarball/22.05";
           # This hash is git-agnostic so nix can detect if the git-tag changes
           sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
         }) {})
}:
pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ./.;
}

