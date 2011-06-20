#!/bin/sh
#
osascript << END
tell application "Terminal"
  activate
	if (count of windows) is 0 then
		do script "$CMD"
	else
    tell application "System Events"
      keystroke "t" using {command down}
    end
    delay 1
    do script "$CMD" in window 1
	end if
end tell
END