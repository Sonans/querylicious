# frozen_string_literal: true

require 'dry-struct'
require 'querylicious/types'

module Querylicious
  # A search-query key-value, with optional operator
  class KeyValuePair < Dry::Struct::Value
    constructor_type :strict_with_defaults

    Operators = Types::Strict::Symbol.enum(
      :eql, :not_eql, :gt, :gteq, :lt, :lteq
    )

    attribute :key, Types::Strict::String
    attribute :value,
              Types::Strict::String |
              Types::Strict::Int |
              Types::Strict::Date |
              Types::Strict::DateTime |
              Types::Strict::Range
    attribute :op, Operators.optional.default(:eql)
  end
end
