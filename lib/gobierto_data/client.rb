# frozen_string_literal: true

require_relative "../gobierto_etl_utils"

module GobiertoData
  class Client

    class ServerError < StandardError; end

    attr_accessor(
      :gobierto_url,
      :auth_header,
      :debug
    )

    def initialize(params = {})
      self.gobierto_url = params[:gobierto_url]
      self.debug = params[:debug] || false

      raise "API token can't be blank" unless params[:api_token].present?
      self.auth_header = "Bearer #{params[:api_token]}"
    end

    def create_dataset(params = {})
      multipart = params[:file_path].present? || params[:schema_path].present?
      response = connection(multipart).post(
        "api/v1/data/datasets",
        build_dataset_params(multipart, params),
        build_dataset_request_headers(multipart)
      )
      log_response(response) if debug
      response
    end

    def update_dataset(params = {})
      multipart = params[:file_path].present? || params[:schema_path].present?
      response = connection(multipart).put(
        "api/v1/data/datasets/#{params[:slug]}",
        build_dataset_params(multipart, params),
        build_dataset_request_headers(multipart)
      )
      log_response(response) if debug
      response
    end

    def upsert_dataset(params = {})
      response = connection.get("api/v1/data/datasets/#{params[:slug]}/meta")
      log_response(response) if debug

      if response.status == 200
        update_dataset(params)
      elsif response.status == 404
        create_dataset(params)
      else
        raise ServerError, response.status
      end
    end

    private

    def log_response(response)
      puts "#{response.env.method.upcase} #{response.env.url} ===> #{response.status}"
      puts "\tBODY: #{response.body}" if (response.status < 200 || response.status > 299)
    end

    def connection(multipart = false)
      @connection = begin
        Faraday.new(gobierto_url) do |f|
          f.request(:multipart ) if multipart
          f.request :url_encoded
          f.adapter :net_http
        end
      end
    end

    def build_dataset_params(multipart, params = {})
      dataset_params = {
        name: params[:name],
        table_name: params[:table_name],
        slug: params[:slug],
        local_data: false,
        visibility_level: params[:visibility_level],
        csv_separator: params[:csv_separator] || ",",
        append: params[:append] || false
      }

      dataset_params.merge!({data_path: params[:file_url]}) if params[:file_url]
      dataset_params.merge!({data_file: Faraday::UploadIO.new(params[:file_path], "text/csv")}) if params[:file_path]
      dataset_params.merge!({schema_file: Faraday::UploadIO.new(params[:schema_path], "application/json")}) if params[:schema_path]

      if multipart
        {dataset: dataset_params}
      else
        dataset_params = {
          data: {
            type: "gobierto_data-dataset_forms",
            attributes: dataset_params
          }
        }
        dataset_params.to_json
      end
    end

    def build_dataset_request_headers(multipart)
      default_headers = {
        "Authorization" => auth_header
      }
      default_headers.merge!({"Content-Type" => "application/json"}) unless multipart
      default_headers
    end
  end
end
