#!/usr/bin/env ruby

require "bundler/setup"
Bundler.require

data_file = ARGV[0]

puts "[START] import-invoices/run.rb data_file=#{data_file}"

nitems = GobiertoData::GobiertoBudgets::InvoicesImporter.new(data: JSON.parse(File.read(data_file))).import!

puts "[END] import-invoices/run.rb imported #{nitems} items"
