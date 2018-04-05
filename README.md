<div align="center">
    <img src="https://res.cloudinary.com/huyderman/image/upload/c_scale,dpr_2,f_auto,fl_preserve_transparency,q_auto,w_728/v1522834080/querylicious" width="728">
</div>

[![Gem Version](https://badge.fury.io/rb/querylicious.svg)](https://badge.fury.io/rb/querylicious)
[![Build Status](https://travis-ci.org/huyderman/querylicious.svg?branch=master)](https://travis-ci.org/huyderman/querylicious)
[![Maintainability](https://api.codeclimate.com/v1/badges/6eeb81253ec37a703d9f/maintainability)](https://codeclimate.com/github/huyderman/querylicious/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6eeb81253ec37a703d9f/test_coverage)](https://codeclimate.com/github/huyderman/querylicious/test_coverage)
[![Join the chat at https://gitter.im/querylicious/Lobby](https://badges.gitter.im/querylicious/Lobby.svg)](https://gitter.im/querylicious/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> Querylicious is an opinionated and repository agnostic search query parser and reducer.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'querylicious'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install querylicious

## Usage

Querylicious parses [GitHub-style search queries](https://help.github.com/articles/understanding-the-search-syntax/), and let's you specify an reducer to generate the result. The reducer is a callable object such as an proc. Here is an simple example where the repository is an array of strings:

```rb
repository = %w[Garnet Amethyst Pearl Steven]

reducer = lambda do |array, m|
  m.phrase do |phrase|
    array.select { |item| item.upcase.include?(phrase.upcase) }
  end

  m.not_phrase do |phrase|
    array.reject { |item| item.upcase.include?(phrase.upcase) }
  end

  m.default { arr }
end

query_reducer = Querylicious::QueryReducer.new(reducer)

query_reducer.call(repository, 'am')         #=> ["Amethyst"]
query_reducer.call(repository, 'NOT Steven') #=> ["Garnet", "Amethyst", "Pearl"]
```

`phrase` is the basic search type intended for free text search or similar. But querylicious also supports defining property search with many possible modifiers.

```rb
# The query "stars:n" searches for when `stars` is the value n
m.key 'stars' do |array, stars|
  # ...
end

# You can use `dry-types` type-definitions if you wish to handle different types differently.
# The parser can return the following types:
# `[String, Integer, Date, DateTime, Range]`

# The query "stars:1" searches for when `stars` is an integer `1`
m.key 'stars', type: Querylicious::Types::Integer do |array, stars|
  # ...
end

# The query "stars:1..10" searches for when `stars` is a range `1..10`
m.key 'stars', type: Querylicious::Types::Range do |array, stars|
  # ...
end

# Properties also support operators different from the default equals;
# possilble operators are: `%i[eql not_eql gt gteq lt lteq]`

# The query "stars:>1" searches for when `stars` is greater than `1`
m.key 'stars', op: :gt do |array, stars|
  # ...
end
```

You can use any type of backing repository, as long as it's reducable. Here is an example using Sequel:

```rb
class Article < Sequel::Model; end

reducer = lambda do |dataset, m|
  m.phrase do |phrase|
    dataset.grep(%i[name body], "%#{phrase}%", case_insensitive: true)
  end

  m.key :published do |published|
    dataset.where(published: published)
  end

  m.default { dataset }
end

query_reducer = Querylicious::QueryReducer.new(reducer)

articles = query_reducer.call(Article, 'foo published:true').all
```

You can curry the call to the query reducer to avoid passing the repository each time:

```rb

article_search = query_reducer.curry.call(Article)

articles = article_search.call('foo published:true').all
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in the `VERSION` file, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/huyderman/querylicious. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Querylicious project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/huyderman/querylicious/blob/master/CODE_OF_CONDUCT.md).

## Credits

Thanks to the talented Alex Daily ([@Daily@tootplanet.space](https://tootplanet.space/@Daily) or [@heyalexdaily@twitter.com](https://twitter.com/heyalexdaily)) for creating the awesome logo!
