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
# Close the app first so an open Lock Screen pane cannot write cached values
# back over the power profiles.
killall 'System Settings' 2> /dev/null || true
sudo -v
sudo pmset -b displaysleep 1
sudo pmset -c displaysleep 5
sudo pmset touch

read_display_sleep() {
  power_profile=$1
  pmset -g custom | awk -v wanted="$power_profile" '
    /^Battery Power:/ { current = "battery"; next }
    /^AC Power:/ { current = "charger"; next }
    current == wanted && $1 == "displaysleep" { print $2; exit }
  '
}

battery_display_sleep=$(read_display_sleep battery)
charger_display_sleep=$(read_display_sleep charger)
if [ "$battery_display_sleep" != '1' ] || [ "$charger_display_sleep" != '5' ]; then
  echo "Display sleep was not applied (battery=${battery_display_sleep:-missing}, charger=${charger_display_sleep:-missing})." >&2
  echo "Run 'pmset -g custom' to inspect the active power profiles." >&2
  exit 1
fi

# sysadminctl stores this setting securely and prompts for the current user's
# login password. Passing the password as an argument would expose it.
sysadminctl -screenLock immediate -password -

killall Spotlight 2> /dev/null || true
echo 'Done. Spotlight, display sleep, and immediate password settings applied.'
