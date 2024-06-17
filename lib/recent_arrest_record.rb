# frozen_string_literal: true

require_relative "api"

# A single arrest record entry
class RecentArrestRecord < Hash
  CSV_HEADERS = [
    "Id",
    "FirstName",
    "MiddleName",
    "LastName",
    "Race",
    "Sex",
    "Height",
    "Weight",
    "Age",
    "ArresteeAddress",
    "ImageUrl", # Computed from the original API response
    "ArrestedDateTime",
    "Location",
    "Notes",
    "ArrestingOfficerFirstName",
    "ArrestingOfficerMiddleName",
    "ArrestingOfficerLastName",
    "Agency",
    "CaseNumber",
    "Beat", # TotalBondAmount is removed from the original API response
    "ArresteeBondType",
    "CourtDate",
    "CourtName",
    "ChargeDescription", # Flattened from the original API response
    "ChargeBondAmount",
    "ChargeBondType",
    "Vehicles",
    "Properties",
  ].freeze

  attr_writer :image_url, :charges

  def initialize(record)
    super
    merge!(record)

    # We want values_at to fill in nil for missing keys
    self.default = nil

    @charges = record["Charges"]
    @image_url = API.image_url(record["ImageId"])
  end

  def id
    self["Id"]&.to_i
  end

  def <=>(other)
    return unless other.is_a? RecentArrestRecord

    self["Id"] <=> other["Id"]
  end

  def to_csv_lines
    return [to_csv_line] if @charges.empty?

    @charges.map { |c| to_csv_line charge: c }
  end

  private

  def to_csv_line(charge: nil)
    line = values_at(*CSV_HEADERS)

    line[CSV_HEADERS.index("ImageUrl")] = @image_url
    unless charge.nil?
      line[CSV_HEADERS.index("ChargeDescription")] = charge["Description"]
      line[CSV_HEADERS.index("ChargeBondAmount")] = charge["BondAmount"]
      line[CSV_HEADERS.index("ChargeBondType")] = charge["BondType"]
    end

    line.map { |value| value == "" ? nil : value }
  end
end
