# frozen_string_literal: true

require 'querylicious'

RSpec.describe Querylicious::QueryReducer do
  context 'with a string-array reducer and array' do
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
      reducer = described_class.new(reducer)
      reducer.curry.call(strings)
    end

    strings = %w[foo bar pizza].freeze
    context strings.to_s do
      let(:strings) { strings }

      context 'and the query `foo`' do
        let(:query) { 'foo' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly('foo') }
      end

      context 'and the query `NOT foo`' do
        let(:query) { 'NOT foo' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly('bar', 'pizza') }
      end

      context 'and the query `NOT foo size:3`' do
        let(:query) { 'NOT foo size:3' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly('bar') }
      end

      context 'and the query `size:>3`' do
        let(:query) { 'size:>3' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly('pizza') }
      end

      context 'and the query `size:"5"` (invalid value type)' do
        let(:query) { 'size:"5"' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly(*strings) }
      end

      context 'and the query `baz`' do
        let(:query) { 'baz' }
        subject { reducer.call(query) }

        it { is_expected.to be_empty }
      end

      context 'and the query `fnord:23`' do
        let(:query) { 'fnord:23' }
        subject { reducer.call(query) }

        it { is_expected.to contain_exactly(*strings) }
      end
    end
  end
end
