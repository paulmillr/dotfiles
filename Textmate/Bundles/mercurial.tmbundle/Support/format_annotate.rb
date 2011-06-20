# just a small to-html formater for what 'hg annotate' gives you.
# made to be compatible with the ruby version included
# in 10.3.7 (1.6.8) but runs also with 1.8
# 
# copyright 2005 torsten becker <torsten.becker@gmail.com>
# no warranty, that it doesn't crash your system.
# you are of course free to modify this.

# so that we can use html_escape()
require "erb"
include ERB::Util

# fetch some tm things..
$full_file     = ENV['TM_FILEPATH']
$current       = ENV['TM_LINE_NUMBER'].to_i
$tab_size      = ENV['TM_TAB_SIZE'].to_i
$bundle        = ENV['TM_BUNDLE_SUPPORT']
$date_format   = ENV['TM_HG_DATE_FORMAT'].nil? ? nil : ENV['TM_HG_DATE_FORMAT']

# find out if the window should get closed on a click
$close = ENV['TM_HG_CLOSE'].nil? ? '' : ENV['TM_HG_CLOSE']
unless $close.empty?
   $close.strip!
   if $close == 'true' or $close == '1'
      $close = ' onClick="window.close();"'
   else
      $close = ''
    end
end


# require the helper, it does some formating, etc:
require $bundle+'/hg_helper.rb'
include HGHelper
require "#{ENV['TM_BUNDLE_SUPPORT']}/getfontpref.rb"


# to show line numbers in output:
linecount = 1


begin
    revision_comment = []
    revision_number = 0
   `"${TM_HG:=hg}" log "$TM_FILEPATH" 2>&1`.each_line do |line|
      if line =~ /^changeset:\s+(\d*):\w+/ then
        revision_number = $1.to_i
        revision_comment[revision_number] = ''
      else
        if !line.empty? then
          revision_comment[revision_number] += line
        end
      end
   end
   
   font = %Q|\n<style type="text/css">\ntd.codecol { font: #{getfontsize}px #{getfontname}; }\n</style>|

   make_head( "Hg Annotate", $full_file,
              [ $bundle+"/Stylesheets/hg_style.css",
                $bundle+"/Stylesheets/hg_annotate_style.css"], font  )

   STDOUT.flush

   puts '<table class="blame"> <tr>' +
            '<th>line</th>' +
            '<th class="revhead">rev</th>' +
            '<th>user</th>' +
            '<th class="codehead">code</th></tr>'
   
   prev_rev = 0
   color = 'color_b'
   
   $stdin.each_line do |line|
      raise HGErrorException, line  if line =~ /^abort:/
      
      # not a perfect pattern, but it works and is short:
      #                user      rev     date                                  text
      if line =~ /^\s*(\w.+) \s*(\d+) (\w{3} \w{3} \d+ \d+:\d+:\d+ \d+ [-+]\d+):(.*)/
         curr_add = ($current == linecount) ? ' current_line' : ''
         line_id = ($current == linecount + 10) ? ' id="current_line"' : ''
         
         revision = $2.to_i
         
         if $2.to_i != prev_rev
          if color == 'color_a'
            color = 'color_b'
          elsif color == 'color_b'
            color = 'color_a'
          end
         end
         puts '<tr class ="' + color + '">'
         puts  '<td class="linecol"><span'+ line_id.to_s + '>'+ linecount.to_s + "</span></td>\n" +
               '<td class="revcol' +curr_add+'" title="' + (revision_comment[revision].nil? ? '' : html_escape(revision_comment[revision]).chomp) + '">' + $2 + "</td>\n" +
               '<td class="namecol'+curr_add+'" title="' + (revision_comment[revision].nil? ? '' :  html_escape(revision_comment[revision]).chomp) + '">' + $1 + "</td>\n" +
               '<td class="codecol'+curr_add+'" title="' + (revision_comment[revision].nil? ? '' :  html_escape(revision_comment[revision]).chomp) + '"><a href="' +
                  make_tm_link( $full_file, linecount) +'"'+$close+'>'+ htmlize( $4 ) +
               "</a></td></tr>\n\n"

         linecount += 1
         
      else
         raise NoMatchException, line
      end
      prev_rev = $2.to_i
   end #each_line

rescue => e
   handle_default_exceptions( e )
ensure
   puts '<script type="text/javascript">window.location.hash = "current_line";</script>'
   make_foot( '</table>' )
end
