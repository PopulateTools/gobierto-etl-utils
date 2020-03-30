#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "fileutils"

# Removes the directory and creates it if doesn't exist
#
# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: directory
#
# Samples:
#
#   $DEV_DIR/gobierto-etl-utils/operations/prepare-working-directory/run.rb /tmp/mataro
#

if ARGV.length != 1
  raise "Review the arguments"
end

directory = ARGV[0]

puts "[START] prepare-working-directory/run.rb #{directory}"

FileUtils.rm_rf(directory)
FileUtils.mkdir_p(directory)

puts "[END] prepare-working-directory/run.rb"
