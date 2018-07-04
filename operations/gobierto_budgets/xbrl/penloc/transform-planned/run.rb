#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

require "yaml"
require "json"

=begin

Description:

  Transform budget lines from XBRL format to Gobierto JSON format

Usage:

  bin/rails runner <absolute_path_to_script> <absolute_path_to_xbrl_dictionary> <absolute_path_to_xbrl_file> <site_domain> <year>

Parameters:

  1. XBRL dictionary
  2. XBRL file
  3. Organization ID
  4. Year
  5. Output file

Example:

$DEV_DIR/gobierto-etl-utils/gobierto_budgets/xbrl/penloc/transform-planned/run.rb dictionary.yml data.xbrl <organization_id> <year> output.json

=end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

if ARGV.length != 5
  puts "$DEV_DIR/gobierto-etl-utils/gobierto_budgets/xbrl/penloc/transform-planned/run.rb dictionary.yml data.xbrl <organization_id> <year> output.json"
  raise "Missing argumnets"
end

puts '[START]'

xbrl_dictionary_path = ARGV[0]
xbrl_file_path       = ARGV[1]
organization_id      = ARGV[2]
year                 = ARGV[3].to_i
output_file_path     = ARGV[4]

puts "[START] transform-planned/run.rb with dictionary=#{xbrl_dictionary_path} data=#{xbrl_file_path} organization_id=#{organization_id} year=#{year} output=#{output_file_path}"

output_data = []
if place = INE::Places::Place.find(organization_id)
  population = GobiertoData::GobiertoBudgets::Population.get(place.id, year)
  base_data = {
    organization_id: organization_id,
    ine_code: place.id.to_i,
    province_id: place.province.id.to_i,
    autonomy_id: place.province.autonomous_region.id.to_i,
    year: year,
    population: population
  }
else
  base_data = {
    organization_id: organization_id,
    ine_code: nil,
    province_id: nil,
    autonomy_id: nil,
    year: year,
    population: nil
  }
end

xbrl_dictionary = YAML.load_file(xbrl_dictionary_path)
xbrl_file       = File.open(xbrl_file_path) { |f| Nokogiri::XML(f) }

xbrl_budget_line_ids = xbrl_file.xpath('//@contextRef').map{ |xml_node| xml_node.value }.select{ |budget_line_id| budget_line_id[/^Ids?(Contextos)?Economica.*/] }.uniq

puts "[DEBUG] Found #{xbrl_budget_line_ids.size} different Budget Line IDs..."

puts '[DEBUG] Parsing budgets execution data...'

xbrl_budget_line_ids.each do |budget_line_id|
  next if (budget_line_info = xbrl_dictionary['dictionary'][budget_line_id]).nil?

  nodes = xbrl_file.xpath("//*[@contextRef='#{budget_line_id}']").select do |node|
    !node.name.include?("TransferenciasDeCapital_") && !node.name.include?("TransferenciasCorrientes_")
  end

  next if nodes.empty?

  amount = nodes.map { |node| node.children.text.to_f.round(2) }.reduce(:+)

  next if amount == 0

  if budget_line_info['code'].nil?
    puts budget_line_info
    puts "Ignoring...."
    next
  end

  kind = (budget_line_info['kind'] == 'I' ? GobiertoData::GobiertoBudgets::INCOME : GobiertoData::GobiertoBudgets::EXPENSE)
  code = budget_line_info['code']
  level = code.length
  next if level > 5
  if level == 5
    parent_code = code[0...3]
    code = "#{parent_code}-#{code[3..4]}"
  else
    parent_code = code[0..-2]
  end
  type = budget_line_info['area']

  amount_per_inhabitant = base_data[:population] ? (amount.to_f / population.to_f).round(2) : nil

  output_data.push base_data.merge({
    amount: amount,
    code: code,
    level: level,
    kind: kind,
    amount_per_inhabitant: amount_per_inhabitant,
    parent_code: parent_code,
    type: type
  })
end

File.write(output_file_path, output_data.to_json)

puts "[END] transform-planned/run.rb output=#{output_file_path}"
