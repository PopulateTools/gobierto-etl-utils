#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

require "yaml"
require "json"
require "pry"

=begin

Description:

  Transform budget lines from XML format to Gobierto JSON format

Parameters:

  1. XML file
  2. Organization ID
  3. Year
  4. Output file

Example:

$DEV_DIR/gobierto-etl-utils/gobierto_budgets/official_xml/transform-executed/run.rb data.xml <organization_id> <year> output.json

=end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

def track_amount(amount, code, output_data, base_data, population, kind, type, functional_code = nil)
  amount_per_inhabitant = base_data[:population] ? (amount.to_f / population).round(2) : nil
  level = code.length
  return if level > 5

  if level == 5
    parent_code = code[0...3]
    code = "#{parent_code}-#{code[3..4]}"
  else
    parent_code = code[0..-2]
  end

  attributes = base_data.merge({
    amount: amount,
    code: code,
    level: level,
    kind: kind,
    amount_per_inhabitant: amount_per_inhabitant,
    parent_code: parent_code,
    type: type
  })
  attributes.merge!({ functional_code: functional_code }) if functional_code

  output_data.push attributes

  return output_data
end

if ARGV.length != 4
  puts "$DEV_DIR/gobierto-etl-utils/gobierto_budgets/official_xml/transform-executed/run.rb data.xml <organization_id> <year> output.json"
  raise "Missing argumnets"
end

xml_file_path = ARGV[0]
organization_id = ARGV[1]
year = ARGV[2].to_i
output_file_path = ARGV[3]

puts "[START] transform-executed/run.rb data=#{xml_file_path} organization_id=#{organization_id} year=#{year} output=#{output_file_path}"

output_data = []
if place = INE::Places::Place.find(organization_id)
  population = GobiertoBudgetsData::GobiertoBudgets::Population.get(place.id, year)
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

xml_file = open(xml_file_path) { |f| Nokogiri::XML(f) }

"""
# kinds:
#   - INCOME
#   - EXPENSE
# areas / types:
#   - ECONOMIC
#   - FUNCTIONAL
#   - ECONOMIC_FUNCTIONAL
"""

[
  {
    nodes: xml_file.css("desglose_ingresos_capital_y_financieros").children + xml_file.css("desglose_ingresos_corrientes").children,
    kind: GobiertoBudgetsData::GobiertoBudgets::INCOME,
    type: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME
  },
  {
    nodes: xml_file.css("desglose_gastos_capital_y_financieros").children + xml_file.css("desglose_gastos_corrientes").children,
    kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE,
    type: GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME
  },
  {
    nodes: xml_file.css("clasificacion_por_programas").children,
    kind: GobiertoBudgetsData::GobiertoBudgets::EXPENSE,
    type: GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME
  }
].each do |batch|
  batch[:nodes].select{ |node| node.name.starts_with?("n_") }.each do |node|
    selector = case batch[:type]
               when GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_AREA_NAME
                 batch[:kind] == GobiertoBudgetsData::GobiertoBudgets::INCOME ? "estimacion_previsiones_definitivas_final_ejercicio_ejercicio_corriente" : "estimacion_creditos_definitivas_final_ejercicio_ejercicio_corriente"
               when GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME
                 "total_programa"
               end

    node_amount = node.css(selector).first
    next if node_amount.nil?

    amount = node_amount.text.to_f.round(2)
    next if amount.zero?

    code = node.name.gsub("n_", "")

    track_amount(amount, code, output_data, base_data, population, batch[:kind], batch[:type])

    if batch[:type] == GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_AREA_NAME
      batch[:nodes].select{ |node| node.name.starts_with?("n_") }.each do |node|

      {
        "gastos_personal" => "1",
        "gastos_corrientes_bienes_y_servicios" => "2",
        "transferencias_corrientes" => "4",
        "inversiones_reales" => "6"
      }.each do |selector, economic_code|
          code = node.name.gsub("n_", "")

          amount_node = node.css(selector).first
          next if amount_node.nil?

          amount = amount_node.text.to_f.round(2)
          next if amount.zero?

          track_amount(amount, economic_code, output_data, base_data, population, batch[:kind], GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_FUNCTIONAL_AREA_NAME, code)
        end
      end
    end
  end
end

File.write(output_file_path, output_data.to_json)

puts "[END] transform-executed/run.rb output=#{output_file_path}"
