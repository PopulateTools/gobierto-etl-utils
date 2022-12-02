require 'zip'

# Usage:
#
#  - Must be ran as an independent Ruby script
#
# Arguments:
#
#  - 0: Zipfile with extension (.zip)
#
# Samples:
#
#   /path/to/project/operations/extract-zip/run.rb /tmp/zipfile.zip
#

if ARGV.length < 1
    raise "Review the arguments"
  end

zipfile_name  =  ARGV[0]

Zip::File.open(zipfile_name) do |zip_file|
    # Handle entries one by one
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
      raise 'File too large when extracted' if entry.size > MAX_SIZE
  
      # Extract to file or directory based on name in the archive
      entry.extract
    end
  end

puts "[END] extract-zip/run.rb"
