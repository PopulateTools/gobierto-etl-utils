#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing the organizations_ids for the deletion
#  - 1: Year (optional)
#  - 2: types to remove (optional). Valid values: economic, functional, custom, total
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/clear-budgets/run.rb /tmp/id.txt [year]

if ARGV.length > 2
  raise "Check arguments"
end

ORGANIZATIONS_IDS_FILE_PATH = ARGV[0]
year = ARGV[1]

indices = [
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
]

types = [
  GobiertoBudgetsData::GobiertoBudgets::TOTAL_BUDGET_TYPE,
  GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_BUDGET_TYPE,
  GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_BUDGET_TYPE,
  GobiertoBudgetsData::GobiertoBudgets::CUSTOM_BUDGET_TYPE
]

if ARGV[2].present?
  types = []
  ARGV[2].split(',').each do |type|
    case type
      when "total"
        types << GobiertoBudgetsData::GobiertoBudgets::TOTAL_BUDGET_TYPE
      when "economic"
        types << GobiertoBudgetsData::GobiertoBudgets::ECONOMIC_BUDGET_TYPE
      when "functional"
        types << GobiertoBudgetsData::GobiertoBudgets::FUNCTIONAL_BUDGET_TYPE
      when "custom"
        types << GobiertoBudgetsData::GobiertoBudgets::CUSTOM_BUDGET_TYPE
    end
  end
end

organizations_ids = []

File.open(ORGANIZATIONS_IDS_FILE_PATH, "r") do |f|
  f.each_line do |line|
    organizations_ids << line.strip
  end
end

puts "[START] clear-budgets/run.rb file=#{ORGANIZATIONS_IDS_FILE_PATH}"

organizations_ids.each do |organization_id|
  puts "- Organization: #{organization_id}"

  terms = [
    {term: { organization_id: organization_id }}
  ]

  if year
    terms.push({term: { year: year }})
  end

  query = {
    query: {
      bool: {
        must: terms
      }
    },
    size: 10_000
  }

  count = 0
  indices.each do |index|
    types.each do |type|
      response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, body: query
      while response['hits']['total'] > 0
        delete_request_body = response['hits']['hits'].map do |h|
          count += 1
          { delete: h.slice("_index", "_type", "_id") }
        end
        GobiertoBudgetsData::GobiertoBudgets::SearchEngineWriting.client.bulk index: index, body: delete_request_body
        response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, body: query
      end
    end
  end

  puts "-  Deleted #{count} items"
end

puts "[END] clear-budgets/run.rb."
