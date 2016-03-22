require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Riskalyze < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'com.riskalyze.client.read'.freeze

      option :client_options, site:          'https://api2.riskalyze.com/',
                              authorize_url: 'https://pro.riskalyze.com/oauthconnect',
                              token_url:     'https://api2.riskalyze.com/ap/v1/oauthpro/token'

      def request_phase
        options[:authorize_params] = {
          client_id:     options['client_id'],
          response_type: 'code',
          scopes:        (options['scope'] || DEFAULT_SCOPE)
        }

        super
      end
    end
  end
end
