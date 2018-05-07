# frozen_string_literal: true

require 'dry-struct'
require 'querylicious/types'

module Querylicious
  # A search-query key-value, with optional operator
  class KeyValuePair < Dry::Struct::Value
    Operators = Types::Strict::Symbol.enum(
      :eql, :not_eql, :gt, :gteq, :lt, :lteq
    )

    attribute :key, Types::Strict::String
    attribute :value,
              Types::Strict::String |
              Types::Strict::Integer |
              Types::Strict::Date |
              Types::Strict::DateTime |
              Types::Strict::Range |
              Types::Strict::Array
    attribute :op, Operators.optional.default(:eql)
  end
end
