# frozen_string_literal: true

require 'querylicious'

RSpec.describe Querylicious::QueryReducer do
  context '#call' do
    context 'for an string-array reducer' do
      let(:reducer) do
        reducer = lambda do |arr, m|
          m.phrase do |phrase|
            arr.select { |item| item == phrase }
          end

          m.not_phrase do |phrase|
            arr.reject { |item| item == phrase }
          end

          m.key 'size', type: Integer do |size|
            arr.select { |item| item.size == size }
          end

          m.key 'size', op: :gt do |size|
            arr.select { |item| item.size > size }
          end

          # Ignore unrecognized keys
          m.default { arr }
        end
        described_class.new(reducer)
      end

      strings = %w[foo bar pizza].freeze
      context("and the strings #{strings.inspect}") do
        where(:case_name, :strings, :query, :result) do
          case_name = ->(query) { "and the query #{query.inspect}" }


          [
            [strings, 'foo', %w[foo]],
            [strings, 'NOT foo', %w[bar pizza]],
            [strings, 'NOT foo size:3', %w[bar]],
            [strings, 'size:>3', %w[pizza]],
            [strings, 'size:"5"', strings],
            [strings, 'baz', []],
            [strings, 'fnord:23', strings],
            [strings, '', strings],
            [strings, nil, strings]
          ].map { |params| [case_name[params[1]], *params] }
        end

        with_them do
          context 'the return value' do
            subject { reducer.call(strings, query) }

            it { is_expected.to contain_exactly(*result) }
          end
        end
      end
    end
  end
end
