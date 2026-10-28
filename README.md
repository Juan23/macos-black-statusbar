# Black Statusbar: hide the MacBook notch with a black menu bar

**Black Statusbar is a free, open-source, tiny macOS app that turns the menu bar black on MacBooks with a notch, so the notch blends in and disappears.** It works on every MacBook Pro and MacBook Air with a notch (M1 Pro, M1 Max, M2, M3, M4, M5 and later), and it never touches your wallpaper.

## Why hide the notch?

On a MacBook with a notch, the camera housing cuts into the top of the screen. Since macOS made the menu bar (status bar) see-through, the notch sits on top of your wallpaper as a black cut-out. Black Statusbar paints the whole menu bar black, so the bar and the notch become one solid black strip that looks like a bezel.

## Features

- **Hides the notch** by making the menu bar solid black.
- **Leaves your wallpaper alone.** Photo shuffles, dynamic and aerial wallpapers keep working because nothing is edited or replaced.
- **Menus stay clickable.** The black strip sits behind the menu bar and lets every click through.
- **Starts at login** and restarts itself if it ever stops.
- **Keeps menus readable.** On a very bright wallpaper macOS turns the menu text black, so the strip steps aside until you pick a darker wallpaper.
- **Only on screens with a notch.** External displays are left as they are.
- **Small and private.** One short Swift file, no dependencies, and no Screen Recording or Accessibility permission.

## Supported Macs

Any MacBook with a notch:

- MacBook Pro 14-inch and 16-inch, 2021 and later (M1 Pro and M1 Max onwards)
- MacBook Air 13-inch and 15-inch, M2 and later

Tested on an M5 MacBook with macOS 27.

## Install

You need Xcode or the Xcode command line tools with Swift 5.9 or later. To get the command line tools, run `xcode-select --install`.

```bash
git clone https://github.com/Juan23/macos-black-statusbar.git
cd macos-black-statusbar
./install.sh
```

The script builds the app into `~/.local/bin/black-statusbar` and adds a launch agent, so it starts at every login. macOS may show a "Background Items Added" notice the first time, and lists it under System Settings > General > Login Items & Extensions.

To update, pull the latest code and run `./install.sh` again.

## Uninstall

```bash
./install.sh uninstall
```

This stops the app and removes the app and its launch agent.

## FAQ

### How do I hide the notch on my MacBook?

Install Black Statusbar with the steps above. The menu bar turns black and the notch blends into it. There is nothing to set up.

### Does it change my wallpaper?

No. Some notch-hiding apps add a black band to your wallpaper image and have to redo it every time the wallpaper changes. Black Statusbar draws its own black strip behind the menu bar instead, so any wallpaper works.

### Why does the menu bar sometimes go back to normal?

macOS chooses the menu bar text colour from your wallpaper, and no app can change that choice. On a very bright wallpaper the text turns black, which would vanish on a black bar. The strip steps aside so you can still read the menus, and it comes back as soon as the wallpaper is darker. Dark and mid-tone wallpapers keep the bar black; even a plain 60% grey does.

### Does it work with full-screen apps?

Full-screen apps already show a black bar around the notch, so Black Statusbar stays out of full-screen spaces.

### Will it cover my windows?

No. It only paints the menu bar area and lets every click through. If your menu bar is set to hide automatically, the strip stays off so it never covers your windows.

### Does it use battery or CPU?

It draws one black window and does nothing more until your displays change or the menu bar text colour changes.

## How it works

For developers:

- A borderless, click-through `NSWindow` sits one level below the main menu window on every screen where `NSScreen.safeAreaInsets.top > 0`. Only notched screens have that top inset.
- The window joins all Spaces and is rebuilt when displays change: resolution changes, monitors plugged in or out, or the lid closing.
- A zero-width `NSStatusItem` reports the menu bar's appearance. When macOS switches the menu bar to dark text, the strip hides.
- A per-user launchd agent with `RunAtLoad` and `KeepAlive` starts it at login.

Run the built-in check with `~/.local/bin/black-statusbar --self-test`.

## Other ways to hide the notch

- **Change the display resolution.** In System Settings > Displays, choose a resolution that ends below the notch. You lose a strip of screen space.
- **Scale one app below the camera.** In Finder, select the app, choose Get Info and turn on "Scale to fit below built-in camera". This only affects that app.
- **Use full-screen mode.** Full-screen apps already black out the area around the notch.

## License

[MIT](LICENSE). Anyone is free to use, modify and share it, at their own risk: it comes with no warranty.
