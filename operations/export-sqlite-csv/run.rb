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
#  - 0: SQlite file path
#  - 1: Data file (CSV)
#
# Samples:
#
#   /path/to/project/operations/export-sqlite-csv/run.rb /tmp/database.sqlite /tmp/data.csv
#

if ARGV.length < 1 || ARGV.length > 2
  raise "Review the arguments"
end

database_path = ARGV[0]
data_path = ARGV[1]

puts "[START] export-sqlite-csv/run.rb export #{database_path} into #{data_path}"

unless File.file?(database_path)
  puts "[ERROR] #{database_path} doesn't exist"
end

system(<<-COMMAND
echo ".headers on
.mode csv
.output #{data_path}
SELECT * from data;
.quit" | sqlite3 #{database_path}
COMMAND
      )


puts "[END] export-sqlite-csv/run.rb"
