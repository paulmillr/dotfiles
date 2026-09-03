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

# Finder > Settings > General
defaults write com.apple.finder NewWindowTarget -string 'PfDl'

# Finder > Settings > Advanced
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'

# Reload Finder so the Advanced settings take effect before verifying them.
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

# Hide iCloud Drive in the sidebar without disabling iCloud Drive itself.
defaults write com.apple.finder SidebarShowingSignedIntoiCloud -bool false

killall Finder 2> /dev/null || true
echo 'Done. Finder settings applied.'
