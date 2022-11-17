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

ruby $DEV_DIR/gobierto-etl-utils/operations/gobierto_data/clone-dataset/run.rb
    --origin https://datos.gobierto.es/datos/tasa-natalidad
    --origin-api-token xxxxx
    --destination https://esplugues.gobify.net
    --destination-api-token xxxxx
    --ine-code 8077
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
  opts.on("--ine-code INE_CODE", "Place INE code") do |v|
    options[:ine_code] = v
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

pp options

# gobierto_data_client = GobiertoData::Client.new(options.slice(:api_token, :gobierto_url, :debug, :no_verify_ssl))
# gobierto_data_client.upsert_dataset(options.except(:api_token, :gobierto_url, :debug))

# ruby $DEV_DIR/gobierto-etl-utils/operations/gobierto_data/clone-dataset/run.rb
#     --origin https://datos.gobierto.es/datos/tasa-natalidad
#     --origin-api-token xxxxx
#     --destination https://esplugues.gobify.net
#     --destination-api-token xxxxx

# 0. Extract origin dataset slug (tasa-natalidad)
# 1. Read origin dataset metadata
#    GET https://datos.gobierto.es/api/v1/data/datasets/tasa-natalidad/meta.json
origin_host = options[:origin].split("/")[0..2].join("/")

client = GobiertoData::Client.new({
  api_token: options[:origin_api_token],
  gobierto_url: origin_host,
  debug: true
})
metadata = client.metadata(options[:origin].split('/').last)
body = JSON.parse(metadata.body)

# 2. Get dataset name
name = body.dig("data", "attributes", "name")
# 3. Get dataset slug
slug = body.dig("data", "attributes", "slug")
# 4. Get dataset table_name
table_name = body.dig("data", "attributes", "table_name")
# 5. Get dataset schema
schema = body.dig("data", "attributes", "columns").to_json
# 7. Build SQL query "SELECT * FROM tasa_natalidad WHERE place_id = 8077"
query = "SELECT * FROM #{table_name} WHERE place_id = #{options[:ine_code]}"
# 8. Fill destination dataset options hash: name, slug, table_name, schema_path, file_url
# 9. Create destination dataset
client = GobiertoData::Client.new({
  api_token: options[:destination_api_token],
  gobierto_url: options[:destination],
  debug: true
})

params = {
  name: name,
  table_name: table_name,
  slug: slug,
  local_data: false,
  visibility_level: 'active',
  csv_separator: ",",
  append: false,
  schema: schema,
  data_path: "#{origin_host}/api/v1/data/data.csv?sql=#{CGI.escape(query)}&token=#{options[:origin_api_token]}",
}
pp params
client.upsert_dataset(params)



puts "[END] upload-dataset/run.rb"
