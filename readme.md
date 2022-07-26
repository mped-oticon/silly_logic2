# Usage example: Usual GUI on current $DISPLAY
```
nix-shell --pure shell_saleaelogic2.nix --run "saleae-logic-2"
```

# Usage example: "Headless" VNC server
```
nix-shell --pure shell_saleaelogic2.nix --run "expose-as-vnc-server jwm-run saleae-logic-2"
```
