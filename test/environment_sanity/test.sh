#! /usr/bin/env nix-shell
#! nix-shell --pure ../../shell.nix -i bash

set -eu # exit on failure

echo Nix environment OK
poetry run echo Poetry can run OK
poetry run python3 -c 'import saleae' && echo Poetry environment OK
