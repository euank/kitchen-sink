## custom xkeyboard layout + qt

Repro for https://github.com/NixOS/nixpkgs/issues/226484

### Running this repro

In this directory, run:

```
$ rm -f nixos.qcow2
$ nixos-rebuild build-vm --flake '.#test'
./result/bin/run-nixos-vm

# Wait for the desktop to appear and auto-login
# Open a terminal and run 'ebook-viewer'
```
