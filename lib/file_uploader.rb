# frozen_string_literal: true

require "active_support/all"
require "tempfile"
require "action_dispatch"
require_relative "file_uploader_service/s3"
require_relative "file_uploader_service/local"

class FileUploader
  attr_reader :file, :file_name

  def initialize(args={})
    @adapter = args.fetch(:adapter)
    @file_name = args.fetch(:file_name)
    @tmp_file = Tempfile.new
    @tmp_file.binmode
    if args[:path].present?
      open(args[:path]) do |f|
        @tmp_file.write f.read
      end
    else
      @tmp_file.write(args[:content])
    end
    @tmp_file.close
    @file =  ::ActionDispatch::Http::UploadedFile.new(filename: @file_name.split('/').last, tempfile: @tmp_file)
    @content_type = args[:content_type]
  end

  delegate :call, :uploaded_file_exists?, :upload!, to: :adapter

  def adapter
    case @adapter
    when :s3 then FileUploaderService::S3.new(file: file, file_name: file_name)
    when :filesystem then FileUploaderService::Local.new(file: file, file_name: file_name)
    end
  end
end
