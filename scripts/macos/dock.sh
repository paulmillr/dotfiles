#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

# Reset the Dock to a fixed layout:
#   left (apps):     Safari, Terminal, System Settings, Apps (Launchpad's
#                    replacement in macOS Tahoe)
#   right (others):  ~/Downloads

defaults delete com.apple.dock persistent-apps 2> /dev/null || true
defaults delete com.apple.dock persistent-others 2> /dev/null || true

# Don't let recently used apps reappear next to the pinned ones.
defaults write com.apple.dock show-recents -bool false

# $1: absolute path to a .app bundle. Spaces must be percent-encoded (%20):
# _CFURLString is a file:// URL, not a plain path.
dock_add_app() {
  defaults write com.apple.dock persistent-apps -array-add "<dict>
    <key>tile-data</key><dict>
      <key>file-data</key><dict>
        <key>_CFURLString</key><string>file://$1/</string>
        <key>_CFURLStringType</key><integer>15</integer>
      </dict>
    </dict>
    <key>tile-type</key><string>file-tile</string>
  </dict>"
}

# $1: absolute folder path (percent-encoded), $2: arrangement (1 name, 2 date
# added), $3: showas (2 grid, 3 list)
dock_add_folder() {
  defaults write com.apple.dock persistent-others -array-add "<dict>
    <key>tile-data</key><dict>
      <key>file-data</key><dict>
        <key>_CFURLString</key><string>file://$1/</string>
        <key>_CFURLStringType</key><integer>15</integer>
      </dict>
      <key>arrangement</key><integer>$2</integer>
      <key>displayas</key><integer>1</integer>
      <key>showas</key><integer>$3</integer>
    </dict>
    <key>tile-type</key><string>directory-tile</string>
  </dict>"
}

dock_add_app '/Applications/Safari.app'
dock_add_app '/System/Applications/Utilities/Terminal.app'
dock_add_app '/System/Applications/System%20Settings.app'

# Apps.app (Tahoe's Launchpad replacement) is a system app; probe for it since
# its location isn't documented.
apps_added=0
for apps_path in '/System/Applications/Apps.app' '/Applications/Apps.app'; do
  if [ -d "$apps_path" ]; then
    dock_add_app "$apps_path"
    apps_added=1
    break
  fi
done
if [ "$apps_added" -eq 0 ]; then
  echo 'Warning: Apps.app not found (needs macOS 26 Tahoe); skipped.' >&2
fi

dock_add_folder "$HOME/Downloads" 2 3

killall Dock 2> /dev/null || true
echo 'Done. Dock restarted with the new layout.'
