#!/usr/bin/env ruby

require_relative "../../lib/gobierto_etl_utils"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Input XML file
#
# Samples:
#
#   $DEV_DIR/gobierto-etl-utils/operations/check-xml/run.rb input.xml
#

if ARGV.length != 1
  raise "Review the arguments"
end

input_file = ARGV[0]

puts "[START] check-xml/run.rb for file #{input_file}"

unless File.file?(input_file)
  raise "File #{input_file} doesn't exist"
end

error = false

begin
  xml_content = File.read(input_file)
  doc = Nokogiri::XML(xml_content)
  error = true if doc.errors.any?
rescue
  error = true
end

if error
  puts "[ERROR] Invalid XML format"
  exit(-1)
end

puts "[END] check-xml/run.rb"
