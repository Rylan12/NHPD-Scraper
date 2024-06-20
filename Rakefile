# frozen_string_literal: true

require "fileutils"
require "pathname"

JSON_DIRECTORY = Pathname("json")

task default: %w[update]

desc "Update the database with the latest records from the API"
task :update do
  require_relative "lib/api"
  require_relative "lib/database"

  client = API::Client.new
  records = client.fetch_records

  puts "Received #{records.size} records from the API."

  db = Database.new
  added, modified = db.update! records
  db.write!

  puts "Updated database with #{added} new records and #{modified} modified records."
end

desc "Fetch the latest records from the API to a JSON file"
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

desc "Dump the latest JSON file into the database"
task :dump do
  require_relative "lib/database"

  input_file = JSON_DIRECTORY.glob("*.json").max
  records = JSON.parse JSON_DIRECTORY.glob("*.json").max.read

  puts "Read #{records.size} records from #{input_file}."

  db = Database.new
  added, modified = db.update! records
  db.write!

  puts "Updated database with #{added} new records and #{modified} modified records."
end

desc "Remove previously created JSON files"
task :clean do
  # Remove all JSON files in the json directory
  JSON_DIRECTORY.glob("*.json").each(&:delete)
end
