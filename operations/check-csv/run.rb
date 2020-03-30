#!/usr/bin/env ruby

require_relative "../../lib/gobierto_etl_utils"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Input CSV file
#
# Samples:
#
#   $DEV_DIR/gobierto-etl-utils/operations/check-csv/run.rb input.csv
#

if ARGV.length != 1
  raise "Review the arguments"
end

input_file = ARGV[0]

puts "[START] check-csv/run.rb for file #{input_file}"

unless File.file?(input_file)
  raise "File #{input_file} doesn't exist"
end

error = false

begin
  error = false
  CSV.read(input_file, encoding: 'utf-8')
rescue
  error = true
end

if error
  begin
    error = false
    CSV.read(input_file, col_sep: ";", encoding: "utf-8")
  rescue StandardError => e
    puts "Error: #{e.message}"
    error = true
  end
end

if error
  puts "[ERROR] Invalid CSV format"
  exit(-1)
end

puts "[END] check-csv/run.rb"
