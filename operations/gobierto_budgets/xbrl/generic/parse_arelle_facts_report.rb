require "byebug"
require "csv"
require "json"
require "nokogiri"
require "active_support"
require "active_support/core_ext"

puts "[START] parse_arelle_facts_report.rb"

workdir = ARGV[0]
facts_report_path = ARGV[1]
taxonomy_dir_path = ARGV[2]
taxonomy_id = ARGV[3]
output_csv_path = ARGV[4] || "#{workdir}/budget_lines.csv"

TAXONOMIES_INFO = {
  "trimloc-2017" => { # Execution
    hacienda_id_regex: /\Atrimloc2017-econ-(gast|ingr)-(cuentas|importes).*/,
    concepts: {
      updated_estimated_amount_regex: /Estimación (Previsiones|Créditos) Definitiv(a|o)s al final de ejercicio/,
      current_amount_regex: /(Derechos|Obligaciones) Reconocid(o|a)s Net(o|a)s del ejercicio corriente/
    }
  },
  "lenloc-6" => { # Liquidation
    hacienda_id_regex: /\Alenloc6-econ-(gast|ingr)-(cuentas|importes).*/,
    concepts: {
      estimated_amount_regex: /(Previsión|Créditos) inicial(es)? del ejercicio corriente/,
      final_amount_regex: /(Obligaciones|Derechos) reconocid(a|o)s del ejercicio corriente/
    }
  },
  "penloc-2015" => { # Forecast
    hacienda_id_regex: /\Apenloc2015-econ-(gast|ingr)-(cuentas|importes).*/,
    concepts: {
      estimated_amount_regex: /(Previsión|Crédito) inicial del ejercicio/
    }
  }
}

taxonomy_info = TAXONOMIES_INFO[taxonomy_id]

# TODO: move to separate stage "Generate budget lines mappings"
puts "Generating budget lines mappings..."
labels_dictionary = {}

Dir.foreach("#{taxonomy_dir_path}") do |file_name|
  next if file_name == '.' || file_name == '..' || !file_name.include?("label.xml")

  puts "Extracting labels info from taxonomy file #{file_name}..."

  xml_doc = File.open("#{taxonomy_dir_path}/#{file_name}") { |f| Nokogiri::XML(f) }

  xml_doc.xpath("//link:label").each do |label_tag|
    label_id = label_tag["id"]
    label_id_suffix = label_id.gsub("label_", "")

    labels_dictionary[label_id_suffix] = {
      label_id: label_id,
      label_text: label_tag.text
    }
  end
end

puts "Puts writing labels info report..."

File.open("#{workdir}/labels_report.json", "w") do |f|
  f.write(JSON.pretty_generate(labels_dictionary))
end

# TODO: move to separate stage "Parse XBRL facts"
puts "Parsing XBRL facts..."
budget_line_items = []

CSV.foreach("#{facts_report_path}", headers: true) do |row|
  # WARNING: Arelle/XBRL bugs
  # - The Label key includes a non-printable character, for reading it we can't use the literal
  # - The number of headers does not match the number of columns. For accessing the last column
  #   we have to do it with the `nil` hash key
  row_hash = row.to_hash
  label_key = row_hash.keys.first
  hacienda_budget_line_id_key = nil

  hacienda_budget_line_id = row_hash[hacienda_budget_line_id_key]
  budget_line_code = nil
  budget_line_name = nil

  if hacienda_budget_line_id.include?(":")
    label_dict_entry = labels_dictionary[hacienda_budget_line_id.split(":").last]
    if label_dict_entry && (splitted_text = label_dict_entry[:label_text].split(":")).length == 2
      budget_line_code = splitted_text[0]
      budget_line_name = splitted_text[1].strip
    end
  end

  budget_line_items << {
    label: row_hash[label_key],
    hacienda_budget_line_id_aux: row_hash["Name"],
    name: budget_line_name,
    context_ref: row_hash["contextRef"],
    amount: row_hash["Value"].to_f,
    instant: Date.parse(row_hash["End/Instant"]),
    dimensions: row_hash["Dimensions"],
    hacienda_budget_line_id: hacienda_budget_line_id,
    budget_line_code: budget_line_code
  }
end

puts "Writing XBRL facts report..."

File.open("#{workdir}/json_report.json", "w") do |f|
  f.write(JSON.pretty_generate(items: budget_line_items))
end

# TODO: move to separate stage "Generate budget lines summary"
puts "Generate budget lines summary..."
budget_lines_summary = {}
instant = budget_line_items.first[:instant]

budget_line_items.each do |budget_line_item|
  # Only keep nodes relative to budget line imports
  next unless taxonomy_info[:hacienda_id_regex].match?(budget_line_item[:hacienda_budget_line_id])

  kind = budget_line_item[:hacienda_budget_line_id].include?("gast") ? "E" : "I"
  area = budget_line_item[:hacienda_budget_line_id].include?("econ") ? "economic" : "functional"
  code = budget_line_item[:budget_line_code]
  budget_line_id = "#{area}/#{kind}/#{code}"

  taxonomy_info[:concepts].each do |concept_key, concept_regex|
    next unless concept_regex.match?(budget_line_item[:label])

    concept_name = concept_key.to_s.gsub("_regex", "")

    if budget_lines_summary[budget_line_id]
      budget_lines_summary[budget_line_id][concept_name] = budget_line_item[:amount]
    else
      budget_lines_summary[budget_line_id] = {
        code: code,
        concept_name => budget_line_item[:amount],
        kind: kind,
        area: area,
        name: budget_line_item[:name]
      }
    end
  end
end

File.open("#{workdir}/budget_lines_summary.json", "w") do |f|
  f.write(JSON.pretty_generate(
    instant: instant,
    items: budget_lines_summary
  ))
end

# TODO: move to separate stage "Generate CSV"

def budget_line_level(code)
  if code.include?(".")
    code.split(".")[0].length + 1
  else
    code.length
  end
end

def budget_line_parent_code(code)
  if code.include?(".")
    code.split(".")[0]
  elsif code.length == 1
    nil
  else
    code[0..-2] # everything but last character
  end
end

amounts_concepts_names = taxonomy_info[:concepts].keys.map { |key| key.to_s.gsub("_regex", "") }
CSV_HEADERS = %w(code date area income/expense name level parent_code) + amounts_concepts_names

CSV.open("#{output_csv_path}", "w") do |csv|
  csv << CSV_HEADERS

  sorted_budget_line_items = budget_lines_summary.values.reject { |item| item[:code].blank? }.sort do |a, b|
    # -1 when a follows b
    # 0 when a and b are equivalent
    # +1 when b follows a
    if a[:kind] == b[:kind] && a[:code] == b[:code]
      0
    elsif a[:kind] != b[:kind]
      a[:kind] == "I" ? 1 : -1
    elsif a[:kind] == b[:kind]
      a[:code] <=> b[:code]
    end
  end

  sorted_budget_line_items.each do |item|
    next if item[:code].blank?

    base_columns = [
      item[:code],
      instant,
      item[:area],
      item[:kind],
      item[:name],
      budget_line_level(item[:code]),
      budget_line_parent_code(item[:code])
    ]

    csv << base_columns + amounts_concepts_names.map { |concept_name| item[concept_name] }
  end
end

puts "[END] parse_arelle_facts_report.rb"
