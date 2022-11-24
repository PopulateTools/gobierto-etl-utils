#!/usr/bin/env ruby

require_relative "../../../lib/gobierto_etl_utils"

# Clone a dataset from a Gobierto Data instance to another Gobierto Data instance
if ARGV.length == 0
  ARGV[0] = "-h"
end

options = {
  debug: true,
  csv_separator: ',',
  append: false,
  visibility_level: 'active',
  no_verify_ssl: false
}

OptionParser.new do |opts|
  opts.banner = <<-BANNER
Clone a dataset from a Gobierto Data instance to another Gobierto Data instance
Usage: ruby $DEV_DIR/gobierto-etl-utils/operations/gobierto_data/clone-dataset/run.rb [options]

       (*) all parameters are required except those with default value

BANNER

  opts.on("--origin-api-token API_TOKEN", "Gobierto Data Origin API Token") do |v|
    options[:origin_api_token] = v
  end
  opts.on("--origin ORIGIN GOBIERTO_URL", "Gobierto Data URL (protocol + host, i.e http://datos.gobierto.es/") do |v|
    options[:origin] = v
  end
  opts.on("--destination-api-token API_TOKEN", "Gobierto Data Destination API Token") do |v|
    options[:destination_api_token] = v
  end
  opts.on("--destination DESTINATION GOBIERTO_URL", "Gobierto Data URL (protocol + host, i.e http://datos.gobierto.es/") do |v|
    options[:destination] = v
  end
  opts.on("--where-condition", "WHERE condition") do |v|
    options[:where_condition] = v
  end
  opts.on("--no-verify-ssl", "Skip SSL verification") do |v|
    options[:no_verify_ssl] = true
  end
  opts.on("-d", "--debug", "Run with debug mode enabled") do |v|
    options[:debug] = v
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

puts "[START] upload-dataset/run.rb with #{ARGV.join(' - ')}"

origin_host = options[:origin].split("/")[0..2].join("/")

client = GobiertoData::Client.new({
  api_token: options[:origin_api_token],
  gobierto_url: origin_host,
  debug: true
})
metadata = client.metadata(options[:origin].split('/').last)
body = JSON.parse(metadata.body)

name = body.dig("data", "attributes", "name")
slug = body.dig("data", "attributes", "slug")
table_name = body.dig("data", "attributes", "table_name")
schema = body.dig("data", "attributes", "columns")
query = "SELECT * FROM #{table_name} WHERE #{options[:where_condition]}"

client = GobiertoData::Client.new({
  api_token: options[:destination_api_token],
  gobierto_url: options[:destination],
  debug: true
})

params = {
  name: name,
  table_name: table_name,
  slug: slug,
  visibility_level: 'active',
  csv_separator: ",",
  append: false,
  schema: schema,
  file_url: "#{origin_host}/api/v1/data/data.csv?sql=#{CGI.escape(query)}&token=#{options[:origin_api_token]}",
}
client.upsert_dataset(params)

puts "[END] upload-dataset/run.rb"
