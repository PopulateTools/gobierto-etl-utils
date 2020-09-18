#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/gobierto_etl_utils"

# Downloads content of an endpoint and saves it into a local file, allowing
# requests with authentication headers

if ARGV.empty?
  ARGV[0] = "-h"
end

options = {}

OptionParser.new do |opts|
  opts.banner = <<-BANNER
    Downloads content of an endpoint and saves it into a local file
    Usage: ruby $DEV_DIR/gobierto-etl-utils/api-download/run.rb [options]
  BANNER

  opts.on("--source-url SOURCE_URL", "Url of the resource to be downloaded. This field is required") do |v|
    options[:source_url] = v
  end
  opts.on("--output-file OUTPUT_FILE", "Path of the file to save the downloaded data. This field is required") do |v|
    options[:output_file] = v
  end
  opts.on("--bearer-token BEARER_TOKEN", "Bearer token to be sent in the request header. Ignored if blank") do |v|
    options[:bearer_token] = v
  end
  opts.on("--compatible COMPATIBLE", FalseClass, "Use and old cipher, necessary for some connections. False by default") do |v|
    options[:compatible] = v
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

puts "[START] api-download/run.rb with #{options.except(:bearer_token)}"

headers = {}
headers["Authorization"] = "Bearer #{options[:bearer_token]}" if options[:bearer_token].present?

uri = URI.parse(options[:source_url])
http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = 500
if options[:source_url] =~ /\Ahttps/
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  if options[:compatible]
    # Use and old cipher, necessary for some connections
    http.ciphers = ["AES128-SHA"]
  end
end

request = Net::HTTP::Get.new(uri.request_uri, headers)
response = http.request(request)

if File.dirname(options[:output_file]) != "."
  FileUtils.mkdir_p(File.dirname(options[:output_file]))
end

File.write(options[:output_file], response.body)

puts "[END] api-download/run.rb"
