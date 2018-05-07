# frozen_string_literal: true

require 'dry-types'

module Querylicious
  # Types for Querylicious
  module Types
    include Dry::Types.module

    Coercible::Symbol = Symbol.constructor { |sym| String(sym).to_sym }
  end
end
