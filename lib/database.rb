# frozen_string_literal: true

require "csv"
require "pathname"

require_relative "record"

# Handle processing of arrest records into CSV format
class Database
  DEFAULT_FILE = Pathname("data/arrests.csv")

  attr_reader :file, :records

  def initialize(file: DEFAULT_FILE)
    @file = Pathname(file)

    return unless @file.exist?

    table = CSV.read(file, headers: true)
    @ids = table.values_at("Id").uniq
    @records = Records.from_csv_lines table.map(&:to_h)
  end

  def update!(new_json_records)
    new_records = Records.from_api_response new_json_records

    @records.merge! new_records
  end

  def write!(file = @file)
    table = CSV::Table.new @records.to_csv_rows
    File.write file, table.to_csv
  end
end
