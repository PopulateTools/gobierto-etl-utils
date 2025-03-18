# frozen_string_literal: true


require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing the ODS and the budget lines
#  - 1: Absolute path to the output file
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/odss/export_odss.rb /tmp/ods_and_budget_lines.csv /tmp/output.csv

if ARGV.length != 2
  raise "Check arguments"
end

ods_and_budget_lines_file_path = ARGV[0]
output_file_path = ARGV[1]

ods_budgets = {}
CSV.read(ods_and_budget_lines_file_path, headers: true).map do |row|
  ods_budgets[row["primary_ods"]] ||= 0
  ods_budgets[row["primary_ods"]] += row["primary_ods_amount"].to_f

  ods_budgets[row["secondary_ods_1"]] ||= 0
  ods_budgets[row["secondary_ods_1"]] += row["secondary_ods_1_amount"].to_f

  ods_budgets[row["secondary_ods_2"]] ||= 0
  ods_budgets[row["secondary_ods_2"]] += row["secondary_ods_2_amount"].to_f

  ods_budgets[row["secondary_ods_3"]] ||= 0
  ods_budgets[row["secondary_ods_3"]] += row["secondary_ods_3_amount"].to_f

  ods_budgets[row["secondary_ods_4"]] ||= 0
  ods_budgets[row["secondary_ods_4"]] += row["secondary_ods_4_amount"].to_f
end

CSV.open(output_file_path, "wb+") do |csv|
  csv << ["ods_code", "amount"]
  ods_budgets.each do |ods_code, amount|
    csv << [ods_code, amount]
  end
end
