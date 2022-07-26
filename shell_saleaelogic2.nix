# Lock all nix-package versions to that which is released atomically together
with (import (builtins.fetchTarball {
  # Release '22.05' is a tag which points to ce6aa13369b667ac2542593170993504932eb836
  url = "https://github.com/nixos/nixpkgs/tarball/22.05";
  # This hash is git-agnostic so nix can detect if the git-tag changes
  sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
}) {});

let
  wdh_sl2 = import ./pkg_saleaelogic2.nix;
  wdh_exposevnc = import ./pkg_exposevnc.nix;
  wdh_jwmrun = import ./pkg_jwmrun.nix;
in pkgs.mkShell {
  buildInputs = [
    # Oticon special interest packages
    wdh_sl2
    wdh_exposevnc
    wdh_jwmrun

    # For Logic's python gRPC Automation
    python39Packages.pip
    libstdcxx5

    # "Headless"/VNC dependencies
    jwm
    xvfb-run
    x11vnc
    xorg.xorgserver
  ];

  extracted_sl2 = (builtins.toString wdh_sl2) + "/wdh_extracted_appimage";

  shellHook = ''
    export PATH="$extracted_sl2:$PATH"

    export ENABLE_AUTOMATION=1

    mkdir -p $HOME/.config/Logic
    echo "NOTE: Overwriting your config.json file!"
    cp $HOME/.config/Logic/config.json $HOME/.config/Logic/config.json.backup
    cp config.json $HOME/.config/Logic/config.json
  '';
}
