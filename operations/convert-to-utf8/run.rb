#!/usr/bin/env ruby
# frozen_string_literal: true

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

def osx?
  RbConfig::CONFIG["host_vendor"].downcase.include?("apple")
end

def detect_charset(file_path)
  arg = osx? ? "I" : "i"

  result = `file -#{arg} #{file_path}`
  result.strip.split("charset=").last
rescue StandardError => e
  raise "Can't determine charset of #{file_path}. Error: #{e.message}"
end

def utf8?(charset)
  charset.downcase.gsub(/[^0-9a-z]/, "") == "utf8"
end

if ARGV.length != 2
  raise "Review the arguments"
end

input_file = ARGV[0]
output_file = ARGV[1]

puts "[START] convert-to-utf8/run.rb input_file=#{input_file} output_file=#{output_file}"

if File.dirname(output_file) != "."
  FileUtils.mkdir_p(File.dirname(output_file))
end

charset = detect_charset(input_file)

if utf8?(charset)
  puts "Already in utf-8: #{input_file}"
  FileUtils.cp(input_file, output_file)
else
  puts "Converting #{input_file} from #{charset} to utf-8"
  `iconv -f #{charset} -t utf-8 #{input_file} > #{output_file}`
end

puts "[END] convert-to-utf8/run.rb"
