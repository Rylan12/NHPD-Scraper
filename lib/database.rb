# frozen_string_literal: true

require "csv"
require "pathname"

require_relative "recent_arrest_record"

# Handle processing of arrest records into CSV format
class Database
  DEFAULT_FILE = Pathname("data/arrests.csv")

  attr_reader :file, :records

  def initialize(file: DEFAULT_FILE)
    @file = Pathname(file)

    return unless @file.exist?

    @table = CSV.read(file, headers: true)
    @ids = @table.values_at("Id").uniq

    populate_records
  end

  def create_csv(from_records)
    from_records = from_records.map { |record| RecentArrestRecord.new(record) }

    CSV.open(file, "w", headers: RecentArrestRecord::CSV_HEADERS, write_headers: true) do |csv|
      from_records.each do |record|
        record.to_csv_lines.each { |line| csv << line }
      end
    end
  end

  private

  def populate_records
    grouped_records = @table.group_by { |row| row["Id"] }
    @records = grouped_records.values.map do |rows|
      RecentArrestRecord.from_csv_lines rows.map(&:to_h)
    end
  end
end
