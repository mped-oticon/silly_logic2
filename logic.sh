#!/usr/bin/env bash

# To enable automation, both export and config setting are required
export ENABLE_AUTOMATION=1

# Scrub the config file clean
mkdir -p $HOME/.config/Logic
echo "NOTE: Overwriting your config.json file!"
cp $HOME/.config/Logic/config.json $HOME/.config/Logic/config.json.backup
cp config.json $HOME/.config/Logic/config.json

# Options. Mostly for Chromium which runs Electron.
# Logic does not accept options by itself
opts="--disable-gpu"

# First try Logic (without bubblewrap), if that fails use the bubblewrapped
Logic $opts 2>/dev/null || saleae-logic-2 $opts 2>/dev/null; exit $?
