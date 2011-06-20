#!/usr/bin/env ruby -s
# encoding: utf-8

abort "Wrong arguments: use -path=«file to revert»" if $path.nil?

hg      = $hg || 'hg'
path    = $path
display = $displayname || File.basename(path)

res = %x{
  iconv -f utf-8 -t mac <<"AS"|osascript 2>/dev/console
    tell app "TextMate" to display alert "Revert File?" ¬
      message "Do you really want to revert the file “#{display}” and lose all local changes?" ¬
      buttons { "Cancel", "Revert" } cancel button 1 as warning
    return button returned of result
}

if res =~ /Revert/i then
  ENV['TM_HG_REVERT'] = path # by using an env. variable we avoid shell escaping
  puts `#{hg} revert "$TM_HG_REVERT"`
else
	puts "Cancel"
end
