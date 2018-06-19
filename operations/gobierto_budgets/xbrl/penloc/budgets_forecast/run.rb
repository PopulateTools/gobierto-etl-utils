require 'ine/places'

=begin

Description:

  Loads budget lines budgeted data in Elasticsearch, from XBRL file.

Usage:

  bin/rails runner <absolute_path_to_script> <absolute_path_to_xbrl_dictionary> <absolute_path_to_xbrl_file> <site_domain> <year>

Parameters:

  1. XBRL dictionary
  2. XBRL file
  3. Site domain
  4. Year
  5. if (ARGV[4] == "test"), executes dry run

Examples (local):

  bin/rails runner ~/proyectos/populate-data-indicators/private_data/gobierto/getafe/recurring/import_budget_lines_budgeted.rb ~/proyectos/populate-data-indicators/private_data/gobierto/getafe/recurring/xbrl_dictionary.yml ~/proyectos/populate-data-indicators/data_sources/private/gobierto/getafe/XX-TrimLoc-2017.xbrl madrid.gobierto.dev 2017

Example (staging):

  bin/rails runner /var/www/populate-data-indicators/private_data/gobierto/esplugues/recurring/import_budget_lines_budgeted.rb /var/www/populate-data-indicators/private_data/gobierto/esplugues/recurring/xbrl_dictionary.yml /var/www/populate-data-indicators/data_sources/private/gobierto/esplugues/budgets_execution/AJ-TrimLoc-2016.xbrl foobar.gobify.net 2016

Example (production):

  ...

=end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

puts '[START]'

xbrl_dictionary_path = ARGV[0]
xbrl_file_path       = ARGV[1]
site_domain          = ARGV[2]
year                 = ARGV[3].to_i
DRY_RUN              = (ARGV[4] == 'test')

site        = Site.find_by(domain: site_domain)
place       = site.place
ine_code    = place.id.to_i
index       = GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast
site_stats  = GobiertoBudgets::SiteStats.new(site: site, year: year)
population  = site_stats.population || site_stats.population(year - 1) || site_stats.population(year - 2)

base_data = {
  ine_code: place.id.to_i, province_id: place.province.id.to_i,
  autonomy_id: place.province.autonomous_region.id.to_i, year: year,
  population: population
}

puts "[DEBUG] Script executed for: xbrl_file_path='#{xbrl_file_path}', xbrl_dictionary_path='#{xbrl_dictionary_path}', site_domain='#{site_domain}', year='#{year}', site.name='#{site.name}', ine_code=#{ine_code}"

puts "[DEBUG] XBRL file path is: #{xbrl_file_path}"

puts '[DEBUG] Opening XBRL dictionary and XBRL file...'

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

  kind = (budget_line_info['kind'] == GobiertoBudgets::BudgetLine::INCOME ? GobiertoBudgets::BudgetLine::INCOME : GobiertoBudgets::BudgetLine::EXPENSE)
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

  amount_per_inhabitant = (amount.to_f / population.to_f).round(2)

  puts "\t---------------------"
  puts "\tXBRL    kind: #{kind}"
  puts "\tXBRL    type: #{type}"
  puts "\tXBRL    code: #{code}"
  puts "\tXBRL    budgeted: #{amount}"
  puts "\tXBRL    amount/hab: #{amount_per_inhabitant}"

  data = base_data.merge({
    amount: amount,
    code: code,
    level: level,
    kind: kind,
    amount_per_inhabitant: amount_per_inhabitant,
    parent_code: parent_code
  })

  id = [place.id,year,code,kind].join("/")

  if !DRY_RUN
    GobiertoBudgets::SearchEngine.client.index(
      index: index,
      type: type,
      id: id,
      body: data
    )
  else
    puts data
    puts "\t[UPDATED]"
  end
end

puts "\t---------------------"

# Load economic budget lines that compose a functional_code
type = 'economic'
xbrl_budget_line_ids.each do |budget_line_id|

  next if (budget_line_info = xbrl_dictionary['dictionary'][budget_line_id]).nil?

  nodes = xbrl_file.xpath("//*[@contextRef='#{budget_line_id}']").select do |node|
    !node.name.include?("TransferenciasDeCapital_") && !node.name.include?("TransferenciasCorrientes_")
  end

  next if nodes.empty?

  functional_code = budget_line_info['code']
  next if functional_code.nil?

  nodes.each do |node|

    budget_line_info = xbrl_dictionary['dictionary']["IdsEconomicaIngresos_#{node.name}"]
    next if budget_line_info.nil?

    if budget_line_info['code'].nil?
      puts budget_line_info
      puts "Ignoring...."
      next
    end

    amount = node.children.text.to_f.round(2)
    next if amount == 0

    kind = (budget_line_info['kind'] == GobiertoBudgets::BudgetLine::INCOME ? GobiertoBudgets::BudgetLine::INCOME : GobiertoBudgets::BudgetLine::EXPENSE)
    code = budget_line_info['code']
    level = code.length
    next if level > 5
    if level == 5
      parent_code = code[0...3]
      code = "#{parent_code}-#{code[3..4]}"
    else
      parent_code = code[0..-2]
    end

    amount_per_inhabitant = (amount.to_f / population.to_f).round(2)

    puts "\t---------------------"
    puts "\tXBRL    kind: #{kind}"
    puts "\tXBRL    type: #{type}"
    puts "\tXBRL    code: #{code}"
    puts "\tXBRL    functional_code: #{functional_code}"
    puts "\tXBRL    budgeted: #{amount}"
    puts "\tXBRL    amount/hab: #{amount_per_inhabitant}"

    data = base_data.merge({
      amount: amount,
      code: code,
      level: level,
      kind: kind,
      amount_per_inhabitant: amount_per_inhabitant,
      parent_code: parent_code,
      functional_code: functional_code,
    })

    id = [place.id,year,[code, functional_code].join('-'),kind].join("/")

    if !DRY_RUN
      GobiertoBudgets::SearchEngine.client.index(
        index: index,
        type: type,
        id: id,
        body: data
      )
    else
      puts data
      puts "\t[UPDATED]"
    end
  end
end

puts "\t---------------------"

puts "[DEBUG] Generating budgets updated notification..."

if !DRY_RUN
  GobiertoBudgets::BudgetLinesImporter.new(site, year).import!
end

puts '[DONE]'

puts "\n\n[INFO] Remember to run the following task in Gobierto to import this records into Algolia:"
puts "\n\tbin/rake gobierto_budgets:algolia:reindex[#{site.domain},#{year}]\n\n"
