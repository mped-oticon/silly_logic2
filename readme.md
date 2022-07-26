# Usage example: Show Saleae Logic GUI on current $DISPLAY
```
nix-shell --pure shell_saleaelogic2.nix --run "./logic.sh"
```
This is fine for personal development; less so for regression.
Regression machines should be minimalistic, so there is no fancy Desktop Environment.
Therefore one typically uses Xvfb, which is fine but prevents (easy) visual inspection.
Also, Xvfb instances need coordination of display numbers to prevent conflicts with other Xvfb instances.
Wouldn't it be nice if these issues were solved in a race-free, clean, debuggable way? See below :)


# Usage example: Show on "Headless" VNC server
```
nix-shell --pure shell_saleaelogic2.nix --run "expose-as-vnc-server jwm-run ./logic.sh"
```
This is good for regression:
 * $DISPLAY is automatically found
 * Everything is cleaned up at exit
 * Gives developers a chance to visually inspect waveforms

