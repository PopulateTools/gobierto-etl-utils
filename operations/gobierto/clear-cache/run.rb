#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

# Usage:
#
#  - Must be ran as Rails runner of Gobierto
#
# Arguments:
#
#  - No arguments
#
# Samples:
#
#   /path/to/project/operations/gobierto/clear-cache/run.rb
#

puts "[START] clear-cache/run.rb"

Rails.cache.clear

puts "[END] clear-cache/run.rb"
