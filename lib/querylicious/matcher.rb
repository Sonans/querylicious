# frozen_string_literal: true

require 'dry-matcher'

module Querylicious
  # A matcher for query key-value pairs
  class Matcher
    # Subclass of Dry::Matcher::Evalutator which provides aliases for common
    # matchers
    class Evaluator < Dry::Matcher::Evaluator
      def phrase(&block)
        key('phrase', op: :eql, type: ::String, &block)
      end

      def not_phrase(&block)
        key('phrase', op: :not_eql, type: ::String, &block)
      end
    end

    CASES = {
      key:     Dry::Matcher::Case.new(
        match:   lambda do |pair, key, op: :eql, type: Object|
          pair.key == key && pair.op == op && pair.value.is_a?(type)
        end,
        resolve: ->(pair) { pair.value }
      ),
      default: Dry::Matcher::Case.new(match: ->(_pair) { true })
    }.freeze

    def self.call(result, &block)
      Evaluator.new(result, CASES).call(&block)
    end
  end
end
