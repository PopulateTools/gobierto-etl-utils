#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Years to import total budget
#  - 1: Absolute path to a file containing the organizations_ids for the import
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/update_total_budgets/run.rb "2010 2012 2017" ids.txt
#

if ARGV.length != 2
  raise "Review arguments"
end

YEARS = ARGV[0].split.map(&:to_i)
ORGANIZATIONS_IDS_FILE_PATH = ARGV[1]

puts "[START] update_total_budgets/run.rb with years=#{YEARS} file=#{ORGANIZATIONS_IDS_FILE_PATH}"

TOTAL_BUDGET_INDEXES = [
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST,
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_EXECUTED,
  GobiertoBudgetsData::GobiertoBudgets::ES_INDEX_FORECAST_UPDATED
].freeze

organizations_ids = []

File.open(ORGANIZATIONS_IDS_FILE_PATH, "r") do |f|
  f.each_line do |line|
    organizations_ids << line.strip
  end
end

if organizations_ids.any?
  puts "Received order to update total budgets for #{organizations_ids.size} organizations"

  organizations_ids.each do |organization_id|
    YEARS.each do |year|
      TOTAL_BUDGET_INDEXES.each do |index|
        puts " - Calculating totals for #{organization_id} in year #{year} for index #{index}"

        total_budget_calculator = GobiertoBudgetsData::GobiertoBudgets::TotalBudgetCalculator.new(
          organization_id: organization_id,
          year: year,
          index: index
        )
        total_budget_calculator.calculate!
      end
    end
  end
else
  puts "[SUMMARY] No organizations to update"
end

puts "[END] update_total_budgets/run.rb"
