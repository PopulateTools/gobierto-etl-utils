#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require_relative "../../lib/file_uploader.rb"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Local file
#  - 1: S3 filename (the file will be saved in gobierto_data)
#
# Samples:
#
#   /path/to/project/operations/upload-s3/run.rb /tmp/foo/execution_status.yml gobierto-etl-gencat/status/last_execution.yml
#

if ARGV.length != 2
  raise "Review the arguments"
end

origin = ARGV[0]
destination_name = ARGV[1]

puts "[START] upload-s3/run.rb from #{origin} to #{destination_name}"
uploader = FileUploader.new(adapter: :s3, path: origin, file_name: destination_name)
puts "- Uploading #{ origin } to #{ uploader.upload! }"
puts "[END] upload-s3/run.rb"
