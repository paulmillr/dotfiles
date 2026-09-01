#!/bin/sh
set -eu

PATH='/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

if [ "$(uname -s)" != 'Darwin' ]; then
  echo "This script is only intended for macOS systems." >&2
  exit 1
fi

# System Settings > Spotlight
# EnabledPreferenceRules contains the result providers that are turned off.
defaults write com.apple.Spotlight EnabledPreferenceRules -array \
  'Custom.relatedContents' \
  'com.apple.AppStore' \
  'com.apple.iCal' \
  'com.apple.mail' \
  'com.apple.Notes' \
  'com.apple.Photos' \
  'com.apple.podcasts' \
  'com.apple.reminders' \
  'com.apple.Safari' \
  'com.apple.shortcuts' \
  'com.apple.tips' \
  'com.apple.VoiceMemos' \
  'System.iphoneApps'

# 2 is Apple's explicit opt-out state for sharing search queries.
defaults write com.apple.assistant.support \
  'Search Queries Data Sharing Status' -int 2

# System Settings > Lock Screen
sudo -v
sudo pmset -b displaysleep 1
sudo pmset -c displaysleep 5

# sysadminctl stores this setting securely and prompts for the current user's
# login password. Passing the password as an argument would expose it.
sysadminctl -screenLock immediate -password -

killall Spotlight 2> /dev/null || true
echo 'Done. Spotlight, display sleep, and immediate password settings applied.'
