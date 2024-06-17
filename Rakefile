# frozen_string_literal: true

require "fileutils"
require "pathname"

JSON_DIRECTORY = Pathname("json")

task default: %w[fetch create_csv]

task :fetch do
  require_relative "lib/api"
  FileUtils.mkdir_p JSON_DIRECTORY

  client = API::Client.new
  records = client.fetch_records

  puts "Received #{records.size} records from the API."

  output_file = JSON_DIRECTORY / "#{Time.now.strftime('%Y%m%dT%H%M%S')}.json"
  output_file.write records.to_json

  puts "Wrote JSON output to #{output_file}."
end

task :create_csv do
  require_relative "lib/database"

  input_file = JSON_DIRECTORY.glob("*.json").max
  records = JSON.parse JSON_DIRECTORY.glob("*.json").max.read

  puts "Read #{records.size} records from #{input_file}."

  db = Database.new
  db.create_csv records

  puts "Wrote CSV output to #{db.file}."
end

task :clean do
  # Remove all JSON files in the json directory
  JSON_DIRECTORY.glob("*.json").each(&:delete)
end
