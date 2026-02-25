require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Riskalyze < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'com.riskalyze.client.read'.freeze

      option :client_options, site:          'https://api2.riskalyze.com/',
                              authorize_url: 'https://pro.riskalyze.com/oauthconnect',
                              token_url:     'https://api2.riskalyze.com/ap/v1/oauthpro/token'

      def authorize_params
        super.tap do |params|
          params[:client_id] = options.client_id
          params[:response_type] = 'code'
          params[:scopes] = options.scope || DEFAULT_SCOPE
        end
      end
    end
  end
end
