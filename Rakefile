# frozen_string_literal: true

task default: %w[fetch]

task :fetch do
  require "json"
  require "./lib/api"

  client = API::Client.new
  json_response = JSON.parse client.request

  puts json_response
end
