# frozen_string_literal: true

require 'querylicious/types'
require 'querylicious/parser'
require 'querylicious/transform'
require 'querylicious/matchers'

require 'dry-initializer'

module Querylicious
  # Reducer
  class QueryReducer
    extend Dry::Initializer

    param :reducer, Types::Any.constrained(attr: :to_proc)

    def self.call(reducable, query, &block)
      new(block).call(reducable, query)
    end

    def call(reducable, query)
      parse_query(query).reduce(reducable) do |memo, rule|
        Matchers::KeyValuePairMatcher.call(
          rule,
          &reducer.to_proc.curry.call(memo)
        )
      end
    end

    def curry(*args)
      to_proc.curry(*args)
    end

    def to_proc
      method(:call)
    end

    private

    def transformer
      @transformer ||= Transform.new
    end

    def parser
      @parser ||= Parser.new
    end

    def parse_query(query)
      Array(transformer.apply(parser.parse(query.strip)))
    end
  end
end
