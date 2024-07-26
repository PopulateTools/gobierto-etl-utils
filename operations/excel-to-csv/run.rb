#!/usr/bin/env ruby

require 'roo'
require 'roo-xls'


# Usage:
#
#  - Must be ran as an independent Ruby script
#  - Converts a Excel XLSX file to CSV using gnumeric ssconvert
#
# Arguments:
#
#  - 0: Name of the input file
#  - 1: Name of the output file
#
# Samples:
#
#   /path/to/project/operations/excel-to-csv/run.rb /tmp/dataset.xlsx /tmp/dataset.csv
#

if ARGV.length != 2
  raise "Review the arguments. Usage: ruby operations/excel-to-csv/run.rb /tmp/dataset.xlsx /tmp/dataset.csv"
end

input_file, output_file = ARGV

unless File.file?(input_file)
  raise "[ERROR] File #{input_file} doesn't exist"
end

puts "[START] excel-to-csv/run.rb #{input_file} to #{output_file}"

begin
  xlsx = Roo::Excelx.new(input_file)
  csv = xlsx.to_csv
rescue TypeError
  xls = Roo::Excel.new(input_file)
  csv = xls.to_csv
ensure
  File.write(output_file, csv)
end

puts "[END] excel-to-csv/run.rb"
