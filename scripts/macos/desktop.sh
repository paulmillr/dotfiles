#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

# Remove configured Desktop and Notification Center widgets without resetting
# the rest of Notification Center's preferences.
defaults delete com.apple.notificationcenterui widgets 2> /dev/null || true

# Keep widgets off the desktop in both normal mode and Stage Manager.
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

wallpaper='/System/Library/Desktop Pictures/Solid Colors/Black.png'
if [ ! -r "$wallpaper" ]; then
  echo "Black system wallpaper not found: $wallpaper" >&2
  exit 1
fi

# Apply the wallpaper to every Space on every connected display.
osascript - "$wallpaper" <<'APPLESCRIPT'
on run argv
  set wallpaperFile to POSIX file (item 1 of argv)
  tell application "System Events"
    repeat with desktopItem in desktops
      set picture of desktopItem to wallpaperFile
    end repeat
  end tell
end run
APPLESCRIPT

killall NotificationCenter 2> /dev/null || true
echo 'Done. Widgets are removed and the wallpaper is black.'
