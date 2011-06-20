
# Includes
support = ENV['TM_SUPPORT_PATH']
bundle	= ENV['TM_BUNDLE_SUPPORT']
require support + "/lib/shelltokenize.rb"
require support + "/lib/escape.rb"
require bundle + "/lib/Builder.rb"
require bundle + "/hg_helper.rb"
require "cgi"
include HGHelper

# Arguments

work_path			= ENV['WorkPath']
work_paths		= TextMate.selected_paths_array
ignore_file_pattern = /(\/.*)*(\/\..*|\.(tmproj|orig|pyc)|Icon)/

input = STDIN.read

if input.length < 1
  make_head( "Hg Status", work_path,
           [ bundle+"/Stylesheets/hg_style.css",
             bundle+"/Stylesheets/hg_status_style.css"] )
  puts "<p>File(s) not modified</p>"
  make_foot
  exit 0
end


# First escape for use in the shell, then escape for use in a JS string
def e_sh_js(str)
  (e_sh str).gsub("\\", "\\\\\\\\")
end

def shorten_path(path)
	prefix = ENV['WorkPath']
	if prefix.nil?
		work_paths = TextMate.selected_paths_array
		prefix = work_paths.first unless work_paths.nil? || work_paths.size != 1
	end

	if prefix && prefix == path
		File.basename(path)
	elsif prefix
		File.expand_path(path).gsub(/#{Regexp.escape prefix}\//, '')
	else
		File.expand_path(path).gsub(/#{Regexp.escape File.expand_path('~')}/, '~')
	end
end

rescan_project = %Q|osascript &>/dev/null -e 'tell app "SystemUIServer" to activate' -e 'tell app "TextMate" to activate'|
hg = ENV['TM_HG'] || 'hg'
hg = `which hg`.chomp unless hg[0] == ?/

display_title = work_paths[0] if work_path.nil? and (not work_paths.nil?) and (work_paths.size == 1)
display_title ||= '(selected files)'

#
# Status or update?
#
$is_status		= false
$is_checkout	= false
command_name	= 'update'

ARGV.each do |arg|
	case arg
	when '--status'
		$is_status = true
		command_name = 'status'
	when '--checkout'
		$is_checkout = true
		command_name = 'checkout'
	end
end

mup = Builder::XmlMarkup.new(:target => STDOUT)

class << mup
	
	StatusColumnNames = ['File', 'Property', 'Lock', 'History', 'Switched', 'Repository Lock']
	
	StatusMap = {	'A' => 'added',
					'R' => 'deleted',
					'G' => 'merged',
					'U' => 'updated',
					'M' => 'modified',
					'L' => 'locked',
					'B' => 'broken',
					'R' => 'deleted',
					'C' => 'conflict',
					'!' => 'missing',
					'+' => 'added',
					'"' => 'typeconflict',
					'?' => 'unknown',
					'I' => 'ignored',
					'X' => 'external',
					' ' => 'none'}
	
	# this may be more dynamic in the future
	# it also possibly should not be stashed in mup
	def status_column_count
		1
	end
	
	def status_colspan
		$is_status ? (status_column_count + 5) : (status_column_count + 1)
	end
	
	def status_map(status)
		StatusMap[status]
	end
	
	def td_status!(status,id)
		status_column_count.times do |i|
			
			c = status[i].chr
			status_class = StatusMap[c] || 'dunno'
			td(c, "class" => "status_col #{status_class}", "title" => StatusColumnNames[i] + " " + status_class.capitalize, :id => "status#{id}")
		end
	end
	
	def button_td!(show, name, onclick)
		lowercase_name = name.downcase
		col_class_name		= lowercase_name + '_col'
		button_class_name	= lowercase_name + '_button'
		td(:class => col_class_name) {
			if show
				a( name, "href" => '#', "class" => button_class_name, "onclick" => onclick )
			end
		}
	end
end


js_functions = <<ENDJS #javascript

			\n<script type="text/javascript">
//<![CDATA[		
				
					the_filename    = null;
					the_id          = null;
					the_displayname = null;
					the_new_status  = null;
					
					function display_tail(id, className, string){
						
						if(string != null && string != '')
						{
							string += " \\n";
							document.getElementById('commandOutput').innerHTML += string;
						}
					}
					
					function HGCommand(cmd, id, statusString, className){
						results        = TextMate.system(cmd, null)
						
						outputString   = results.outputString;
						// errorString = results.errorString;
						errorCode      = results.status;
						// TM doesn't receive the error stream unless output and error are the same descriptor?
						// display_tail('error', 'error', errorString);
						display_tail('info', 'info', outputString);
						
						if(errorCode == 0)
						{
							document.getElementById('status'+id).innerHTML = statusString;
							document.getElementById('status'+id).className = 'status_col ' + className;
						}
					}
					
					hg_commit = function(){
						TextMate.isBusy = true;
						cmd = 'cd #{e_sh_js work_path};';
						#{ %{cmd += "export            TM_HG=#{ e_sh_js ENV['TM_HG']            };";} if ENV['TM_HG']            }
						#{ %{cmd += "export TM_BUNDLE_SUPPORT=#{ e_sh_js ENV['TM_BUNDLE_SUPPORT'] };";} if ENV['TM_BUNDLE_SUPPORT'] }
						#{ %{cmd += "export   TM_SUPPORT_PATH=#{ e_sh_js ENV['TM_SUPPORT_PATH']   };";} if ENV['TM_SUPPORT_PATH']   }
						#{ %{cmd += "export      CommitWindow=#{ e_sh_js ENV['CommitWindow']      };";} if ENV['CommitWindow']      }
						#{ %{cmd += "export   TM_HG_DIFF_CMD=#{ e_sh_js ENV['TM_HG_DIFF_CMD']   };";} if ENV['TM_HG_DIFF_CMD']   }
						#{ %{cmd += "export   TM_HG_FROM_STATUS=true;";}   }
						
						cmd += 'ruby -- #{e_sh_js ENV['TM_BUNDLE_SUPPORT']}/hg_commit.rb'
						document.getElementById('commandOutput').innerHTML = TextMate.system(cmd, null).outputString + ' \\n'
						
						TextMate.isBusy = false;
					};
					// the filename passed in to the following functions is already properly shell escaped
               diff_to_mate = function(filename,id){
                  TextMate.isBusy = true;
                  tmp = '/tmp/hg_diff_to_mate' + id + '.diff'
                  cmd = 'cd #{e_sh_js work_path};#{e_sh_js hg} 2>&1 diff ' + filename + ' >' + tmp + ' && open -a TextMate ' + tmp
                  document.getElementById('commandOutput').innerHTML += TextMate.system(cmd, null).outputString + ' \\n'
                  TextMate.isBusy = false;
               };
               extdiff_to_mate = function(filename,difftool){
                  TextMate.isBusy = true;
                  cmd = 'cd #{e_sh_js work_path};#{e_sh_js hg} 2>&1 ' + difftool + ' ' + filename
                  document.getElementById('commandOutput').innerHTML += TextMate.system(cmd, null).outputString + ' \\n'
                  TextMate.isBusy = false;
               };
					hg_add = function(filename,id){
						TextMate.isBusy = true;
						
						cmd = 'cd #{e_sh_js work_path};#{e_sh_js hg} add ' + filename + ' 2>&1'
						HGCommand(cmd, id, 'A', '#{mup.status_map('A')}')
						
						TextMate.isBusy = false;
					};
					hg_revert = function(filename,id, newstat){
						TextMate.isBusy = true;
						cmd = 'cd #{e_sh_js work_path};#{e_sh_js hg} 2>&1 revert ' + filename;
						HGCommand(cmd, id, '?', '#{mup.status_map('?')}')
						
						TextMate.isBusy = false;
					};
					hg_revert_modified = function(filename,id, newstat){
						TextMate.isBusy = true;
						cmd = 'cd #{e_sh_js work_path};#{e_sh_js hg} 2>&1 revert ' + filename;
						HGCommand(cmd, id, ' ', '#{mup.status_map(' ')}')
						
						TextMate.isBusy = false;
					};
					hg_revert_confirm = function(filename,id,displayname){
						the_filename    = filename;
						the_id          = id;
						the_displayname = displayname;
						the_new_status  = '-';
						TextMate.isBusy = true;
						cmd = 'cd #{e_sh_js work_path};#{e_sh_js ENV['TM_BUNDLE_SUPPORT']}/revert_file.rb -hg=#{e_sh_js hg} -path=' + filename + ' -displayname=' + displayname;
						myCommand = TextMate.system(cmd, function (task) { });
						myCommand.onreadoutput = hg_output;
					};
					hg_remove = function(filename,id,displayname){
						the_filename    = filename;
						the_id          = id;
						the_displayname = displayname;
						the_new_status  = 'R';
						TextMate.isBusy = true;
						cmd = '#{e_sh_js ENV['TM_BUNDLE_SUPPORT']}/remove_file.rb -hg=#{e_sh_js hg} -path=' + filename + ' -displayname=' + displayname;
						myCommand = TextMate.system(cmd, function (task) { });
						myCommand.onreadoutput = hg_output;
					};
					hg_output = function(str){
						display_tail('info', 'info', str);
						document.getElementById('status'+the_id).innerHTML = the_new_status;
						if(the_new_status == '-'){document.getElementById('status'+the_id).className = 'status_col #{mup.status_map('-')}'};
						if(the_new_status == 'R'){document.getElementById('status'+the_id).className = 'status_col #{mup.status_map('R')}'};
						TextMate.isBusy = false;
						the_filename    = null;
						the_id          = null;
						the_displayname = null;
						the_new_status  = null;
					};
					finder_open = function(filename,id){
						TextMate.isBusy = true;
						cmd = "open 2>&1 " + filename;
						output = TextMate.system(cmd, null).outputString;
						display_tail('info', 'info', output);
						TextMate.isBusy = false;
					};
//]]>					
				</script>

ENDJS

make_head( "Hg Status", work_path,
           [ bundle+"/Stylesheets/hg_style.css",
             bundle+"/Stylesheets/hg_status_style.css"], js_functions )

		STDOUT.flush
		
		mup.div( "class" => "section" ) do
			mup.table("class" => "status") {
			
				match_columns       = '.' * mup.status_column_count
				unknown_file_status = '?' + (' ' * (mup.status_column_count - 1))
				missing_file_status = '!' + (' ' * (mup.status_column_count - 1))
				added_file_status   = 'A' + (' ' * (mup.status_column_count - 1))
				removed_file_status   = 'R' + (' ' * (mup.status_column_count - 1))
			
				stdin_line_count = 1
				input.each_line do |line|
				
					# ignore lines consisting only of whitespace
					next if line.squeeze.strip.empty?
					# build the row
					mup.tr {
						if /^hg:/.match( line ).nil? then
							match = /^(.)(?:\s+)(.*)\n/.match( line )
							if match.nil? then
								# Informational text, not status
								mup.td(:colspan => (mup.status_colspan).to_s ) do
									mup.div(:class => 'info') { mup.text(line) }
								end
							else
								status          = match[1]
								file            = work_path + "/" + match[2]
								esc_file        = '&quot;' + CGI.escapeHTML(e_sh_js(file).gsub(/(?=")/, '\\')) + '&quot;'
								esc_displayname = '&quot;' + CGI.escapeHTML(e_sh_js(shorten_path(file)).gsub(/(?=")/, '\\')) + '&quot;'

								# Skip files that we don't want to know about
								next if (status == unknown_file_status and ignore_file_pattern =~ file)
								
								# Status string
								mup.td_status!(status, stdin_line_count)
								
								# Add, Revert, etc buttons
								if $is_status
									# ADD Column 
									mup.button_td!((status == unknown_file_status),
													'Add',
													"hg_add(#{esc_file},#{stdin_line_count}); return false")

									# REVERT Column 
									if status == added_file_status
									  newstat = '?'
								  else
								    newstat = ' '
							    end
									mup.button_td!((status != unknown_file_status),
													'Revert',
													"hg_revert#{"_confirm" unless status == added_file_status}(#{esc_file},#{stdin_line_count},#{esc_displayname}); return false")
													
									# REMOVE Column 
									mup.button_td!((status == missing_file_status),
													'Remove',
													"hg_remove(#{esc_file},#{stdin_line_count},#{esc_displayname}); return false")

									# DIFF Column
									if file.match(/\.(png|gif|jpe?g|psd|tif?f|zip|rar)$/i)
										onclick        = "finder_open(#{esc_file},#{stdin_line_count}); return false"
										column_is_an_image = true
									else
										onclick        = ""
										# Diff Column (only available for text)
										column_is_an_image = false
									end
                           if ENV['TM_HG_EXT_DIFF']
                              mup.button_td!( ((not column_is_an_image) and (status != unknown_file_status)),
													'Diff',
													"extdiff_to_mate(#{esc_file},&quot;#{ENV['TM_HG_EXT_DIFF']}&quot;); return false")
									else
									   mup.button_td!( ((not column_is_an_image) and (status != unknown_file_status)),
													'Diff',
													"diff_to_mate(#{esc_file},#{stdin_line_count}); return false")
									end
								end

								# FILE Column
								mup.td(:class => 'file_col') {
								  if status == removed_file_status
										mup << shorten_path(file)
									else
									  mup.a( shorten_path(file), "href" => 'txmt://open?url=file://' + (e_url file), "class" => "pathname", "onclick" => onclick )
									end
								}
							end 
						else
							mup.td { mup.div( line, "class" => "error" ) }
						end
					}
					mup << "\n"
					stdin_line_count += 1
				end
			}
		end
		
# CHANGED: Figured out how to make commit work in status window
		if $is_status then
			mup.div(:id => 'actions'){
				mup.input(:type => 'button', :value => 'Commit', :onclick => 'hg_commit(); return false', :style => 'margin:10px 0;')
				mup.div(:style => 'clear:both'){}
			}
		end
		
		mup.div(:id => 'commandOutput'){
			mup << " "
		}
make_foot()