# frozen_string_literal: true

require 'dry-matcher'

module Querylicious
  module Matchers
    PhraseCase = Dry::Matcher::Case.new(
      match:   ->(pair) { pair.key == 'phrase' && pair.op == :eql },
      resolve: ->(pair) { pair.value }
    )

    NotPhraseCase = Dry::Matcher::Case.new(
      match:   ->(pair) { pair.key == 'phrase' && pair.op == :not_eql },
      resolve: ->(pair) { pair.value }
    )

    KeyCase = Dry::Matcher::Case.new(
      match:   lambda do |pair, key, op: :eql, type: Object|
        pair.key == key && pair.op == op && pair.value.is_a?(type)
      end,
      resolve: ->(pair) { pair.value }
    )

    DefaultCase = Dry::Matcher::Case.new(match: ->(_pair) { true })

    KeyValuePairMatcher = Dry::Matcher.new(
      phrase:     PhraseCase,
      not_phrase: NotPhraseCase,
      key:        KeyCase,
      default:    DefaultCase
    )

    SimpleKeyValuePairMatcher = Dry::Matcher.new(
      phrase:     PhraseCase,
      not_phrase: NotPhraseCase
    )
  end
end
