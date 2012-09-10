# echo 'Disabling useless Safari page previews...'
# defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
# echo 'Disabling warning dialogue on downloaded applications...'
# defaults write com.apple.LaunchServices LSQuarantine -bool NO
echo 'Changing default screenshot location to ~/Downloads/...'
defaults write com.apple.screencapture location ~/Downloads/
killall SystemUIServer
