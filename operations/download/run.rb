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
#  - 2: --compatible
#
# Samples:
#
#   /path/to/project/operations/download/run.rb "http://input.json" /tmp/output.json
#

if ARGV.length < 2 || ARGV.length > 3
  raise "Review the arguments"
end

def fetch(url, compatible_mode, limit = 10)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 500
  if url =~ /\Ahttps/
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    if compatible_mode
      # Use and old cipher, necessary for some connections
      http.ciphers = ['AES128-SHA']
    end
  end
  request = Net::HTTP::Get.new(uri.to_s)
  response = http.request(request)

  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then fetch(response['location'], compatible_mode, limit - 1)
  else
    response.error!
  end
end

url = ARGV[0]
destination_file_name = ARGV[1]
compatible_mode = ARGV[2]

puts "[START] download/run.rb from #{url} to #{destination_file_name} #{compatible_mode ? " using compatible mode" : ""}"
response = fetch(url, compatible_mode)

if File.dirname(destination_file_name) != "."
  FileUtils.mkdir_p(File.dirname(destination_file_name))
end

File.open(destination_file_name, 'wb') do |file|
  body_io = StringIO.new(response.body)
  until body_io.eof?
    file.write(body_io.read(1024*1024)) # Write 1 MB chunks at a time to avoid Errno::EINVAL errors like `Invalid argument @ io_fread` and `Invalid argument @ io_write`.
  end
end

puts "[END] download/run.rb"
