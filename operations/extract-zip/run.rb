require "bundler/setup"
Bundler.require
require 'zip'
require 'fileutils'

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Zipfile with extension (.zip)
#  - 1: Destination path
#
# Samples:
#
#   /path/to/project/operations/extract-zip/run.rb /tmp/zipfile.zip documents/tmp
#

if ARGV.length < 1
    raise "Review the arguments"
  end

zipfile_name  =  ARGV[0]
destination_path = ARGV[1]

Zip.on_exists_proc = true
Zip.continue_on_exists_proc = true

Zip::File.open(zipfile_name) do |zip_file|
  # Handle entries one by one
  zip_file.each do |entry|
    fpath = File.join(destination_path, entry.name)
    # Create necessary subdirectories in the destination directory
    FileUtils.mkdir_p(File.dirname(fpath))
    puts "Extracting #{entry.name}"
    # Extract to file or directory based on name in the archive
    entry.extract(destination_path + "/#{entry.name}") unless File.exist?(fpath)
  end
end

puts "[END] extract-zip/run.rb"
