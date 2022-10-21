#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "fileutils"
require "open-uri"
require "net/http"
require "net/https"

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: S3 URI
#  - 1: Output folder
#  - 2: Output filename (optional)
#
# Samples:
#
#   /path/to/project/operations/download-s3/run.rb "getafe/providers" /tmp/foo [foo.txt]
#

if ARGV.length < 2 || ARGV.length > 3
  raise "Review the arguments"
end

folder = ARGV[0]
destination_folder = ARGV[1]
destination_file = ARGV[2]
FileUtils.mkdir_p(destination_folder)

puts "[START] download-s3/run.rb from #{folder} to #{destination_folder}#{destination_file ? "/#{destination_file}" : ""}"

s3 = Aws::S3::Resource.new(
  region: ENV.fetch("GOBIERTO_DATA_AWS_REGION"),
  access_key_id: ENV.fetch("GOBIERTO_DATA_AWS_ACCESS_KEY_ID"),
  secret_access_key: ENV.fetch("GOBIERTO_DATA_AWS_SECRET_ACCESS_KEY")
)

objects = s3.bucket(ENV.fetch("GOBIERTO_DATA_S3_BUCKET_NAME")).objects(prefix: folder).each do |object|
  next if object.get.content_type == "application/x-directory"
  destination_file = "#{destination_folder}/#{destination_file || File.basename(object.public_url)}"
  puts "- Downloading #{object.public_url} in #{destination_file}"
  object.get(response_target: destination_file)
end

puts "[END] download-s3/run.rb"
