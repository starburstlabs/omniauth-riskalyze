# OmniAuth 2.0 Upgrade Guide

Context: OmniAuth 2.0 introduced CSRF protection (POST-only request phase) and deprecated
mutating `options[:authorize_params]` in `request_phase`. This doc covers what changed and
how to test strategies against the new version.

## Key Strategy Change

OmniAuth 2.0 / omniauth-oauth2 1.8+ handles `client_id`, `response_type`, and `state`
automatically. The old pattern of overriding `request_phase` and mutating the shared
options hash is thread-unsafe and no longer needed.

**Before (OmniAuth 1.x):**
```ruby
def request_phase
  options[:authorize_params] = {
    client_id:     options['client_id'],
    response_type: 'code',
    scopes:        (options['scope'] || DEFAULT_SCOPE)
  }
  super
end
```

**After (OmniAuth 2.x):**
```ruby
def authorize_params
  super.tap do |params|
    params[:scopes] = options.scope || DEFAULT_SCOPE
  end
end
```

Only set params that are custom to your provider. `super` provides `client_id`,
`response_type`, `redirect_uri`, and `state` automatically.

## Testing Strategies with Rack

OmniAuth 2.0 requires a session in the Rack environment. Use a minimal inline middleware
rather than pulling in a full session gem:

```ruby
# In spec_helper or the spec itself
let(:session_middleware) do
  Class.new do
    def initialize(app) = @app = app

    def call(env)
      env['rack.session'] ||= {}
      @app.call(env)
    end
  end
end

let(:original_validation_phase) { OmniAuth.config.request_validation_phase }

before { OmniAuth.config.request_validation_phase = nil }
after  { OmniAuth.config.request_validation_phase = original_validation_phase }

let(:app) do
  sm = session_middleware
  Rack::Builder.new do
    use sm
    use OmniAuth::Builder do
      provider YourStrategy, 'client_id', 'client_secret'
    end
    run ->(_env) { [200, {}, ['OK']] }
  end
end
```

Then test via `post '/auth/your_strategy'` and assert on `last_response.headers['Location']`.

**Important:** Disable `request_validation_phase` in tests (OmniAuth 2.0's CSRF guard),
and always capture + restore the original value rather than hardcoding the constant.

## Dependency Versions

| Gem | Version |
|-----|---------|
| omniauth | `~> 2.0` |
| omniauth-oauth2 | `~> 1.8` |
| bundler | `~> 2.0` |

## Environment Notes

- Requires Ruby 2.7+ (omniauth-oauth2 1.8+, rubocop 1.50+)
- Set `.ruby-version` to pin the local Ruby version (e.g., `3.2.4`)
- If the system gem cache is root-owned, use `BUNDLE_USER_HOME=/tmp/... bundle install`
