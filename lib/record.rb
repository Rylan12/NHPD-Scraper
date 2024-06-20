# frozen_string_literal: true

require "csv"

require_relative "api"
require_relative "charge"

# A collection of records
class Records
  include Enumerable

  def self.from_csv_lines(lines)
    lines = lines.group_by { |line| line["Id"] }
    new(lines.values.map { |group| Record.from_csv_lines group })
  end

  def self.from_api_response(response)
    new(response.map { |record| Record.from_api_response record })
  end

  attr_accessor :contents

  def initialize(*records)
    @contents = Array.new(*records)
  end

  def merge!(other)
    other.each do |record|
      existing = @contents.find { |r| r.id == record.id }
      if existing
        existing.merge! record
      else
        push record
      end
    end
    self
  end

  def to_csv_rows
    @contents.sort.flat_map do |record|
      record.to_csv_arrays.map do |line|
        CSV::Row.new Record::CSV_HEADERS, line
      end
    end
  end

  # Pass everything through to the underlying array
  def respond_to_missing?(*)
    @contents.respond_to?(*)
  end

  def method_missing(method, *, &)
    super unless @contents.respond_to? method

    @contents.send(method, *, &)
  end
end

# A single arrest record entry
class Record
  CSV_HEADERS = [
    # Personal information
    "Id", "FirstName", "MiddleName", "LastName", "Race", "Sex", "Height", "Weight", "Age", "ArresteeAddress",

    # Arrest details
    # The image url is computed from the original API response
    "ImageUrl",
    "ArrestedDateTime", "Location", "Notes",
    "ArrestingOfficerFirstName", "ArrestingOfficerMiddleName", "ArrestingOfficerLastName",
    "Agency", "CaseNumber", "Beat",

    # Bond information (TotalBondAmount)
    "TotalBondAmount", "ArresteeBondType", "CourtDate", "CourtName",

    # Charge information
    # This is flattened into individual lines from the original API response
    "ChargeDescription", "ChargeBondAmount", "ChargeBondType",

    # Other
    "Vehicles", "Properties",
    "LastUpdated"
  ].freeze

  attr_accessor :charges
  attr_reader :contents

  # Take in a CSV line formatted like { "Id" => "1", "FirstName" => "John", ...}
  def self.from_csv_lines(lines)
    # Use the first entry to populate the record
    record = new lines.first
    record.charges = Charges.from_csv_lines lines
    record
  end

  def self.from_api_response(response)
    record = new response
    record.charges = Charges.from_api_response response
    record
  end

  # Don't call this directly because it won't set up charges properly,
  # instead use `from_csv_lines` or `from_api_response`
  def initialize(record)
    # We want values_at to fill in nil for missing keys
    @contents = Hash.new(nil)

    record.each do |key, value|
      @contents[key] = convert_type(key, value)
    end
  end

  def id
    @contents["Id"]&.to_i
  end

  def image_url
    @image_url ||= @contents["ImageUrl"] || API.image_url(@contents["ImageId"]).to_s
  end

  def last_updated
    @last_updated ||= @contents["LastUpdated"] || Time.now
  end

  # Take everything from the new record
  def merge!(other)
    return @contents unless needs_update?(other)

    CSV_HEADERS.each do |key|
      @contents[key] = other[key]
    end

    @image_url = other.image_url
    @charges = other.charges
    @last_updated = Time.now

    @contents
  end

  def <=>(other)
    return unless other.is_a? self.class

    [id, charges] <=> [other.id, other.charges]
  end

  def to_csv_arrays
    return [to_csv_array] if @charges.nil? || @charges.empty?

    @charges.sort.map { |c| to_csv_array charge: c }
  end

  private

  def convert_type(header, value)
    return value.to_i if header == "Id"
    return value.to_f if %w[TotalBondAmount ChargeBondAmount].include?(header)
    return value.to_s if %w[Vehicles Properties].include?(header)
    return nil if value == ""

    value
  end

  # Items are equal if everything matches, but it's okay if one has ImageId and one uses ImageUrl.
  # Also, compare charges using Charge comparison logic and don't depend on the Charge* fields.
  def needs_update?(other)
    return false unless other.is_a? self.class
    return true if charges.needs_update?(other.charges)

    CSV_HEADERS.any? do |key|
      # Charges are handled above, and we don't care about LastUpdated
      next false if key == "LastUpdated" || key.start_with?("Charge")

      if key == "ImageUrl"
        image_url != other.image_url
      else
        @contents[key] != other[key]
      end
    end
  end

  def to_csv_array(charge: nil)
    CSV_HEADERS.map do |header|
      next image_url if header == "ImageUrl"
      next last_updated if header == "LastUpdated"

      unless charge.nil?
        next charge.description if header == "ChargeDescription"
        next charge.bond_amount if header == "ChargeBondAmount"
        next charge.bond_type if header == "ChargeBondType"
      end

      # Return the value or nil if the value is the empty string
      @contents[header] == "" ? nil : @contents[header]
    end
  end

  # Pass everything through to the underlying array
  def respond_to_missing?(*)
    @contents.respond_to?(*)
  end

  def method_missing(method, *, &)
    super unless @contents.respond_to? method

    @contents.send(method, *, &)
  end
end
