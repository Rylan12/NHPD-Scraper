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

  def initialize(record)
    super
    merge!(record)

    @charges = record["Charges"]
    @image_url = API.image_url(record["ImageId"])
  end

  def to_csv_lines
    @charges.map do |charge|
      # values_at fills in nil for missing keys
      line = values_at(*CSV_HEADERS)

      line[CSV_HEADERS.index("ImageUrl")] = @image_url
      line[CSV_HEADERS.index("ChargeDescription")] = charge["Description"]
      line[CSV_HEADERS.index("ChargeBondAmount")] = charge["BondAmount"]
      line[CSV_HEADERS.index("ChargeBondType")] = charge["BondType"]

      line.map { |value| value == "" ? nil : value }
    end
  end
end
