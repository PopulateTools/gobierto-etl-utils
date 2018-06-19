#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Input file
#  - 1: Output file
#
# Samples:
#
#   /path/to/project/operations/convert-to-utf8/run.rb input_file output_file
#

if ARGV.length != 2
  raise "Review the arguments"
end

input_file = ARGV[0]
output_file = ARGV[1]

puts "[START] convert-to-utf8/run.rb input_file=#{input_file} output_file=#{output_file}"

if File.dirname(output_file) != "."
  FileUtils.mkdir_p(File.dirname(output_file))
end

`iconv -f iso-8859-15 -t utf-8 #{input_file} > #{output_file}`

puts "[END] convert-to-utf8/run.rb"
