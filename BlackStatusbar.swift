import AppKit

// Puts a black strip behind the menu bar on screens with a notch, so the notch disappears into it.

/// The strip to paint on a screen, or nil when it has no notch or its menu bar is set to hide (the strip would cover windows).
func barRect(frame: NSRect, visible: NSRect, notch: CGFloat) -> NSRect? {
    guard notch > 0, frame.maxY > visible.maxY else { return nil }
    let height = max(frame.maxY - visible.maxY, notch)  // the menu bar is about 0.5pt taller than the notch
    return NSRect(x: frame.minX, y: frame.maxY - height, width: frame.width, height: height)
}

if CommandLine.arguments.contains("--self-test") {
    let screen = NSRect(x: 0, y: 0, width: 1710, height: 1112)
    precondition(barRect(frame: screen, visible: NSRect(x: 79, y: 0, width: 1631, height: 1074), notch: 37.5)
                 == NSRect(x: 0, y: 1074, width: 1710, height: 38))
    precondition(barRect(frame: screen, visible: screen, notch: 0) == nil)
    precondition(barRect(frame: screen, visible: screen, notch: 37.5) == nil)
    print("self-test ok")
    exit(0)
}

final class Bar: NSWindow {
    override func constrainFrameRect(_ rect: NSRect, to screen: NSScreen?) -> NSRect { rect }  // allow sitting under the menu bar
}

var bars: [NSWindow] = []

// macOS picks the menu bar text colour from the wallpaper and turns it black on a very light one.
// The strip then steps aside so the menus stay readable. A zero-width status item reports that colour.
// shortcut: the item reports one menu bar; when that is on a screen without a notch the strip hides to be safe,
// and switching the active display without plugging anything in waits for the next colour change.
@MainActor func showBars() {
    let button = probe.button!
    let onNotchedScreen = (button.window?.screen?.safeAreaInsets.top ?? 0) > 0
    let textIsWhite = onNotchedScreen && button.effectiveAppearance.bestMatch(from: [.vibrantDark, .vibrantLight]) == .vibrantDark
    bars.forEach { textIsWhite ? $0.orderFrontRegardless() : $0.orderOut(nil) }
}

@MainActor func rebuild() {
    bars.forEach { $0.orderOut(nil) }
    bars = NSScreen.screens.compactMap { screen in
        guard let rect = barRect(frame: screen.frame, visible: screen.visibleFrame, notch: screen.safeAreaInsets.top) else { return nil }
        let bar = Bar(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        bar.backgroundColor = .black
        bar.hasShadow = false
        bar.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) - 1)  // just behind the menu bar
        bar.ignoresMouseEvents = true
        bar.collectionBehavior = [.canJoinAllSpaces, .stationary]  // full-screen spaces are already black at the top
        return bar
    }
    showBars()
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let probe = NSStatusBar.system.statusItem(withLength: 0)
let watch = MainActor.assumeIsolated {  // top-level code runs on the main thread
    rebuild()
    return probe.button!.observe(\.effectiveAppearance) { _, _ in MainActor.assumeIsolated { showBars() } }
}
// Resolution changes, displays plugged in or out, lid closed.
NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { _ in
    MainActor.assumeIsolated { rebuild() }
}
app.run()
