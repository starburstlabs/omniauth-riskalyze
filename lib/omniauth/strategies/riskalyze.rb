require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Riskalyze < OmniAuth::Strategies::OAuth2
      # NOTE: Riskalyze uses `scopes` (plural), not the standard OAuth2 `scope` param.
      DEFAULT_SCOPE = 'com.riskalyze.client.read'.freeze

      option :client_options, site: 'https://api2.riskalyze.com/',
                              authorize_url: 'https://pro.riskalyze.com/oauthconnect',
                              token_url: 'https://api2.riskalyze.com/ap/v1/oauthpro/token'

      def authorize_params
        super.tap do |params|
          # NOTE: Riskalyze uses `scopes` (plural) - omniauth-oauth2 handles
          # client_id and response_type automatically.
          params[:scopes] = options.scope || DEFAULT_SCOPE
        end
      end
    end
  end
end
