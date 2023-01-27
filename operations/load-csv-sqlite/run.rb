#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "fileutils"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Data file (CSV)
#  - 1: SQlite file path
#  - 2: Record separator
#  - 3: (Optional) Table name (default: data_raw)
#
# Samples:
#
#   /path/to/project/operations/load-csv-sqlite/run.rb /tmp/data_raw.csv /tmp/database.sqlite ','
#

if ARGV.length < 3 || ARGV.length > 4
  raise "Review the arguments"
end

data_path = ARGV[0]
database_path = ARGV[1]
separator = ARGV[2]
raw_table_name = ARGV[3] || "data_raw"

puts "[START] load-csv-sqlite/run.rb load CSV #{data_path} into #{database_path} with separator #{separator} in table #{raw_table_name}"

unless File.file?(data_path)
  puts "[ERROR] #{data_path} doesn't exist"
end

system(
<<-COMMAND
sqlite3 #{database_path} << EOF
.separator "#{separator}"
.import #{data_path} #{raw_table_name}
EOF
COMMAND
      )


puts "[END] load-csv-sqlite/run.rb"
