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

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Enforce system hibernation and evict FileVault keys from memory instead of traditional sleep to memory.
sudo pmset -a destroyfvkeyonstandby 1
sudo pmset -a hibernatemode 25 # 25: Force copying RAM to disk always

# Also modify your standby and power nap settings.
# Otherwise, your machine may wake while in standby mode and then
# power off due to the absence of the FileVault key
sudo pmset -a powernap 0
sudo pmset -a standby 0
sudo pmset -a standbydelay 0
sudo pmset -a autopoweroff 0

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write com.apple.AppleMultitouchTrackpad Clicking 1

# Finder: show all filename extensions, disable warnings
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Hide indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Hot corners: Bottom right screen corner → Lock screen
defaults write com.apple.dock wvous-br-corner -int 13
defaults write com.apple.dock wvous-br-modifier -int 0

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Terminal.app
# Enable Secure Keyboard Entry https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true
# Disable the annoying line marks
defaults write com.apple.Terminal ShowLineMarks -int 0

# Mac App Store
# Enable the automatic update check
# Check for software updates daily, not just once per week
# Download newly available updates in background
# Install System data files & security updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 0
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 0
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 0

# Deactivate Apple Intelligence
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"

# Memory management
# =================
# Disable swap file. macOS will crash if mem will exceed max mem.
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
# Enable swap back.
# sudo launchctl load -wF /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist

# Apply
# =====
# Restart affected apps so the settings above take effect.
# Terminal is intentionally not killed; restart it manually.
for app in cfprefsd Dock Finder SystemUIServer; do
  killall "$app" 2> /dev/null || true
done
echo 'Done. Restart Terminal.app manually; some changes need a logout/restart.'
