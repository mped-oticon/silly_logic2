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



## Usage example 1: Show Logic GUI on current $DISPLAY
```
$ nix-shell --pure --run "./logic.sh"
```
This is fine for personal development; less so for regression.
Regression machines should be minimalistic, so there is no fancy Desktop Environment.
Therefore one typically uses Xvfb, which is fine but prevents (easy) visual inspection.
Also, Xvfb instances need coordination of display numbers to prevent conflicts with other Xvfb instances.
Wouldn't it be nice if these issues were solved in a race-free, clean, debuggable way? See below :)



## Usage example 2: Show Logic GUI on "Headless" VNC server
```
$ nix-shell --pure --run "expose-as-vnc-server jwm-run ./logic.sh"
```
This is good for regression:
 * Uses new unallocated $DISPLAY
 * Cleans up at exit
 * Gives developers a chance to visually inspect waveforms

![Screenshot of VNC client](https://i.imgur.com/0iMRPAK.png)

This depends on
[expose-as-vnc-server](https://github.com/mped-oticon/expose-as-vnc-server) and
[jwm-run](https://github.com/mped-oticon/jwm-run), which already are included in `shell.nix`.



## Usage example 3: Fully scripted via python
```
$ ./auto_saleae.py --capture --verbose
```
This python code has all its dependencies taken care of through poetry.
It starts `./logic.sh` by default (see `-s` option), and {starts, stops, exports} a capture, then kills Logic GUI.
Like example 1, Logic GUI will appear on current $DISPLAY.
Several options are explained by `--help`.
If physical Saleae Logic device is connected, virtual devices can't be selected via `-d` option -- see example 4.



## Usage example 4: Fully scripted via python against simulated Logic device
```
$ ./auto_saleae.py --capture --verbose -d F4241
```

F4241 is the serial number for a virtual Logic Pro 16 device.
These virtual devices are only selectable when no physical devices are found by Logic.
Testing of our python code without interfering with physically attached devices, requires masking out USB devices.
Therefore selecting a virtual device will let `./logic.sh` execute under `./mask_out_usb_devices.sh`.

