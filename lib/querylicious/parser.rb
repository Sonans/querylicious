# frozen_string_literal: true

require 'parslet'

module Querylicious
  # Parser for Querylicious search queries
  class Parser < Parslet::Parser
    rule(:expression) do
      ((kv_pair | phrase) >> (space >> expression).repeat).maybe
    end

    rule(:phrase) do
      (
        (str('NOT').as(:symbol).as(:op) >> space).maybe >> (word | quoted_string)
      ).as(:phrase)
    end

    rule(:kv_pair) do
      (str('-').as(:symbol).as(:op).maybe >> key.as(:key) >>
        str(':') >> value.as(:value)).as(:pair)
    end

    rule(:key) { word }
    rule(:value) do
      list | range | (kv_op.as(:op).maybe >> (datetime | integer | simple_string | quoted_string))
    end

    rule(:kv_op) { (str('>=') | str('>') | str('<=') | str('<')).as(:symbol) }

    rule(:word) { match('[[:graph:]&&[^":.,]]').repeat(1).as(:string) }
    rule(:simple_string) do
      match('[[:graph:]&&[^".,]]').repeat(1).as(:string)
    end
    rule(:quoted_string) do
      str('"') >> (str('\"') | match('[[^"]&&[:print:]]')).repeat(0).as(:string) >> str('"')
    end
    rule(:integer) { match('\d').repeat(1).as(:integer) }

    rule(:range) do
      ((star | datetime | integer | word).as(:start) >>
        dotdot >>
        (star | datetime | integer | word).as(:end)
      ).as(:range)
    end

    rule(:list) do
      ((range | datetime | integer | simple_string | quoted_string) >>
        (comma >>
        (range | datetime | integer | simple_string | quoted_string)).repeat(1)
      ).as(:list)
    end

    rule(:datetime) do
      (date >> str('T') >> time).as(:datetime) | date.as(:date)
    end
    rule(:date) do
      digits4 >> str('-') >> digits2 >> str('-') >> digits2
    end
    rule(:time) do
      digits2 >> str(':') >> digits2 >> str(':') >> digits2 >> timezone
    end

    rule(:timezone) do
      str('Z') | (str('+') >> digits2 >> str(':') >> digits2)
    end

    rule(:star)      { str('*').as(:symbol) }
    rule(:dotdot)    { str('..') }
    rule(:comma) { str(',') }

    rule(:space)     { match('[[:space:]]').repeat(1) }
    rule(:space?)    { space.maybe }

    rule(:digits2)   { match('\d').repeat(2, 2) }
    rule(:digits4)   { match('\d').repeat(4, 4) }

    root(:expression)
  end
end
