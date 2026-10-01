require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Riskalyze < OmniAuth::Strategies::OAuth2
      # NOTE: Riskalyze uses `scopes` (plural), not the standard OAuth2 `scope` param.
      DEFAULT_SCOPE = 'com.riskalyze.client.read'.freeze

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
          # NOTE: Riskalyze uses `scopes` (plural) - omniauth-oauth2 handles
          # client_id and response_type automatically.
          params[:scopes] = options.scope || DEFAULT_SCOPE
        end
      end

      # OmniAuth includes callback query parameters in its default redirect_uri.
      def callback_url
        full_host + callback_path
      end
    end
  end
end
