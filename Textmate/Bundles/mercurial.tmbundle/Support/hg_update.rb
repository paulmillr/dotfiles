$bundle        = ENV['TM_BUNDLE_SUPPORT']
work_path		= ENV['WorkPath']

require $bundle+'/hg_helper.rb'
include HGHelper

begin
   update = %x{hg update -v 2>&1}
   
   make_head( 'Hg Update', 'work_path',
              [ $bundle+'/Stylesheets/hg_style.css',
                $bundle+'/Stylesheets/hg_log_style.css'] )
                
  lines = update.split( "\n" )
  puts "<p><strong>" + lines[0] + "</strong></p>"
  puts "<ul>"
  lines[1].split( "," ).each do |files|
     puts "<li>" + files + "</li>"
  end
  puts "<ul>"

ensure
   make_foot()
end

