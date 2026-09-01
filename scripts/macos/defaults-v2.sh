#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

script_dir=$(CDPATH='' cd "$(dirname "$0")" && pwd -P)

# Finder > Settings > General
defaults write com.apple.finder NewWindowTarget -string 'PfDl'

# Finder > Settings > Advanced
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# Finder > Settings > Sidebar
# Replace Favorites so Recents, Shared, and the home folder are omitted.
if ! xcrun --find swift > /dev/null 2>&1; then
  echo 'Swift is required; install the Xcode Command Line Tools first.' >&2
  exit 1
fi
xcrun swift "$script_dir/finder-sidebar.swift" \
  "$HOME/Downloads" \
  "$HOME/Developer" \
  "$HOME/Documents" \
  '/Applications'

# Hide iCloud Drive in the sidebar without disabling iCloud Drive itself.
defaults write com.apple.finder SidebarShowingSignedIntoiCloud -bool false

killall sharedfilelistd 2> /dev/null || true
killall Finder 2> /dev/null || true
echo 'Done. Finder settings applied.'
