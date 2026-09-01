#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  echo 'Run this script as the logged-in user, without sudo.' >&2
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

# Reload Finder before doing the independent sidebar work. This makes the
# Advanced settings apply even if the sidebar helper fails.
killall Finder 2> /dev/null || true

verify_default() {
  preference_domain=$1
  preference_key=$2
  expected_value=$3
  actual_value=$(defaults read "$preference_domain" "$preference_key" 2> /dev/null || true)
  if [ "$actual_value" != "$expected_value" ]; then
    echo "Finder setting was not applied ($preference_key: expected $expected_value, got ${actual_value:-missing})." >&2
    exit 1
  fi
}

verify_default NSGlobalDomain AppleShowAllExtensions 1
verify_default com.apple.finder FXEnableExtensionChangeWarning 0
verify_default com.apple.finder FXEnableRemoveFromICloudDriveWarning 0
verify_default com.apple.finder WarnOnEmptyTrash 0
verify_default com.apple.finder FXRemoveOldTrashItems 1
verify_default com.apple.finder FXDefaultSearchScope SCcf

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
