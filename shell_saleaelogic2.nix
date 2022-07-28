{ 
  # Lock all nix-package versions to that which is released atomically together
  pkgs ? (import (builtins.fetchTarball {
           # Release '22.05' is a tag which points to ce6aa13369b667ac2542593170993504932eb836
           url = "https://github.com/nixos/nixpkgs/tarball/22.05";
           # This hash is git-agnostic so nix can detect if the git-tag changes
           sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
         }) {}),

  allthepoetrystuff ? import ./default.nix {} 
}:

let
  wdh_sl2 = import ./pkg_saleaelogic2.nix;
  wdh_exposevnc = import ./pkg_exposevnc.nix;
  wdh_jwmrun = import ./pkg_jwmrun.nix;
in pkgs.mkShell {
  buildInputs = [
    #allthepoetrystuff

    # Oticon special interest packages
    wdh_sl2
    wdh_exposevnc
    wdh_jwmrun

    # For Logic's python gRPC Automation
    #python39Packages.pip
    pkgs.libstdcxx5
    pkgs.stdenv.cc.cc.lib
    pkgs.poetry


    # "Headless"/VNC dependencies
    pkgs.jwm
    pkgs.xvfb-run
    pkgs.x11vnc
    pkgs.xorg.xorgserver
  ];

  extracted_sl2 = (builtins.toString wdh_sl2) + "/wdh_extracted_appimage";

  shellHook = ''
    # Prefix: Prefer the extracted Logic binary
    export PATH="$extracted_sl2:$PATH"

    # Postfix: Prefer system libraries, but let extracted libraries be a backup
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$extracted_sl2/resources/linux/optional/libstdc++

    # Install the python automation package
    #pip install --user logic2_automation-0.0.1-py3-none-any.whl
    #export PYTHONPATH=$PYTHONPATH:/home/eisbaw/.local/lib/python3.9/site-packages
    #python3 saleae_example.py


    #poetry run python3 saleae_example.py
  '';
}
