# frozen_string_literal: true

require 'dry-types'

module Querylicious
  # Types for Querylicious
  module Types
    include Dry::Types.module

    Range         = Dry::Types::Definition[::Range].new(::Range)
    Strict::Range = Range.constrained(type: ::Range)

    Form::Symbol = Symbol.constructor(&:to_sym)
  end
end
