#!/usr/bin/env ruby

require_relative "../../lib/gobierto_etl_utils"

# Runs a query into Oracle and returns the result in a CSV
# Assumes exists sqlplus command
#
# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Oracle connection
#  - 1: Query file
#  - 2: Output file
#
# Samples:
#
#   $DEV_DIR/gobierto-etl-utils/operations/run-oracle-query/run.rb "CONNECTION" input.sql $WORKING_DIR/output.csv

if ARGV.length != 3
  raise "Review the arguments"
end

# Check sqlplus
if `which sqlplus` == ""
  raise "SQLPlus not found"
end

connection_string = ARGV[0]
query_filename = ARGV[1]
destination_name = ARGV[2]

puts "[START] run-oracle-query/run.rb from #{query_filename} to #{destination_name}"

query = File.read(query_filename)
file = Tempfile.new("oracle-connection")
file.write "#{connection_string}\nset markup csv on;\n#{query}\n"
file.close

# Run the query and return in the standar output the results
# The first row and the last 3 rows are removed because contain
# metainformation of the query not in CSV format
`cat #{file.path} | sqlplus -S /nolog | sed '1d' | head -n -3 > #{destination_name}`
file.unlink
puts "[END] run-oracle-query/run.rb"
