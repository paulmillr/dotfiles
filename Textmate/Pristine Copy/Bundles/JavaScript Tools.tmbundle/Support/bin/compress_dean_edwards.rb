require 'ftools'
require "#{ENV['TM_BUNDLE_SUPPORT']}/bin/packr-1.0.2/lib/packr.rb"

File::copy("#{ENV['TM_FILEPATH']}", '/tmp/compress_this_file.js')
Packr.pack_file('/tmp/compress_this_file.js', :shrink_vars => true, :base62 => !ENV['TM_JST_PB62'].nil?)
packed = File::read('/tmp/compress_this_file.js')
puts packed