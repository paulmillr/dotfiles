# just some small methods and some exceptions to help
# with converting some of the hg command outputs to html.
# 
# Based on the svn bundle (copyright 2005 torsten becker <torsten.becker@gmail.com>)
# no warranty, that it doesn't crash your system.
# you are of course free to modify this.

# Needed to easily convert date
require 'parsedate' 
require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview.rb"
# require "/Library/Application Support/TextMate/Bundles/Mercurial.tmbundle/Support/web_preview.rb"


module HGHelper   
   # (log) raised, if the maximum number of log messages is shown.
   class LogLimitReachedException < StandardError; end
   
   # (all) raised if the 'parser' gets a line
   # which doesnt match a certain scheme or wasnt expected
   # in a special state.
   class NoMatchException < StandardError; end
   
   # (all) if we should go in error mode
   class HGErrorException < StandardError; end
   
   
   # makes a txmt-link for the html output, the line arg is optional.
   def make_tm_link( filename, line=nil )
      encoded_file_url = ''
      ('file://'+filename).each_byte do |b|
         if b.chr =~ /\w/
            encoded_file_url << b.chr
         else
            encoded_file_url << sprintf( '%%%02x', b )
         end
      end
      
      'txmt://open?url=' + encoded_file_url + ((line.nil?) ? '' : '&amp;line='+line.to_s)
   end
   
   
   # subsitutes some special chars for showing html..
   def htmlize( string, blow_up_spaces = true, tab_size = $tab_size )
      return string.to_s.gsub( /<|>|&| |\t/ ) do |match|
         case match
            when '<';  '&lt;'
            when '>';  '&gt;'
            when '&';  '&amp;'
            when ' ';  (blow_up_spaces) ? '&zwj;&#32;&zwj;' : ' '
            when "\t"; ((blow_up_spaces) ? '&zwj;&#32;&zwj;' : ' ')*tab_size
            else; raise 'this should never happen!'
         end
      end   
   end
   
   
   # formates you date (input should be a standart hg date)
   # if format is nil it just gives you back the current date
   def formated_date( input, format=$date_format )
      if not format.nil? and not input.nil?
         res = ParseDate.parsedate( input )
         Time.local(*res).strftime( format )
      else
         input
      end
   end
   
   
   # produces a TM header..
   
   def make_head( title='', filename="#{ENV['TM_FILEPATH']}", styles=Array.new, head_adds='' )
      tm_extra_head = ""
      styles.each do |style|
         tm_extra_head << "<link rel=\"stylesheet\" href=\"file://"+style+"\" type=\"text/css\" charset=\"utf-8\" media=\"screen\">\n"
      end
      tm_extra_head += head_adds
#       html_header(title, filename, tm_extra_head)
      puts html_head(:title => title, :sub_title =>filename, :html_head => tm_extra_head)
   end
   
   # .. and this a simple, matching footer ..
   def make_foot( foot_adds='' )
  	puts <<HTML
  	#{foot_adds}
  	</div>
  </body>
  </html>
HTML
   end
   
   
   
   
   # the same as the above 2 methods, just for errors.
   def make_error_head( title='', head_adds='' )
      puts '<div class="error"><h2>'+title+'</h2>'+head_adds
   end
   
   # .. see above.
   def make_error_foot( foot_adds='' )
      puts foot_adds+'</div>'
   end
   
   
   # used to handle the normal exceptions like
   # NoMatchException, HGErrorException and unknown exceptions.
   def handle_default_exceptions( e, stdin=$stdin )
   	case e
   	when NoMatchException
         make_error_head( 'NoMatch' )
         
         puts 'mhh, something with with the regex or hg must be wrong.  this should never happen.<br />'
         puts 'last line: <em>'+htmlize( $! )+'</em><br />please bug-report.'
         
         make_error_foot()
         
      when HGErrorException
         make_error_head( 'HGError', htmlize( $! )+'<br />' )
         stdin.each_line { |line| puts htmlize( line )+'<br />' }
         make_error_foot()
         
      # handle unknown exceptions..
      else
         make_error_head( e.class.to_s )
         
         puts 'reason: <em>'+htmlize( $! )+'</em><br />'
         trace = ''; $@.each { |e| trace+=htmlize('  '+e)+'<br />' }
         puts 'trace: <br />'+trace
         
         make_error_foot()
         
      end #case
      
   end #def handle_default_exceptions
   
end #module HGHelper
