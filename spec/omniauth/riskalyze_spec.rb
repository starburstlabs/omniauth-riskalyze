# frozen_string_literal: true

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

    before { OmniAuth.config.request_validation_phase = nil }
    after  { OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection }

    it 'includes the default scope in the authorize redirect' do
      post '/auth/riskalyze'
      expect(last_response.headers['Location']).to include("scopes=#{CGI.escape(OmniAuth::Strategies::Riskalyze::DEFAULT_SCOPE)}")
    end
  end
end
