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
#   /path/to/project/operations/gobierto_budgets/publish-activity/run.rb budgets_updated ids.txt
#

if ARGV.length != 2
  raise "Review arguments"
end

action = ARGV[0]
ORGANIZATIONS_IDS_FILE_PATH = ARGV[1]

puts "[START] publish-activity/run.rb with action=#{action} file=#{ORGANIZATIONS_IDS_FILE_PATH}"

organizations_ids = []

File.open(ORGANIZATIONS_IDS_FILE_PATH, "r") do |f|
  f.each_line do |line|
    organizations_ids << line.strip
  end
end

if organizations_ids.any?
  puts "Received order to update annual for #{organizations_ids.size} organizations"

  organizations_ids.each do |organization_id|
    puts " - Publishing activity #{action} for #{organization_id}"
    Site.where(organization_id: organization_id).find_each do |site|
      Publishers::GobiertoBudgetsActivity.broadcast_event(action, {
        action: action,
        site_id: site.id
      })
    end
  end
else
  puts "[SUMMARY] No organizations to update"
end

puts "[END] publish-activity/run.rb"
