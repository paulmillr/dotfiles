$bundle         = ENV['TM_BUNDLE_SUPPORT']
$support        = ENV['TM_SUPPORT_PATH']
$work_path      = ENV['WorkPath'] + "/"
$hg             = ENV['TM_HG'] || `which hg`.chomp

msg_count      = 0      # used to count messages and to show tables in alternate colors

require 'erb'
require $bundle+'/hg_helper.rb'
require $bundle+'/getfontpref.rb'
require $support+'/lib/shelltokenize.rb'
require $support+'/lib/textmate.rb'
include HGHelper
include ERB::Util

$is_ext = false
$window_title = "Hg Log"
$file_paths = if ENV['TM_SELECTED_FILES'].nil?
  ENV['TM_FILEPATH']
elsif TextMate.selected_files[1]
  "Selected Files"
else
  TextMate.selected_files[0].sub($work_path, "")
end

ARGV.each do |arg|
  case arg
  when '--in'
    $is_ext = true
    $window_title = "Hg Incoming"
  when '--out'
    $is_ext = true
    $window_title = "Hg Outgoing"
  end
end


def link_for( path, rev, state )
  result = ''
  revi = (state == "modified") ? rev.to_i : (rev.to_i - 1)

  file = path.gsub(/(.*) \(from .*:\d+\)/, '\1')

  full_url = $work_path + file
  full_url_escaped = full_url.quote_filename_for_shell.gsub('\\','\\\\\\\\').gsub('"', '\\\&#34;').gsub("'", '&#39;')

  filename = file.gsub(%r(.*/(.*?)$), '\1')
  filename_escaped = filename.quote_filename_for_shell.gsub('\\','\\\\\\\\').gsub('"', '\\\&#34;').gsub("'", '&#39;')

  workpath_escaped = $work_path.quote_filename_for_shell.gsub('\\','\\\\\\\\').gsub('"', '\\\&#34;').gsub("'", '&#39;')
  
  if difftool = ENV['TM_HG_EXT_DIFF']
    result = " &nbsp;<small>(<a href=\"#\" onclick=\"javascript:ext_diff('#{workpath_escaped}', '#{$hg}', '#{full_url_escaped}', #{revi},'#{difftool}'); return false;\">Diff With Previous</a>)</small>"
  else
    result = " &nbsp;<small>(<a href=\"#\" onclick=\"javascript:diff_and_open_tm('#{workpath_escaped}', '#{$hg}', '#{full_url_escaped}', #{revi}, '/tmp/#{filename_escaped}.diff'); return false;\">Diff With Previous</a>)</small>"
  end

end

begin
  font = %Q|\n<style type="text/css">\npre { font: 11px #{getfontname}; }\n</style>|
  make_head( $window_title, $file_paths,
  [ $bundle+'/Stylesheets/hg_style.css',
  $bundle+'/Stylesheets/hg_log_style.css'],
  font + "<script type=\"text/javascript\">\n"+
  File.open($bundle+'/log_helper.js', 'r').readlines.join+'</script>' )

  STDOUT.flush

  input = $is_ext ? ( STDIN.read.sub(/(searching for changes)\n(.*)\n/, '<p id="hginfo">\1...<br />\2</p>') ) : STDIN.read


  # hg ouput is formatted with map-log.changelog, then parsed by ERB. Weird but works.
  ERB.new( input ).result( binding ).each_line do |l|
    puts l
  end

rescue => e
  handle_default_exceptions( e )
ensure
  make_foot()
end
