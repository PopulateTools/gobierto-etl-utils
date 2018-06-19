#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as Rails runner of Gobierto
#
# Arguments:
#
#  - 0: Years to import total budget
#  - 1: Absolute path to a file containing the organizations_ids for the import
#
# Samples:
#
#   /path/to/project/operations/gobierto_budgets/annual_data/run.rb "2010 2012 2017" ids.txt
#

if ARGV.length != 2
  raise "Review arguments"
end

YEARS = ARGV[0].split.map(&:to_i)
ORGANIZATIONS_IDS_FILE_PATH = ARGV[1]

puts "[START] annual_data/run.rb with years=#{YEARS} file=#{ORGANIZATIONS_IDS_FILE_PATH}"

organizations_ids = []

File.open(ORGANIZATIONS_IDS_FILE_PATH, "r") do |f|
  f.each_line do |line|
    organizations_ids << line.strip
  end
end

if organizations_ids.any?
  puts "Received order to update annual for #{organizations_ids.size} organizations"

  organizations_ids.each do |organization_id|
    Site.where(organization_id: organization_id).find_each do |site|
      YEARS.each do |year|
        puts " - Calculating annual data for #{organization_id} in year #{year}"
        GobiertoBudgets::Data::Annual.new(site: site, year: year).generate_files
      end
    end
  end
else
  puts "[SUMMARY] No organizations to update"
end

puts "[END] annual_data/run.rb"
