require 'mechanize'

# Usage:
#
#  - Must be ran as an independent Ruby script
#  - Goes to url, clicks on text description button and save the downloaded excel
#
# Arguments:
#
#  - 0: URL
#  - 1: Button's text description
#  - 2: Name of the output file
#
# Samples:
#
#   /path/to/project/operations/click-download/run.rb https://example_url.es "Click here for download" /tmp/dataset.xlsx 
#

if ARGV.length != 3
    raise "Review the arguments. Usage: ruby operations/click-download/run.rb https://example_url.es 'Click here for download' /tmp/dataset.xlsx "
  end

url, text_button, output_file = ARGV

# Create a new Mechanize object
agent = Mechanize.new

# Load the page
page = agent.get(url)

# Find the link to download the Excel file
download_link = page.link_with(text: text_button)

# Click the link to download the Excel file
excel_file = agent.get(download_link)

# Save the Excel file
File.open(output_file, 'wb') { |f| f.write(excel_file.body) }
