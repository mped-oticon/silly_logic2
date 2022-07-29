#! /usr/bin/env nix-shell
#! nix-shell --pure ../../shell.nix -i bash

set -eu
echo Nix environment OK
poetry run echo Poetry envrionment OK
