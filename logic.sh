#!/usr/bin/env bash
# Start gRPC server which is embedded into the Logic GUI

function reset_usb {
    local vendor_id="$1"
    lsusb -d "${vendor_id}:" | grep -Eo "${vendor_id}:[^ ]+" | while read vidpid; do usb-reset "$vidpid"; done
}

# Ensure known-good initial state of physical Logic Device(s).
# If Logic GUI is violently kill -9'ed during capture, subsequent
# captures will crash and one must reset the usb device itself.
# We can't detect if that would be the case beforehand, so we will rather always reset.
saleae_vendor_id="21a9"
reset_usb "$saleae_vendor_id"

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
