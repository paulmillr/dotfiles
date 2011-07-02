#!/usr/bin/env ruby
FILENAME = ENV['TM_FILENAME']
FILEPATH = ENV['TM_FILEPATH']
SUPPORT  = ENV['TM_BUNDLE_SUPPORT']
BINARY   = "#{SUPPORT}/bin/jsl"
# BINARY   = `uname -a` =~ /i386/ ? "#{SUPPORT}/bin/intel/jsl" : "#{SUPPORT}/bin/ppc/jsl"

output = `"#{BINARY}" -process "#{FILEPATH}" -nologo -conf "#{SUPPORT}/conf/jsl.textmate.conf"`

# the "X error(s), Y warning(s)" line will always be at the end
results = output.split(/\n/).pop
puts results unless results == "0 error(s), 0 warning(s)"
