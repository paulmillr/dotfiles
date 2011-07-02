# RSpec support
begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  require 'rspec'
end
begin
  require "rspec/core/rake_task"
rescue LoadError
  puts <<-EOS
  To use rspec for testing you must install rspec gem:
    gem install rspec
  EOS
  exit(0)
end

spec_common = Proc.new do |spec|
  spec.pattern = 'Support/spec/**/*/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
end

task :default => :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec_common.call(spec)
end

namespace :spec do
  desc "Run all specs in spec directory with RCov"
  RSpec::Core::RakeTask.new(:rcov) do |spec|
    spec_common.call(spec)
    spec.rcov = true
    spec.rcov_opts = ['-x', 'Support/spec/', '-T']
  end
end
