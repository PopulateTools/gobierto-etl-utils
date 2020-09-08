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
#  - 0: URL to download the content
#  - 1: Output file
#
# Samples:
#
#   /path/to/project/operations/download/run.rb "http://input.json" /tmp/output.json
#

if ARGV.length != 2
  raise "Review the arguments"
end

url = ARGV[0]
destination_file_name = ARGV[1]

puts "[START] download/run.rb from #{url} to #{destination_file_name}"


uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 500
if url =~ /\Ahttps/
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  # Use and old cipher, necessary for some connections
  http.ciphers = ['AES128-SHA']
end
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)

if File.dirname(destination_file_name) != "."
  FileUtils.mkdir_p(File.dirname(destination_file_name))
end

File.write(destination_file_name, response.body)

puts "[END] download/run.rb"
