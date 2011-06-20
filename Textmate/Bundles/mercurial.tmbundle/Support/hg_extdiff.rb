#!/usr/bin/env ruby -w

$LOAD_PATH << ENV['TM_SUPPORT_PATH'] + "/lib"

module Mercurial
   def Mercurial.diff_active_file( revision, command )
      hg             = ENV['TM_HG'] || 'hg'
      target_path    = ENV['TM_SELECTED_FILE'] || ENV['TM_FILEPATH']
      work_path      = ENV['WorkPath']
      path           = target_path.sub(/^#{work_path}\//, '')     
      output_path    = File.basename(target_path) + ".diff"
      difftool        = ENV['TM_HG_EXT_DIFF']
      
      the_diff = %x{cd "#{work_path}";"#{hg}" diff #{revision} "#{target_path}"}
      
      if the_diff.empty?
         puts "No differences found."
         exit 206
      else
         %x{cd "#{work_path}";"#{hg}" #{difftool} #{revision} "#{target_path}"}
         exit 206
      end
   end
end
