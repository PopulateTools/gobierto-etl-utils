#!/usr/bin/env ruby

require_relative "../../lib/gobierto_etl_utils"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: SQLite database
#  - 1: SQL script
#
# Samples:
#
#   $DEV_DIR/gobierto-etl-utils/operations/apply-sqlite-transform/run.rb script.sql database.sqlite
#

if ARGV.length != 2
  raise "Review the arguments"
end

transform_script = ARGV[0]
input_database = ARGV[1]

puts "[START] apply-sqlite-transform/run.rb #{transform_script} on the database #{input_database}"

unless File.file?(transform_script)
  raise "[ERROR] File #{transform_script} doesn't exist"
end

unless File.file?(input_database)
  raise "[ERROR] File #{input_database} doesn't exist"
end

system "cat #{transform_script} | sqlite3 #{input_database}"

puts "[END] apply-sqlite-transform/run.rb"
