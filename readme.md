# Silly Logic 2

Saleae Logic devices are very capable, very expensive.
However their software is crippled and obese.
Sure, GUIs are nice sometimes - but definitely not all the time.

Logic GUI v1 had some limited automation, but still insisted on requiring X11
and Qt framework locking ipc kernel shared memory segments and lock files under /tmp.

Logic GUI v2 had no automation until recently; now we have a nicer gRPC socket.
Qt quirks are gone, but now we deal with AppImage, Chrome/Electron and early Python code.
In addition, we need jump through hoops for activing the Automation and disabling popups.
And X11 is still a requirement.

This means Saleae software is quite *silly*.

Nix is the opposite of silly; in fact we can confine the silliness with Nix.
Finally we sprinkle some, optional, Xvfb/x11vnc on top.
This should make Saleae much more edible for use in regression setups.



## Usage example: Show Saleae Logic GUI on current $DISPLAY
```
$ nix-shell --pure shell_saleaelogic2.nix --run "./logic.sh"
```
This is fine for personal development; less so for regression.
Regression machines should be minimalistic, so there is no fancy Desktop Environment.
Therefore one typically uses Xvfb, which is fine but prevents (easy) visual inspection.
Also, Xvfb instances need coordination of display numbers to prevent conflicts with other Xvfb instances.
Wouldn't it be nice if these issues were solved in a race-free, clean, debuggable way? See below :)



## Usage example: Show on "Headless" VNC server
```
$ nix-shell --pure shell_saleaelogic2.nix --run "expose-as-vnc-server jwm-run ./logic.sh"
```
This is good for regression:
 * $DISPLAY is automatically found
 * Everything is cleaned up at exit
 * Gives developers a chance to visually inspect waveforms



## Usage example: Fully scripted via python
```
$ nix-shell shell_saleaelogic2.nix --run "poetry run python3 auto_saleae.py --capture --verbose"
```

