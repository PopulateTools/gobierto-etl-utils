#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "json"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Input JSON file
#
# Samples:
#
#   /path/to/project/operations/check-json/run.rb input.json
#

if ARGV.length != 1
  raise "Review the arguments"
end

input_file = ARGV[0]

puts "[START] check-json/run.rb for file #{input_file}"

unless File.file?(input_file)
  raise "File #{input_file} doesn't exist"
end

if File.size(input_file) == 0
  raise "File #{input_file} is empty"
end

begin
  JSON.parse(File.read(input_file))
rescue
  puts "[ERROR] Invalid JSON format"
  exit(-1)
end

puts "[END] check-json/run.rb"
