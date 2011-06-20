# encoding: utf-8

bundle			= ENV['TM_BUNDLE_SUPPORT']
support			= ENV['TM_SUPPORT_PATH']
hg             = ENV['TM_HG'] || 'hg'
work_path      = ENV['WorkPath']

require (support + '/lib/progress')



TextMate::call_with_progress(:title => "Pull from default repos.",
                           :message => "Accessing Parent Repository…",
                           :output_filepath => nil) do

   `cd #{work_path};#{hg} pull`

end

