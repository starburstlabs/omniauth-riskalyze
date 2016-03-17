# omniauth-riskalyze

Riskalyze OAuth2 Strategy for OmniAuth 1.x and supports the OAuth 2.0 server-side flow.

You may view the Riskalyze API documentation [here](https://developers.riskalyze.com/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-riskalyze'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-riskalyze

## Usage

`OmniAuth::Strategies::Riskalyze` is simply Rack middleware. Read the OmniAuth 1.0 docs for detailed instructions: https://github.com/intridea/omniauth.

Here's a quick example, adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :riskalyze, ENV['RISKALYZE_CLIENT_ID'], ENV['RISKALYZE_CLIENT_SECRET']
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
