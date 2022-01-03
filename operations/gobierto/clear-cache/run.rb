#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Clears cache for a site and namespace

if ARGV.length == 0
  ARGV[0] = "-h"
end

options = {}

OptionParser.new do |opts|
  opts.banner = <<-BANNER
Clears cache for a site and namespace
Usage: cd $DEV/gobierto; bin/rails runner $DEV/gobierto-etl-utils/operations/gobierto/clear-cache/run.rb [options]

       (*) site-organization-id or site-domain must be provided to find a site and namespace is required
BANNER

  opts.on("--site-organization-id SITE_ORGANIZATION_ID", "Site organization_id") do |v|
    options[:organization_id] = v
  end
  opts.on("--site-domain SITE_DOMAIN", "Site domain") do |v|
    options[:domain] = v
  end
  opts.on("--namespace NAMESPACE", "Cache namespace (for example: GobiertoData)") do |v|
    options[:namespace] = v
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

puts "[START] clear-cache/run.rb with #{ARGV.join(' - ')}"

site_options = options.slice(:organization_id, :domain).reject { |_, v| v.blank? }

site = Site.find_by(**site_options)

if site.blank?
  raise "Site not found. Please provide a valid domain or organization_id"
end

cache_service = GobiertoCommon::CacheService.new(site, options[:namespace])
cache_service.clear

puts "[END] clear-cache/run.rb"
