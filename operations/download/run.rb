#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "fileutils"
require "open-uri"
require "net/http"
require "net/https"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: URL to download the content
#  - 1: Output file
#  - 2: --compatible
#
# Samples:
#
#   /path/to/project/operations/download/run.rb "http://input.json" /tmp/output.json
#

if ARGV.length < 2 || ARGV.length > 3
  raise "Review the arguments"
end

url = ARGV[0]
destination_file_name = ARGV[1]
compatible_mode = ARGV[2]

puts "[START] download/run.rb from #{url} to #{destination_file_name} #{compatible_mode ? " using compatible mode" : ""}"

command = "wget -O #{destination_file_name}"
command += " --no-check-certificate" if compatible_mode
command += " #{url}"

puts command
system(command)

puts "[END] download/run.rb"
