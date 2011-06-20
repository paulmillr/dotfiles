require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"

# Load TM preferences to discover the current font settings
# Taken from doc2html by Brad Choate -- http://bradchoate.com/
textmate_pref_file = '~/Library/Preferences/com.macromates.textmate.plist'
$prefs = OSX::PropertyList.load(File.open(File.expand_path(textmate_pref_file)))
 
def getfontname
  font_name = $prefs['OakTextViewNormalFontName'] || 'Monaco'
  font_name = '"' + font_name + '"' if font_name.include?(' ') && !font_name.include?('"')
  return font_name
end

def getfontsize
  font_size = ($prefs['OakTextViewNormalFontSize'] || 11).to_s
	font_size.sub!(/\.\d+$/, '')
end