# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Omniauth::Riskalyze do
  it 'has a version number' do
    expect(Omniauth::Riskalyze::VERSION).not_to be nil
  end

  it 'has a version string in semver format' do
    expect(Omniauth::Riskalyze::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

describe OmniAuth::Strategies::Riskalyze do
  it 'inherits from OmniAuth::Strategies::OAuth2' do
    expect(described_class.ancestors).to include(OmniAuth::Strategies::OAuth2)
  end

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

  describe '#authorize_params' do
    include Rack::Test::Methods

    # Minimal session middleware for test environments (Rack 3 compatible)
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

    before do
      # Disable CSRF protection in test; host app is responsible for this in production
      OmniAuth.config.request_validation_phase = nil
    end

    after do
      OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection
    end

    it 'redirects with the default scope when none is configured' do
      post '/auth/riskalyze'
      expect(last_response.headers['Location']).to include("scopes=#{CGI.escape(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE)}")
    end

    it 'redirects to the correct Riskalyze authorize URL' do
      post '/auth/riskalyze'
      expect(last_response.headers['Location']).to start_with('https://pro.riskalyze.com/oauthconnect')
    end
  end
end
