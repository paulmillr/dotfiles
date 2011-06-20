#!/usr/bin/env ruby -s
# encoding: utf-8

abort "Wrong arguments: use -path=«file to remove»" if $path.nil?

hg     = $hg || 'hg'
path    = $path
display = $displayname || File.basename(path)

res = %x{
  iconv -f utf-8 -t mac <<"AS"|osascript 2>/dev/console
    tell app "TextMate" to display alert "Remove File?" ¬
      message "Do you really want to remove the file “#{display}” from your working copy?" ¬
      buttons { "Cancel", "Remove" } cancel button 1 as warning
    return button returned of result
}

if res =~ /Remove/ then
  ENV['TM_HG_REMOVE'] = path # by using an env. variable we avoid shell escaping
  puts `#{hg} remove "$TM_HG_REMOVE"`
else
	puts "Cancel"
end
