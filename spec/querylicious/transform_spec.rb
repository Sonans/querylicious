# frozen_string_literal: true

require 'querylicious'

RSpec.describe Querylicious::Transform do
  let(:parser) { Querylicious::Parser.new }
  let(:transformer) { described_class.new }

  context 'result of query' do
    subject { transformer.apply parser.parse(query) }

    context '`cats`' do
      let(:query) { 'cats' }

      it { is_expected.to be_a_kv_pair }
      it do
        is_expected.to have_attributes(key: 'phrase', value: 'cats', op: :eql)
      end
    end

    context '`many cats`' do
      let(:query) { 'many cats' }

      it { is_expected.to be_an Array }
      it { is_expected.to have_attributes(size: 2) }
      it do
        is_expected.to(
          all(
            be_a_kv_pair.and(have_attributes(key: 'phrase', op: :eql))
          )
        )
      end
      it do
        is_expected.to(
          include(
            have_attributes(value: 'many'),
            have_attributes(value: 'cats')
          )
        )
      end
    end

    context '`"fluffy cats`' do
      let(:query) { '"fluffy cat"' }

      it { is_expected.to be_a_kv_pair }
      it do
        is_expected.to(
          have_attributes(key: 'phrase', value: 'fluffy cat', op: :eql)
        )
      end
    end

    context '`cats grumpy:yes`' do
      let(:query) { 'cats grumpy:yes' }

      it { is_expected.to all be_a_kv_pair.and(have_op(:eql)) }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'grumpy', value: 'yes')
          )
        )
      end
    end

    context '`cats stars:>1000`' do
      let(:query) { 'cats stars:>1000' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'stars', value: 1000, op: :gt)
          )
        )
      end
    end

    context '`cats topics:>=5`' do
      let(:query) { 'cats stars:>=5' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_key('phrase').and(have_value('cats')),
            have_key('stars').and(have_value(5)).and(have_op(:gteq))
          )
        )
      end
    end

    context '`cats size:<10000`' do
      let(:query) { 'cats size:<10000' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'size', value: 10_000, op: :lt)
          )
        )
      end
    end

    context '`cats stars:<=50`' do
      let(:query) { 'cats stars:<=50' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'stars', value:  50, op: :lteq)
          )
        )
      end
    end

    context '`cats stars:10..*`' do
      let(:query) { 'cats stars:10..*' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'stars', value: 10, op: :gteq)
          )
        )
      end
    end

    context '`cats stars:*..10`' do
      let(:query) { 'cats stars:*..10' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'stars', value: 10, op: :lteq)
          )
        )
      end
    end

    context '`cats stars:10..50`' do
      let(:query) { 'cats stars:10..50' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(key: 'stars', value: 10..50, op: :eql)
          )
        )
      end
    end

    context '`cats created:>2016-04-29`' do
      let(:query) { 'cats created:>2016-04-29' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2016, 4, 29),
              op: :gt
            )
          )
        )
      end
    end

    context '`cats created:>=2016-04-01`' do
      let(:query) { 'cats created:>=2016-04-01' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2016, 4, 1),
              op: :gteq
            )
          )
        )
      end
    end

    context '`cats created:<2012-07-05`' do
      let(:query) { 'cats created:<2012-07-05' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2012, 7, 5),
              op: :lt
            )
          )
        )
      end
    end

    context '`cats created:<=2012-07-04`' do
      let(:query) { 'cats created:<=2012-07-04' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2012, 7, 4),
              op: :lteq
            )
          )
        )
      end
    end

    context '`cats created:2016-04-30..2016-07-04`' do
      let(:query) { 'cats created:2016-04-30..2016-07-04' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: (Date.new(2016, 4, 30)..Date.new(2016, 7, 4)),
              op: :eql
            )
          )
        )
      end
    end

    context '`cats created:2012-04-30`' do
      let(:query) { 'cats created:2012-04-30..*' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2012, 4, 30),
              op: :gteq
            )
          )
        )
      end
    end

    context '`cats created:*..2012-04-30`' do
      let(:query) { 'cats created:*..2012-04-30' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: Date.new(2012, 4, 30),
              op: :lteq
            )
          )
        )
      end
    end

    context(
      '`cats created:2017-01-01T01:00:00+07:00..2017-03-01T15:30:15+07:00`'
    ) do
      let(:query) do
        'cats created:2017-01-01T01:00:00+07:00..2017-03-01T15:30:15+07:00'
      end

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats'),
            have_attributes(
              key: 'created',
              value: DateTime.new(2017, 1, 1, 1, 0, 0, '+7')..
                     DateTime.new(2017, 3, 1, 15, 30, 15, '+7'),
              op: :eql
            )
          )
        )
      end
    end

    context '`hello NOT world`' do
      let(:query) { 'hello NOT world' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'hello', op: :eql),
            have_attributes(key: 'phrase', value: 'world', op: :not_eql)
          )
        )
      end
    end

    context '`cats stars:>10 -language:javascript`' do
      let(:query) { 'cats stars:>10 -language:javascript' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats', op: :eql),
            have_attributes(key: 'stars', value: 10, op: :gt),
            have_attributes(key: 'language', value: 'javascript', op: :not_eql)
          )
        )
      end
    end

    context '`mentions:defunkt -org:github`' do
      let(:query) { 'mentions:defunkt -org:github' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'mentions', value: 'defunkt', op: :eql),
            have_attributes(key: 'org', value: 'github', op: :not_eql)
          )
        )
      end
    end

    context '`cats NOT "hello world"`' do
      let(:query) { 'cats NOT "hello world"' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'cats', op: :eql),
            have_attributes(key: 'phrase', value: 'hello world', op: :not_eql)
          )
        )
      end
    end

    context '`build label:"bug fix"`' do
      let(:query) { 'build label:"bug fix"' }

      it { is_expected.to all be_a_kv_pair }
      it do
        is_expected.to(
          include(
            have_attributes(key: 'phrase', value: 'build', op: :eql),
            have_attributes(key: 'label', value: 'bug fix', op: :eql)
          )
        )
      end
    end
  end
end
