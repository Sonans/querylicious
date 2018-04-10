# frozen_string_literal: true

require 'querylicious'

RSpec.describe Querylicious::Transform do
  let(:parser) { Querylicious::Parser.new }
  let(:transformer) { described_class.new }

  context '#apply' do
    context 'with an empty query' do
      let(:query) { '' }

      context 'the return value' do
        subject { transformer.apply parser.parse(query) }

        it { is_expected.to eq nil }
      end
    end
    context 'with a single statmeent query' do
      where(:case_name, :query, :result) do
        [
          ['cats', { key: 'phrase', value: 'cats', op: :eql }],
          ['"fluffy cats"', { key: 'phrase', value: 'fluffy cats', op: :eql }],
          [
            '"Dwayne \"The Rock\" Johnson"',
            { key: 'phrase', value: 'Dwayne "The Rock" Johnson', op: :eql }
          ]
        ].map { |params| [params.first.inspect, *params] }
      end

      with_them do
        context 'the return value' do
          subject { transformer.apply parser.parse(query) }

          it { is_expected.to eq Querylicious::KeyValuePair.new(result) }
        end
      end
    end

    context 'with a multiple statement query' do
      where(:case_name, :query, :results) do
        [
          ['many cats', [
            { key: 'phrase', value: 'many', op: :eql },
            { key: 'phrase', value: 'cats', op: :eql }
          ]],
          ['cats grumpy:yes', [
            { key: 'phrase', value: 'cats' },
            { key: 'grumpy', value: 'yes' }
          ]],
          ['cats stars:>1000', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 1000, op: :gt }
          ]],
          ['cats stars:>=5', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 5, op: :gteq }
          ]],
          ['cats size:<10000', [
            { key: 'phrase', value: 'cats' },
            { key: 'size', value: 10_000, op: :lt }
          ]],
          ['cats stars:<=50', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value:  50, op: :lteq }
          ]],
          ['cats stars:10..*', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 10, op: :gteq }
          ]],
          ['cats stars:*..10', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 10, op: :lteq }
          ]],
          ['cats stars:10..50', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 10..50, op: :eql }
          ]],
          ['cats created:>2016-04-29', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2016, 4, 29), op: :gt }
          ]],
          ['cats created:>=2016-04-01', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2016, 4, 1), op: :gteq }
          ]],
          ['cats created:<2012-07-05', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2012, 7, 5), op: :lt }
          ]],
          ['cats created:<=2012-07-04', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2012, 7, 4), op: :lteq }
          ]],
          ['cats created:2016-04-30..2016-07-04', [
            { key: 'phrase', value: 'cats' },
            {
              key: 'created',
              value: Date.new(2016, 4, 30)..Date.new(2016, 7, 4),
              op: :eql
            }
          ]],
          ['cats created:2012-04-30..*', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2012, 4, 30), op: :gteq }
          ]],
          ['cats created:*..2012-04-30', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2012, 4, 30), op: :lteq }
          ]],
          ['cats -created:2012-04-30..*', [
            { key: 'phrase', value: 'cats' },
            { key: 'created', value: Date.new(2012, 4, 30), op: :lt }
          ]],
          ['cats created:>2017-01-01T01:00:00+07:00', [
            { key: 'phrase', value: 'cats' },
            {
              key: 'created',
              value: DateTime.new(2017, 1, 1, 1, 0, 0, '+7'),
              op: :gt
            }
          ]],
          [
            'cats created:2017-01-01T01:00:00+07:00..2017-03-01T15:30:15+07:00',
            [
              { key: 'phrase', value: 'cats' },
              {
                key: 'created',
                value: DateTime.new(2017, 1, 1, 1, 0, 0, '+7')..
                       DateTime.new(2017, 3, 1, 15, 30, 15, '+7'),
                op: :eql
              }
            ]
          ],
          ['hello NOT world', [
            { key: 'phrase', value: 'hello' },
            { key: 'phrase', value: 'world', op: :not_eql }
          ]],
          ['cats stars:>10 -language:javascript', [
            { key: 'phrase', value: 'cats' },
            { key: 'stars', value: 10, op: :gt },
            { key: 'language', value: 'javascript', op: :not_eql }
          ]],
          ['mentions:defunkt -org:github', [
            { key: 'mentions', value: 'defunkt', op: :eql },
            { key: 'org', value: 'github', op: :not_eql }
          ]],
          ['cats NOT "hello world"', [
            { key: 'phrase', value: 'cats' },
            { key: 'phrase', value: 'hello world', op: :not_eql }
          ]],
          ['build label:"bug fix"', [
            { key: 'phrase', value: 'build' },
            { key: 'label', value: 'bug fix', op: :eql }
          ]],
          ['cats owner:"Dwayne \"The Rock\" Johnson"', [
            { key: 'phrase', value: 'cats' },
            { key: 'owner', value: 'Dwayne "The Rock" Johnson', op: :eql }
          ]],
          ['cats breed:tabby,persian', [
            { key: 'phrase', value: 'cats' },
            { key: 'breed', value: %w[tabby persian], op: :eql }
          ]],
          ['cats owner:name:bob', [
            { key: 'phrase', value: 'cats' },
            { key: 'owner', value: 'name:bob', op: :eql }
          ]]
        ].map { |params| [params.first.inspect, *params] }
      end

      with_them do
        context 'the return value' do
          subject { transformer.apply parser.parse(query) }

          it { is_expected.to be_an Array }
          it { is_expected.to have_size results.size }
          it do
            is_expected.to(
              include(
                *results.map do |attributes|
                  Querylicious::KeyValuePair.new(attributes)
                end
              )
            )
          end
        end
      end
    end
  end
end
