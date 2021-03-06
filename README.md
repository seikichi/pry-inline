# Pry Inline

[![Gem Version](https://badge.fury.io/rb/pry-inline.svg)](http://badge.fury.io/rb/pry-inline)
[![Build Status](https://travis-ci.org/seikichi/pry-inline.svg?branch=master)](https://travis-ci.org/seikichi/pry-inline)
[![Coverage Status](https://coveralls.io/repos/seikichi/pry-inline/badge.svg?branch=master&service=github)](https://coveralls.io/github/seikichi/pry-inline?branch=master)

Pry Inline is a plugin for [pry](https://github.com/pry/pry/),
which enables the inline variables view like [RubyMine](https://www.jetbrains.com/ruby/help/inline-debugging.html).

![screenshot](./screenshot.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pry-inline'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pry-inline

## Usage

There is no need to edit any configuration.
After you have added the dependency in Gemfile,
pry-inline will enable the inline variables view functionality.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/seikichi/pry-inline.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
