# Concatenates CSV files that share the same header into one CSV file, writing
# the header once.
#
# The first argument is the destination path of the concatenated files and the
# rest of arguments (2 or more) are the paths of the files to concatenate
#
# Usage:
#   ruby operations/concat-csv/run.rb OUTPUT_PATH INPUT_PATH INPUT_PATH [...]

output_path, *input_paths = ARGV

if output_path.nil? || input_paths.length < 2
  raise "Usage: ruby operations/concat-csv/run.rb OUTPUT_PATH INPUT_PATH INPUT_PATH [...]"
end

puts "[START] concat-csv/run.rb #{input_paths.join(' + ')} into #{output_path}"

header = nil

File.open(output_path, "wb") do |output|
  input_paths.each do |input_path|
    raise "[ERROR] #{input_path} doesn't exist" unless File.file?(input_path)

    File.open(input_path, "rb") do |input|
      input_header = input.gets
      raise "[ERROR] #{input_path} is empty" if input_header.nil?

      if header.nil?
        header = input_header
        output.write(header)
      elsif input_header != header
        raise "[ERROR] #{input_path} header #{input_header.inspect} doesn't match #{header.inspect}"
      end

      copied_bytes = IO.copy_stream(input, output)
      raise "[ERROR] #{input_path} has no data rows" if copied_bytes.zero?

      puts "- #{input_path}: #{copied_bytes} bytes"
    end
  end
end

puts "[END] concat-csv/run.rb"
