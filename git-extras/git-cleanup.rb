#!/usr/bin/env ruby

# git-cleanup
# ===========

# Script for removing unused local & remote git branches.
# Helps a lot of you use topic branches and GitHub pull requests.
#
# Usage:
#
#     # <switch to master branch>
#     git cleanup
#
# (c) 2012 Paul Miller (paulmillr.com), Mathias Schäfer, moviepilot.com.
# The script can be redistributed under the MIT License.

# CONFIG
UNTOUCHABLES = %w[master staging]
REQUIRED_BRANCH = 'master'

class BranchList < Array
  def self.from_command(command)
    branch_list = self.new
    command_result = `#{command}`
    command_result.each_line do |result_line|
      # Ignore references
      next if result_line.include? '->'
      # Add cleaned up branch name
      branch_list << result_line.chomp.gsub(/[*\s]/, '')
    end

    branch_list
  end

  def initialize(list = [])
    self.concat list
  end

  def without(list)
    self.class.new(self.reject { |branch| list.include? branch })
  end

  def local_names
    self.class.new(self.map { |branch| branch.gsub(/origin\//, '') })
  end

  def to_list(indent = 0)
    self.map { |branch| (' ' * indent) << branch }.join "\n"
  end
end

def get_current_branch
  branches = `git branch --no-color 2> /dev/null`
  branches.each_line do |branch|
    return $1 if branch =~ /^\*\s*(.+)/
  end
end

def cleanup
  current_branch = get_current_branch
  if current_branch != REQUIRED_BRANCH
    abort "Aborting: You should run this while in `#{REQUIRED_BRANCH}`."
  end
  puts 'Fetching merged branches ...'
  `git remote prune origin`
  remote_branches = BranchList.from_command('git branch -r --merged').local_names.without UNTOUCHABLES
  local_branches  = BranchList.from_command('git branch --merged').without UNTOUCHABLES

  if local_branches.empty? && remote_branches.empty?
    puts 'Nothing to do.'
    exit
  end

  puts 'The following remote branches will be removed:'
  puts remote_branches.to_list 2
  puts 'The following local branches will be removed:'
  puts local_branches.to_list 2

  print "\nProceed (y/n) "
  proceed = STDIN.gets.downcase.chomp

  if proceed == 'y'
    `git push origin #{remote_branches.map { |branch | ':' << branch }.join ' '}`
    `git branch -d #{local_branches.join ' '}`
    puts 'Done.'
  else
    puts 'No action taken.'
  end
end

cleanup
