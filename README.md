# hotify

Onelogin role management with yaml tool.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hotify'
```

or install 

```sh
gem install hotify
```

## Usage

### Dump role and users

```sh
hotify dump
```

or

```sh
hotify dump ~/role_and_users.yml
```

### Apply role and users

```sh
hotify apply role_and_users.yml
```

If you want to execute dry-run

```sh
hotify apply role_and_users.yml --dry-run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/j-o-lantern0422/hotify


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
