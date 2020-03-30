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
      if params[:file_path]
        dataset_params = {
          data_file: Faraday::UploadIO.new(params[:file_path], "text/csv"),
          name: params[:name],
          table_name: params[:table_name],
          slug: params[:slug],
          visibility_level: params[:visibility_level],
          csv_separator: params[:csv_separator] || ",",
          append: params[:append] || false
        }
        dataset_params.merge!({schema_file: Faraday::UploadIO.new(params[:schema_path], "application/json")}) if params[:schema_path]
        response = multipart_connection.post("api/v1/data/datasets", {
          dataset: dataset_params
        }, "Authorization" => auth_header)
      else
        response = Faraday.post(
          "#{gobierto_url}/api/v1/data/datasets",
          build_dataset_meta(params).to_json,
          "Content-Type" => "application/json",
          "Authorization" => auth_header
        )
      end
      log_response(response) if debug
      response
    end

    def update_dataset(params = {})
      if params[:file_path]
        response = multipart_connection.put(
          "api/v1/data/datasets/#{params[:slug]}",
          {
            dataset: {
              data_file: Faraday::UploadIO.new(params[:file_path], "text/csv"),
              visibility_level: params[:visibility_level],
              csv_separator: params[:csv_separator] || ",",
              append: params[:append] || false
            }
          },
          "Authorization" => auth_header
        )
      else
        response = Faraday.put(
          "#{gobierto_url}/api/v1/data/datasets/#{params[:slug]}",
          build_dataset_meta(params).to_json,
          "Content-Type" => "application/json",
          "Authorization" => auth_header
        )
      end
      log_response(response) if debug
      response
    end

    def upsert_dataset(params = {})
      response = Faraday.get("#{gobierto_url}/api/v1/data/datasets/#{params[:slug]}/meta")
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

    def multipart_connection
      @multipart_connection = begin
        Faraday.new(gobierto_url) do |f|
          f.request :multipart
          f.request :url_encoded
          f.adapter :net_http
        end
      end
    end

    def build_dataset_meta(params = {})
      {
        data: {
          type: "gobierto_data-dataset_forms",
          attributes: {
            name: params[:name],
            table_name: params[:table_name],
            slug: params[:slug],
            data_path: params[:file_url],
            local_data: false,
            visibility_level: params[:visibility_level]
          }
        }
      }
    end
  end
end
