require 'spec_helper'
require 'rack/test'

describe Omniauth::Riskalyze do
  it 'has a version string in semver format' do
    expect(Omniauth::Riskalyze::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

describe OmniAuth::Strategies::Riskalyze do
  it 'sets the correct authorize URL' do
    expect(described_class.default_options[:client_options][:authorize_url])
      .to eq('https://pro.riskalyze.com/oauthconnect')
  end

  it 'sets the correct token URL' do
    expect(described_class.default_options[:client_options][:token_url])
      .to eq('https://api2.riskalyze.com/ap/v1/oauthpro/token')
  end

  it 'defines the default scope constant' do
    expect(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE).to eq('com.riskalyze.client.read')
  end

  describe '#credentials' do
    let(:app) { ->(_env) { [200, {}, ['OK']] } }
    let(:strategy_options) { {} }
    let(:strategy) do
      described_class.new(app, 'test_id', 'test_secret', strategy_options).tap do |instance|
        instance.access_token = OAuth2::AccessToken.from_hash(instance.client, token_response)
      end
    end
    let(:token_response) { { 'access_token' => 'token' } }

    it 'uses the scope granted in the token response' do
      strategy_options[:scope] = 'requested.read requested.write'
      token_response['scope'] = 'granted.read'

      expect(strategy.credentials['scope']).to eq('granted.read')
    end

    it 'falls back to the configured requested scope when the token response omits scope' do
      strategy_options[:scope] = 'requested.read requested.write'

      expect(strategy.credentials['scope']).to eq('requested.read requested.write')
    end

    it 'falls back to the default requested scope when none is configured' do
      expect(strategy.credentials['scope']).to eq(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE)
    end
  end

  describe '#authorize_params' do
    include Rack::Test::Methods

    # Rack 3-compatible fake session (avoids rack-session gem dependency)
    let(:session_middleware) do
      Class.new do
        def initialize(app) = @app = app

        def call(env)
          env['rack.session'] ||= {}
          @app.call(env)
        end
      end
    end

    let(:app) do
      sm = session_middleware
      Rack::Builder.new do
        use sm
        use OmniAuth::Builder do
          provider OmniAuth::Strategies::Riskalyze, 'test_id', 'test_secret'
        end
        run ->(_env) { [200, {}, ['OK']] }
      end
    end

    let(:original_validation_phase) { OmniAuth.config.request_validation_phase }

    before { OmniAuth.config.request_validation_phase = nil }
    after  { OmniAuth.config.request_validation_phase = original_validation_phase }

    it 'includes the default scope in the authorize redirect' do
      post '/auth/riskalyze'
      expect(last_response.headers['Location']).to include("scopes=#{CGI.escape(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE)}")
    end

    it 'omits request query parameters from the redirect_uri' do
      post '/auth/riskalyze?source=example'
      params = URI.decode_www_form(URI(last_response.headers['Location']).query).to_h
      expect(params['redirect_uri']).to eq('http://example.org/auth/riskalyze/callback')
    end
  end
end
