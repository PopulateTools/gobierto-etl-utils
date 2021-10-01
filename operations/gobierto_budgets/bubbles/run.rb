#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Absolute path to a file containing the organizations_ids for the import
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/bubbles/run.rb updated_organizations_ids.txt
#

if ARGV.length != 1
  raise "At least one argument is required"
end

ORGANIZATIONS_IDS_FILE_PATH = ARGV[0]

puts "[START] bubbles/run.rb with file=#{ORGANIZATIONS_IDS_FILE_PATH}"

organizations_ids = []

File.open(ORGANIZATIONS_IDS_FILE_PATH, "r") do |f|
  f.each_line do |line|
    organizations_ids << line.strip
  end
end

if organizations_ids.any?
  puts " - Received order to calculate bubbles for #{organizations_ids.size} organizations"

  organizations_ids.each do |organization_id|
    puts " - Calculating bubbles for organization #{organization_id}"
    GobiertoBudgetsData::GobiertoBudgets::Bubbles.dump(organization_id)
  end
else
  puts "[SUMMARY] No organizations to calculate bubbles"
end

puts "[END] bubbles/run.rb"
