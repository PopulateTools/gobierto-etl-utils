#!/usr/bin/env ruby

require_relative "../../../lib/gobierto_etl_utils"

# Uploads a dataset to Gobierto Data

if ARGV.length == 0
  ARGV[0] = "-h"
end

options = {
  debug: true,
  csv_separator: ',',
  append: false,
  visibility_level: 'active'
}

OptionParser.new do |opts|
  opts.banner = <<-BANNER
Uploads / Updates a dataset in Gobierto Data
Usage: ruby $DEV_DIR/gobierto-etl-utils/operations/gobierto_data/upload-dataset/run.rb [options]

       (*) all parameters are required except those with default value
BANNER

  opts.on("--api-token API_TOKEN", "Gobierto Data API Token") do |v|
    options[:api_token] = v
  end
  opts.on("--gobierto-url GOBIERTO_URL", "Gobierto Data URL (protocol + host, i.e http://datos.gobierto.es/") do |v|
    options[:gobierto_url] = v
  end
  opts.on("--name DATASET_NAME", "Dataset name") do |v|
    options[:name] = v
  end
  opts.on("--slug DATASET_SLUG", "Dataset slug") do |v|
    options[:slug] = v
  end
  opts.on("--table-name TABLE_NAME", "Dataset table-name") do |v|
    options[:table_name] = v
  end
  opts.on("--file-path FILE_PATH", "Data file path") do |v|
    options[:file_path] = v
  end
  opts.on("--schema-path SCHEMA_PATH", "Schema file path") do |v|
    options[:schema_path] = v
  end
  opts.on("--append", "Append existing dataset") do |v|
    options[:append] = v
  end
  opts.on("--visibility-level VISIBILITY_LEVEL ", "Dataset visibility level (draft or active). By default active") do |v|
    options[:visibility_level] = v
  end
  opts.on("--csv-separator SEPARATOR", "CSV separator. By default ','") do |v|
    options[:csv_separator] = v
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

gobierto_data_client = GobiertoData::Client.new(options.slice(:api_token, :gobierto_url, :debug))
gobierto_data_client.upsert_dataset(options.except(:api_token, :gobierto_url, :debug))

puts "[END] upload-dataset/run.rb"
