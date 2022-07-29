#! /usr/bin/env nix-shell
#! nix-shell --pure ../../shell.nix -i bash

set -eu # exit on failure

echo Nix environment OK
poetry run echo Poetry environment OK