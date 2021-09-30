#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Organization ID to remove data
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/clear-previous-providers/run.rb 8019

if ARGV.length != 1
  raise "At least one argument is required"
end

index = GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_INVOICES
type =  GobiertoBudgetsData::GobiertoBudgets::INVOICE_TYPE
organization_id = ARGV[0].to_s

puts "[START] clear-previous-providers/run.rb organization_id=#{organization_id}"

terms = [
  {term: { location_id: organization_id }}
]

query = {
  query: {
    filtered: {
      filter: {
        bool: {
          must: terms
        }
      }
    }
  },
  size: 10_000
}

count = 0
response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
while response['hits']['total'] > 0
  delete_request_body = response['hits']['hits'].map do |h|
    count += 1
    { delete: h.slice("_index", "_type", "_id") }
  end
  GobiertoBudgetsData::GobiertoBudgets::SearchEngineWriting.client.bulk index: index, type: type, body: delete_request_body
  response = GobiertoBudgetsData::GobiertoBudgets::SearchEngine.client.search index: index, type: type, body: query
end

puts "[END] clear-previous-providers/run.rb. Deleted #{count} items"
