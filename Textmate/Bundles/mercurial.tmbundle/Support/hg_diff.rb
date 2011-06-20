#!/usr/bin/env ruby -w
# encoding: utf-8

$LOAD_PATH << ENV['TM_SUPPORT_PATH'] + "/lib"
require 'progress'

module Mercurial
   def Mercurial.diff_active_file( revision, command )
      hg             = ENV['TM_HG'] || 'hg'
      target_path    = ENV['TM_SELECTED_FILE'] || ENV['TM_FILEPATH']
      work_path      = ENV['WorkPath']
      path           = target_path.sub(/^#{work_path}\//, '')     
      output_path    = File.basename(target_path) + ".diff"

      TextMate::call_with_progress(:title => command,
                           :message => "Accessing Mercurial Repository…",
                           :output_filepath => output_path) do

         revs = revision.gsub( '-r', '' ).split( ' ' )
         
         
         the_diff = %x{cd "#{work_path}";"#{hg}" diff #{revision} "#{target_path}"}

         
         unless the_diff.empty?     
            # idea here is to stream the data rather than submit it in one big block
            the_diff.each_line do |line|
               if line =~ /^diff -r (\w+)( -r (\w+))? .*/
                  puts "Index: " + target_path
                  puts "===================================================================\n"
                  
                  if revs[1]
                     puts "diff of revs " + revs[0] + " (#{$1})" + " and " + revs[1] + " (#{$2})" 
                  elsif revs[0] == 'tip'
                     puts "diff with tip (#{$1})"
                  elsif revs.empty?
                     puts "diff with working copy (#{$1})"
                  else
                     puts "diff with revision " + revs[0] + "(#{$1})"
                  end
               elsif line =~ /(^@@\s*.+?\s*@@)(.*)?/
                  puts $1
               else
                  puts line
               end
            end
            return
         else
            # switch to tooltip output to report lack of differences
            puts "No differences found."
            exit 206;
         end
      end
   end
end
