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

status = :success
separator = ","

begin
  CSV.read(input_file, col_sep: separator, encoding: 'utf-8')
rescue => e
  status = :error_reading_comma_separated
end

if status == :error_reading_comma_separated
  separator = ";"
  begin
    CSV.read(input_file, col_sep: separator, encoding: 'utf-8')
    status = :success
  rescue StandardError => e
    puts "Error: #{e.message}"
    status = :error_reading_semicolon_separated
  end
end

if status == :success
  if CSV.table(input_file, col_sep: separator, encoding: 'utf-8').count < 2
    puts "[ERROR] the CSV file has no content"
    exit(-1)
  end
end

unless status == :success
  puts "[ERROR] Invalid CSV format #{status}"
  exit(-1)
end

puts "[END] check-csv/run.rb"
