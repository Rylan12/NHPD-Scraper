# frozen_string_literal: true

# A collection of charges for a given record
class Charges
  include Enumerable

  def self.from_csv_lines(lines)
    charges = lines.map do |line|
      Charge.new(
        description: line["ChargeDescription"],
        bond_amount: line["ChargeBondAmount"],
        bond_type: line["ChargeBondType"],
      )
    end
    new charges
  end

  def self.from_api_response(response)
    charges = response["Charges"].map do |charge|
      Charge.new(
        description: charge["Description"],
        bond_amount: charge["BondAmount"],
        bond_type: charge["BondType"],
      )
    end
    new charges
  end

  attr_accessor :contents

  def initialize(*charges)
    @contents = Array.new(*charges)
  end

  def empty?
    @contents.empty? || @contents.all?(&:blank?)
  end

  def needs_update?(other)
    return false unless other.is_a? self.class
    return false if empty? && other.empty?
    return true if @contents.length != other.contents.length

    @contents.sort.zip(other.contents.sort).any? { |a, b| a != b }
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

# A single charge entry
class Charge
  attr_accessor :description, :bond_amount, :bond_type

  def initialize(description:, bond_amount:, bond_type:)
    @description = description
    @bond_amount = bond_amount.to_f
    @bond_type = bond_type
  end

  def blank?
    (description.nil? || description.empty?) && bond_amount.zero? && (bond_type.nil? || bond_type.empty?)
  end

  def ==(other)
    return false unless other.is_a? self.class

    description == other.description &&
      bond_amount == other.bond_amount &&
      bond_type == other.bond_type
  end

  def <=>(other)
    return unless other.is_a? self.class

    [description, bond_amount, bond_type] <=> [other.description, other.bond_amount, other.bond_type]
  end
end
