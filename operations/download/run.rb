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
# Environment:
#
#  - DOWNLOAD_PROXY_LIST_URL: URL of a list of proxy IPs, one per line. When set together with
#    DOWNLOAD_PROXY_PORT, the download goes through a random proxy from that list.
#  - DOWNLOAD_PROXY_PORT: port of the proxies in the list
#
# Samples:
#
#   /path/to/project/operations/download/run.rb "http://input.json" /tmp/output.json
#

if ARGV.length < 2 || ARGV.length > 3
  raise "Review the arguments"
end

url = ARGV[0]
destination_file_name = ARGV[1]
compatible_mode = ARGV[2]

puts "[START] download/run.rb from #{url} to #{destination_file_name} #{compatible_mode ? " using compatible mode" : ""}"

def proxy_address
  list_url = ENV["DOWNLOAD_PROXY_LIST_URL"]
  port = ENV["DOWNLOAD_PROXY_PORT"]
  return if list_url.to_s.empty? || port.to_s.empty?

  ips = URI.open(list_url, &:read).split.grep(/\A[\d.]+\z/)
  raise "No proxy IPs found in DOWNLOAD_PROXY_LIST_URL" if ips.empty?

  "http://#{ips.sample}:#{Integer(port)}"
end

proxy = proxy_address

command = "wget -O #{destination_file_name}"
command += " --no-check-certificate" if compatible_mode
command += " -e https_proxy=#{proxy} -e http_proxy=#{proxy}" if proxy
command += " '#{url}'"

puts command
system(command)

puts "[END] download/run.rb"
