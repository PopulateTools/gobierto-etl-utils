#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

index = GobiertoData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
data_file = ARGV[0]
year = ARGV[1].to_i

puts "[START] import-planned-budgets/run.rb year=#{year} data_file=#{data_file}"

nitems = GobiertoData::GobiertoBudgets::BudgetLinesImporter.new(index: index, year: year, data: JSON.parse(File.read(data_file))).import!

puts "[END] import-planned-budgets/run.rb imported #{nitems} items"
