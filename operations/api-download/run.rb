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
  opts.on("--basic-auth USER_AND_PASSWORD", "User and password separated by a colon to be used with basic auth in the request. Ignored if blank") do |v|
    options[:basic_auth_user], options[:basic_auth_password] = v.split(":")
  end
  opts.on("--compatible COMPATIBLE", FalseClass, "Use and old cipher, necessary for some connections. False by default") do |v|
    options[:compatible] = v
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

puts "[START] api-download/run.rb with #{options.except(:bearer_token, :basic_auth_user, :basic_auth_password)}"

headers = {}
headers["Authorization"] = "Bearer #{options[:bearer_token]}" if options[:bearer_token].present?

uri = URI.parse(CGI.unescape(options[:source_url]))
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

request = Net::HTTP::Get.new(uri.to_s, headers)
request.basic_auth(options[:basic_auth_user], options[:basic_auth_password]) if options.values_at(:basic_auth_user, :basic_auth_password).all?(&:present?)
response = http.request(request)

unless response.code == "200"
  puts "[ERROR] Unexpected response code: #{response.code}: #{response.body}"
  exit(-1)
end

if File.dirname(options[:output_file]) != "."
  FileUtils.mkdir_p(File.dirname(options[:output_file]))
end

File.write(options[:output_file], response.body)

puts "[END] api-download/run.rb"
