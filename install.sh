#!/bin/sh
# Builds black-statusbar and starts it at every login (launchd also restarts it if it ever stops).
# Usage: ./install.sh            install or update
#        ./install.sh uninstall  stop it and remove it
set -e
cd "$(dirname "$0")"

BIN="$HOME/.local/bin/black-statusbar"
LABEL="io.github.juan23.black-statusbar"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

if [ "$1" = uninstall ]; then
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  rm -f "$PLIST" "$BIN"
  echo "Removed black-statusbar."
  exit 0
fi

# Build and check before stopping the running copy, so a failed build leaves it running.
mkdir -p "$(dirname "$BIN")" "$(dirname "$PLIST")"
swiftc -O BlackStatusbar.swift -o "$BIN.new"
"$BIN.new" --self-test
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
mv "$BIN.new" "$BIN"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$BIN</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict>
</plist>
EOF

# Starting it again right after stopping it can fail for a moment.
for _ in 1 2 3 4 5; do
  launchctl bootstrap "$DOMAIN" "$PLIST" 2>/dev/null && break
  sleep 1
done
if ! launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
  echo "Could not start black-statusbar. Check that it is allowed under System Settings > General > Login Items & Extensions." >&2
  exit 1
fi
echo "Installed. black-statusbar is running and will start at every login."
