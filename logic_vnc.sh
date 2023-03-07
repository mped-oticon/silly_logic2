#!/usr/bin/env bash

# Ensure ./logic.sh exists in PATH
export PATH="$PATH:$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

# xvfb is the actual X virtual framebuffer - low-level
export XVFB_SERVER_ARGS='-screen 0 1920x1080x24'

# xvfb is executed by xvfb-run script, which allocates display numbers
export XVFBRUN_ARGS='--auto-display'

# expose-as-vnc-server runs xvfb-run and then x11vnc
export X11VNC_PASSWD=whatever

# run logic.sh in a small window manager, and expose the whole thing via VNC
expose-as-vnc-server jwm-run logic.sh
