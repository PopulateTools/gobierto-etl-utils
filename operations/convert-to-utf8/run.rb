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
#  - 2: (Optional) Input file encoding. Used as fallback if autodetect fails.
#
# Samples:
#
#   /path/to/project/operations/convert-to-utf8/run.rb input_file output_file
#

class EncodingUtils
  def self.detect_charset(file_path, fallback_charset = nil)
    arg = osx? ? "I" : "i"

    result = `file -#{arg} #{file_path}`

    charset = result.strip.split("charset=").last

    if unknown_charset?(charset)
      fallback_charset || "latin1"
    else
      charset
    end
  rescue StandardError => e
    raise "Can't determine charset of #{file_path}. Error: #{e.message}"
  end

  def self.utf8?(charset)
    charset.downcase.gsub(/[^0-9a-z]/, "") == "utf8"
  end

  ## private

  def self.osx?
    RbConfig::CONFIG["host_vendor"].downcase.include?("apple")
  end
  private_class_method :osx?

  def self.unknown_charset?(charset)
    charset.downcase.include?("unknown")
  end
  private_class_method :unknown_charset?
end

raise "Invalid number of arguments" unless ARGV.length.between?(2, 3)

input_file = ARGV[0]
output_file = ARGV[1]
input_fallback_charset = ARGV[2]

puts "[START] convert-to-utf8/run.rb input_file=#{input_file} output_file=#{output_file}"

if File.dirname(output_file) != "."
  FileUtils.mkdir_p(File.dirname(output_file))
end

charset = EncodingUtils.detect_charset(input_file, input_fallback_charset)

if EncodingUtils.utf8?(charset)
  puts "Already in utf-8: #{input_file}"
  FileUtils.cp(input_file, output_file)
else
  puts "Converting #{input_file} from #{charset} to utf-8"
  `iconv -f #{charset} -t utf-8 #{input_file} > #{output_file}`
end

puts "[END] convert-to-utf8/run.rb"
