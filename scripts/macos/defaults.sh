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

########## NON-FINDER ##########
# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Hide indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Hot corners: Bottom right screen corner → Lock screen
defaults write com.apple.dock wvous-br-corner -int 13
defaults write com.apple.dock wvous-br-modifier -int 0
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Terminal: Enable Secure Keyboard Entry
defaults write com.apple.terminal SecureKeyboardEntry -bool true

for app in cfprefsd Dock Finder SystemUIServer; do
  killall "$app" 2> /dev/null || true
done
echo 'Done. Settings applied.'
