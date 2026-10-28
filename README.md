# macos-black-statusbar

Makes the menu bar black on MacBooks with a notch, so the notch disappears into it.

It puts a black strip behind the menu bar. Your wallpaper is never touched, the menus stay clickable, and only screens with a notch get the strip.

## Install

Needs a MacBook with a notch and Xcode or its command line tools with Swift 5.9 or later (`xcode-select --install`).

```bash
./install.sh
```

This builds the app into `~/.local/bin/black-statusbar` and adds a launch agent, so it starts at every login and restarts if it ever stops. macOS shows a "Background Items Added" notice the first time, and lists it under Login Items & Extensions.

If the menu bar is set to hide automatically, the strip stays off so it never covers your windows.

## Uninstall

```bash
./install.sh uninstall
```

## Very bright wallpapers

macOS picks the menu bar text colour from your wallpaper, and no app can change that. On a very bright wallpaper the text turns black, so the strip steps aside and the menu bar looks normal until you switch to a darker wallpaper. Dark and mid-tone wallpapers keep the bar black; a plain 60% grey still does.

Tested on an M5 MacBook with macOS 27.
