# frozen_string_literal: true

require "http-cookie"
require "json"
require "net/http"
require "stringio"
require "uri"
require "zlib"

# Handle API requests to the Police to Citizen API
module API
  BASE_URL = URI("https://newhavenct.policetocitizen.com/api/")
  AGENCY_ID = 158
  MODULES = %w[RecentArrests Inmates].freeze

  def self.default_headers
    {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip",
      "Accept-Language" => "en-US,en;q=0.9",
      "Cache-Control" => "no-cache",
      "Connection" => "keep-alive",
      "Content-Type" => "application/json",
      "Host" => BASE_URL.host,
      "Origin" => "https://#{BASE_URL.host}",
    }
  end

  def self.payload(query: nil, take: 10, skip: 0) # rubocop:disable Metrics/MethodLength
    {
      "FilterOptionsParameters" => {
        "IntersectionSearch" => true,
        "SearchText" => query || "",
        "Parameters" => [],
      },
      "IncludeCount" => true,
      "PagingOptions" => {
        "SortOptions" => [
          {
            "Name" => "ArrestedDateTime",
            "SortDirection" => "Descending",
            "Sequence" => 1,
          },
        ],
        "Take" => take,
        "Skip" => skip,
      },
    }.to_json
  end

  # Handle the API fetch logic
  class Client
    def initialize
      @cookie_jar = HTTP::CookieJar.new
      @xsrf_token = nil

      setup_session
    end

    def request(mod = MODULES[0], payload = API.payload(), headers = {})
      request_url = BASE_URL + "#{mod}/#{AGENCY_ID}"
      response = Net::HTTP.post(request_url, payload, merge_headers(headers))

      raise "Request failed with code #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      return response.body unless response["Content-Encoding"] == "gzip"

      Zlib::GzipReader.new(StringIO.new(response.body)).read
    end

    private

    def setup_session
      response = Net::HTTP.get_response(BASE_URL)
      response.get_fields("set-cookie").each do |cookie|
        @cookie_jar.parse(cookie, BASE_URL)
      end
      xsrf_cookie = @cookie_jar.cookies.find { |cookie| cookie.name == "XSRF-TOKEN" }
      @xsrf_token = xsrf_cookie.value if xsrf_cookie
    end

    def merge_headers(headers)
      API.default_headers.merge(headers).merge(
        "Cookie" => HTTP::Cookie.cookie_value(@cookie_jar.cookies(BASE_URL)),
        "X-XSRF-TOKEN" => @xsrf_token,
      )
    end
  end
end
