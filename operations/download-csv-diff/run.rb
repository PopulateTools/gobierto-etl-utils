#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require
require "fileutils"
require "open-uri"
require "net/http"
require "net/https"
require "date"

# Usage:
#
#  - Must be ran as an independent Ruby script
#  - It will download the CSV file and check if there is an older version from the previous day.
#    - If there is, it will output the diff between the two versions
#    - If there is not, it will output the newest file
#
# Arguments:
#
#  - 0: URL to download the content
#  - 1: Name of the output file
#
# Samples:
#
#   /path/to/project/operations/download-csv-diff/run.rb "http://input.csv" /tmp/diff.csv
#

if ARGV.length != 2
  raise "Review the arguments"
end

url, output_full_path = ARGV

puts "[START] download-csv-diff/run.rb from #{url} to #{output_full_path}"

def http_response url
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 500
  if url =~ /\Ahttps/
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
end

if File.dirname(output_full_path) != "."
  FileUtils.mkdir_p(File.dirname(output_full_path))
end

response = http_response(url)
output_path = File.dirname(output_full_path)
output_filename = File.basename(output_full_path)

yesterday_full_path = File.join(output_path, "#{Date.today.prev_day.to_s}-#{output_filename}")
day_before_yesterday_full_path = File.join(output_path, "#{Date.today.prev_day.prev_day.to_s}-#{output_filename}")
today_full_path = File.join(output_path, "#{Date.today.to_s}-#{output_filename}")
temp_copy_full_path = "#{output_full_path}.tmp"

# We save today's version either way for the next time
File.write(today_full_path, response.body)

if File.exists?(yesterday_full_path)
  puts "[RUN] download-csv-diff/run.rb creating diff version"
  # If yesterday's version exists, we make the diff
  cmd = "awk '
NR==FNR{
    a[$0]
    next
}
!($0 in a)
' #{yesterday_full_path} #{today_full_path} > #{temp_copy_full_path}"

  `#{cmd}`

  # We add the headers since theey will be missing from the diff
  headers = File.open(today_full_path, &:readline)

  File.open(output_full_path, 'w') do |fo|
    fo.puts headers
    File.foreach("#{temp_copy_full_path}") do |li|
      fo.puts li
    end
  end

  # Remove the temporary file without headers and the day before yesterday csv if it exists
  FileUtils.rm temp_copy_full_path
  FileUtils.rm(day_before_yesterday_full_path) if File.exists?(day_before_yesterday_full_path)
else
  puts "[RUN] download-csv-diff/run.rb creating full version"
  # Otherwise we just use the latest in its entirety
  File.write(output_full_path, response.body)
end

puts "[END] download-csv-diff/run.rb"
