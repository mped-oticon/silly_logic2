#!/usr/bin/env bash
#
# What: Run payload command without access to USB devices.
# Intent: Test USB-sensitive commands for use in regression.
# How: 
#   Via cgroups, bubblewrap lets us manipulate {filesystem, networking, etc} for single one-off processes.
#   Here we want our payload to not see any USB devices -- for testing purposes.
#   First we bind everything 1:1, then we mount a new minimal /dev, and mount over /sys's USB device tree with an empty tmpfs.
#   Bubblewrap does not require {root permission, special privileges} to do this.
# Why: Saleae Logic GUi prevents accessing built-in virtual devices when a physical device is attached.
#
# Usage example 0 -- lots of USB devices attached:
#   $ lsusb | wc -l
#   12
#
# Usage example 1 -- Now they're "gone", yay
#   $ ./mask_out_usb_devices.sh lsusb | wc -l
#   0
#
# Usage example 2 -- Sanity test of bubblewrap, without hiding USB devices
#   $ OPTS_HIDE_USB="" ./mask_out_usb_devices.sh lsusb | wc -l
#   12
#
# Usage example 3 -- same as example 0, just under nix
#   $ nix-shell -p usbutils -p bubblewrap --run "lsusb" | wc -l
#   12
#
# Usage example 4 -- same as example 1, just under nix
#   $ nix-shell -p usbutils -p bubblewrap --run "./mask_out_usb_devices.sh lsusb" | wc -l
#   0
#
# Usage example 5 -- Gain access to virtual Logic devices, or prevent interfering with physical device
#   $ nix-shell shell_saleaelogic2.nix --run "./mask_out_usb_devices.sh ./logic.sh"


# Determine if bubblewrap is already available
if type bwrap &> /dev/null; then
    : # Natively available, use that
else
    # Not installed, let's get it from Nix
    function bwrap { nix-shell -p bubblewrap --run "bwrap $*"; }
fi

# Bubblewrap USB-related options
OPTS_HIDE_USB_SYS="--tmpfs /sys/bus/usb/devices"            # Enough for lsusb, but not Logic
OPTS_HIDE_USB_ALL="--tmpfs /sys/bus/usb/devices --dev /dev" # Agressive. Required to hide from Logic
OPTS_HIDE_USB_DEFAULTS="$OPTS_HIDE_USB_ALL"

# Run payload command under modified environment
bwrap \
    --dev-bind / / \
    --proc /proc  \
    --die-with-parent \
    ${OPTS_HIDE_USB-${OPTS_HIDE_USB_DEFAULTS}} \
    $@
