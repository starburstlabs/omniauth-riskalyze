require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Riskalyze < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'com.riskalyze.client.read'.freeze

      option :scope, DEFAULT_SCOPE

      option :client_options, site: 'https://api2.riskalyze.com/',
                              authorize_url: 'https://pro.riskalyze.com/oauthconnect',
                              token_url: 'https://api2.riskalyze.com/ap/v1/oauthpro/token'

      credentials do
        # OmniAuth merges these with inherited token credentials; include only returned values.
        # Riskalyze may return granted scope under its nonstandard plural key.
        {
          'scope' => access_token['scope'] || access_token['scopes'],
          'token_type' => access_token['token_type']
        }.compact
      end

      def authorize_params
        super.tap do |params|
          # Nitrogen's MCP OAuth docs specify the standard `scope` request parameter:
          # https://developers.riskalyze.com/#ac011e12-9852-47f3-b00a-a126d75df5f2
          # Mirror it to the legacy `scopes` parameter for compatibility.
          params[:scopes] = params[:scope]
        end
      end

      # OmniAuth includes callback query parameters in its default redirect_uri.
      def callback_url
        full_host + callback_path
      end
    end
  end
end
