#!/usr/bin/env ruby
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'

FILENAME = ENV['TM_FILENAME']
$FILEPATH = ENV['TM_FILEPATH'] || '/tmp/compress_this_file.js'
$SUPPORT  = ENV['TM_BUNDLE_SUPPORT']
# You'll need to set this path manually to run the unit tests
# $SUPPORT  = "#{ENV['HOME']}/Library/Application Support/TextMate/Bundles/JavaScript Tools.tmbundle/Support"
# $BINARY   = "#{$SUPPORT}/bin/jsl"
# $BINARY   = `uname -a` =~ /i386/ ? "#{$SUPPORT}/bin/intel/jsl" : "#{$SUPPORT}/bin/ppc/jsl"

def lint!(javascript,offset_line=0,offset_column=0)
  $BINARY   = "java -jar '#{$SUPPORT}/bin/compiler.jar' --warning_level VERBOSE"
# output = `"#{$BINARY}" -process "#{$FILEPATH}" -nologo -conf "#{$SUPPORT}/conf/jsl.textmate.conf"`

File.open($FILEPATH,'w'){|file| file.write(javascript)}

output = `#{$BINARY} --js "#$FILEPATH" 2>&1`

output.gsub!('lint warning:', '<span class="warning">Warning:</span>')
output.gsub!('SyntaxError:', '<span class="error">Syntax Error:</span>')
output.gsub!('Error:', '<span class="error">Error:</span>')
# output.gsub!(FILENAME, '') if FILENAME



output  = output.gsub('&','&amp;').gsub('<','&lt;').split(/\n/)
# the "X error(s), Y warning(s)" line will always be at the end
results = output.grep(/\d+ warning\(s\)/).to_s

# output.unshift('<pre>')
# output << '</pre>'
output  = output.join("\n")

output  = output.split(/\n\n/)
output.pop

output.map! do |chunk|
  chunk.gsub!(/(#{Regexp.escape $FILEPATH}):(\d+):/, %{<a href="txmt://open?url=file://\\1&line=\\2">Go to line</a><br />\n})
  
  "<li><pre>#{chunk}</pre></li>"
end
output.unshift('<ol>')
output << '</ol>'
output  = output.join("\n")

=begin

output  = output.split(/\n\n/)
output  = output.map do |chunk|
  chunk.strip!
  next if chunk.length == 0
  lines = chunk.split(/\n/)
  j = 0
  lines = lines.map do |line|
    if line =~ /^(\d+):/
      lines[j+1] ||= ''
      tab_count = lines[j+1].scan("\t").length rescue 0
      
      lines[j+1].gsub!("\t", (' ' * ENV['TM_TAB_SIZE'].to_i))
      tab_count.times do
        lines[j+2].sub!(('.' * 8), '.' + (' ' * (ENV['TM_TAB_SIZE'].to_i - 1)) )
      end
      
      linenum = line.scan(/^(\d+):/).first.first
      linenum = linenum.to_i + offset_line rescue 1
      
      column = lines[j+2].gsub(' ','').rindex("^") rescue 1
      column = column.to_i + 1 + offset_column rescue 1
      
      # print '<pre>'
      # puts line
      # puts lines[j+1]
      # puts lines[j+2]
      # print '</pre>'
      
      # line.gsub!(/^(\d+):/, %{<a href="txmt://open?url=file://#{e_url $FILEPATH}&line=#{linenum}&column=#{column}">\\1</a>})
      line.sub!(/^/, %{<a href="txmt://open?url=file://#{e_url $FILEPATH}&line=#{linenum}&column=#{column}">})
      line.sub!(/$/, %{</a>})
    end
    j += 1
    line
  end
  
  # don't do the transformation on an empty string
  if (chunk.length > 0)
    chunk = "<li>#{lines[0]}<pre><code>#{lines[1]}\n#{lines[2]}</code></pre></li>"
  end
  chunk
end
output = output.join("\n\n")
=end
html = <<-HTML
<html>
  <head>
    <title>JavaScript Lint Results</title>
    <style type="text/css">
      body {
        font-size: 13px;
      }
      
      pre {
        background-color: #eee;
        color: #400;
        margin: 3px 0;
      }
      
      h1, h2 { margin: 0 0 5px; }
      
      h1 { font-size: 20px; }
      h2 { font-size: 16px;}
      
      span.warning {
        color: #c90;
        text-transform: uppercase;
        font-weight: bold;
      }
      
      span.error {
        color: #900;
        text-transform: uppercase;
        font-weight: bold;
      }
      
      ul {
        margin: 10px 0 0 20px;
        padding: 0;
      }
      
      li {
        margin: 0 0 10px;
      }
    </style>
  </head>
  <body>
    <h1>JavaScript Lint</h1>
    <h2>#{results}</h2>
    
    <ul>
      #{output}
    </ul>
  </body>
</html>  
HTML

html
end

if __FILE__ == $0

def has_selection?
  !!ENV['TM_SELECTED_TEXT']
end

def start_line
  # return (ENV['TM_INPUT_START_LINE'] || 1).to_i - 1
  
  $file ||= (File.read($FILEPATH))
  $file[0..$file.index($INPUT)].scan("\n").length rescue 0 #- (has_selection? ? 1 : 0)
  # $file[0..$file.index($INPUT)].scan("\n").length # correct for embedded javascript in html and selected js in html
end

def start_column
  # ENV['TM_INPUT_START_COLUMN'].to_i - (has_selection? ? 1 : 0)
  $file ||= (File.read($FILEPATH))
  $file[0..$file.index($INPUT)].split("\n").last.length - 1 rescue 0 #- (has_selection? ? 1 : 0)
  # $file[0..$file.index($INPUT)].split("\n").last.length - 1 # correct for embedded javascript in html and selected js in html
end

if ENV['TM_SCOPE'] =~ /source\.js/
  $INPUT = (STDIN.read)
  # p start_line
  # p start_column
  puts lint!($INPUT, start_line, start_column)
else
  $SUPPORT = File.expand_path(File.dirname(__FILE__ + '/../../../'))
  require "test/unit"
  class TestLint < Test::Unit::TestCase
    def test_basic
      js = 'var a=1+1;'
      result = lint!(js)
      assert result.include?('0 error(s), 0 warning(s)'), result
    end
    def test_basic_error
      js = '"'
      result = lint!(js)
      assert result.include?('1 error(s), 0 warning(s)'), result
      assert result.include?('&line=1&column=1'), result
    end
    def test_offset
      js = '"'
      result = lint!(js, 100)
      assert result.include?('1 error(s), 0 warning(s)'), result
      assert result.include?('&line=101&column=1'), result
    end
    def test_offset2
      js = "{'singleQuotedString': null}"
      result = lint!(js, 100, 100)
      assert result.include?('1 error(s), 0 warning(s)'), result
      assert result.include?('&line=101&column=122'), result
    end
  end
end #TESTING

end #if
