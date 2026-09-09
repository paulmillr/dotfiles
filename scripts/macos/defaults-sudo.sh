#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

# Ask for the administrator password upfront so later sudo calls don't interrupt the run.
sudo -v

# Touchpad tap-to-click
sudo defaults write com.apple.AppleMultitouchTrackpad Clicking 1

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "
# Apply
# =====
# Restart affected apps so the settings above take effect.
# Terminal is intentionally not killed; restart it manually.
for app in cfprefsd Dock Finder SystemUIServer; do
  killall "$app" 2> /dev/null || true
done
echo 'Done. Restart Terminal.app manually; some changes need a logout/restart.'
