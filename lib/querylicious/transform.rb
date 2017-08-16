# frozen_string_literal: true

require 'parslet'
require 'date'
require 'querylicious/types'
require 'querylicious/key_value_pair'

module Querylicious
  # Transformer for turning a parsed query string into a list of KeyValuePair
  class Transform < Parslet::Transform
    rule('') { nil }
    rule(string: simple(:it)) { Types::Coercible::String[it] }
    rule(integer: simple(:it)) { Types::Form::Int[it] }
    rule(date: simple(:it)) { Types::Form::Date[it] }
    rule(datetime: simple(:it)) { Types::Form::DateTime[it] }

    rule(symbol: simple(:it)) do
      symbol = Types::Form::Symbol[it.to_s.downcase]

      # Symbol normalization
      case symbol
      when :not then :not_eql
      when :- then :not_eql
      when :> then :gt
      when :>= then :gteq
      when :< then :lt
      when :<= then :lteq
      else symbol
      end
    end

    rule( list: sequence(:it)) { Types::Form::Array[it] }

    rule(range: { start: simple(:first), end: simple(:last) }) do
      if first == :* && last == :*
        :*
      elsif first == :*
        { object: last,  op: :lteq }
      elsif last == :*
        { object: first, op: :gteq }
      else
        Range.new(first, last)
      end
    end

    rule(phrase: simple(:text)) do
      KeyValuePair.new(key: 'phrase', value: text)
    end
    rule(phrase: { object: simple(:text), op: simple(:op) }) do
      KeyValuePair.new(
        key: 'phrase',
        value: Types::Coercible::String[text],
        op: op
      )
    end

    rule(pair: { key: simple(:key), value: simple(:value) }) do
      KeyValuePair.new(key: key, value: value)
    end
    rule(pair: { key: simple(:key), value: simple(:value), op: simple(:op) }) do
      KeyValuePair.new(key: key, value: value, op: op)
    end

    rule(pair: { key: simple(:key), value: sequence(:value) }) do
      KeyValuePair.new(key: key, value: value)
    end
    rule(pair: { key: simple(:key), value: sequence(:value), op: simple(:op) }) do
      KeyValuePair.new(key: key, value: value, op: op)
    end

    rule(op: simple(:op), string: simple(:it)) do
      { object: Types::Coercible::String[it], op: op }
    end
    rule(op: simple(:op), integer: simple(:it)) do
      { object: Types::Form::Int[it], op: op }
    end
    rule(op: simple(:op), date: simple(:it)) do
      { object: Types::Form::Date[it], op: op }
    end
    rule(op: simple(:op), datetime: simple(:it)) do
      { object: Types::Form::DateTime[it], op: op }
    end
    rule(pair: {
           key: simple(:key),
           value: { op: simple(:op), object: simple(:it) }
         }) do
      KeyValuePair.new(key: key, value: it, op: op)
    end

    NEGATIONS = {
      not_eql: :eql,
      eql:     :not_eql,
      gt:      :lteq,
      gteq:    :lt,
      lt:      :gteq,
      lteq:    :gt
    }.freeze

    rule pair: {
      key: simple(:key),
      op: :not_eql,
      value: { object: simple(:obj), op: simple(:op) }
    } do
      KeyValuePair.new(key: key, value: obj, op: NEGATIONS[op])
    end
  end
end
