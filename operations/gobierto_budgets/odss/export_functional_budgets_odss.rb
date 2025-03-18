# frozen_string_literal: true


require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing the functional budgets data
#  - 1: Absolute path to a file containing the ODS template
#  - 2: Absolute path to the output file
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/odss/export_functional_budgets_odss.rb /tmp/functional_budgets.csv /tmp/ods_template.csv /tmp/output.csv

if ARGV.length != 3
  raise "Check arguments"
end

budgets_data_file_path = ARGV[0]
ods_template_file_path = ARGV[1]
output_file_path = ARGV[2]

def load_functional_budgets_data(file_path)
  budgets = {}
  CSV.read(file_path, headers: true).map do |row|
    next if row["area"] != "functional" && row["kind"] != "G" && row["level"] != "3"

    budgets[row["code"]] = row["initial_value"]
  end

  budgets
end

def hydrate_row(row, budgets)
  code = row["functional_code"]
  amount = budgets[code]&.to_f
  amount = 0 if amount.nil?
    # Count the number of secondary ODS
  number_of_secondary_ods = 0
  1.upto(4) do |i|
    number_of_secondary_ods += 1 if row["secondary_ods_#{i}"].present?
  end

  if number_of_secondary_ods.zero?
    secondary_ods_amount = 0
    primary_ods_amount = amount
  elsif number_of_secondary_ods == 1
    primary_ods_amount = amount * 0.75
    secondary_ods_amount = amount * 0.25
  else
    primary_ods_amount = (amount.to_f / 2).round(2)

    # Second half of the budget is distributed among the secondary ODS
    secondary_ods_amount = (primary_ods_amount / number_of_secondary_ods).round(2)
  end

  [
    row["functional_code"],
    row["name"],
    row["primary_ods"],
    row["secondary_ods_1"],
    row["secondary_ods_2"],
    row["secondary_ods_3"],
    row["secondary_ods_4"],
    amount,
    primary_ods_amount,
    row["secondary_ods_1"].present? ? secondary_ods_amount : 0,
    row["secondary_ods_2"].present? ? secondary_ods_amount : 0,
    row["secondary_ods_3"].present? ? secondary_ods_amount : 0,
    row["secondary_ods_4"].present? ? secondary_ods_amount : 0
  ]
end

def apply_budgets_to_ods_template(budgets, ods_template_file_path, output_file_path)
  ods_template_headers = CSV.read(ods_template_file_path, headers: true).headers

  ouput_headers = ods_template_headers + ["amount", "primary_ods_amount", "secondary_ods_1_amount", "secondary_ods_2_amount", "secondary_ods_3_amount", "secondary_ods_4_amount"]

  CSV.open(output_file_path, "wb+") do |csv|
    csv << ouput_headers

    CSV.read(ods_template_file_path, headers: true).map do |row|
      csv << hydrate_row(row, budgets)
    end
  end
end

budgets = load_functional_budgets_data(budgets_data_file_path)
apply_budgets_to_ods_template(budgets, ods_template_file_path, output_file_path)



