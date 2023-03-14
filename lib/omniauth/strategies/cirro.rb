module OmniAuth
  module Strategies
    class Cirro < OmniAuth::Strategies::OAuth2
      option :name, :cirro

      option :client_options,
             site: Settings.cirro.site,
             authorize_url: Settings.cirro.authorize_url

      uid do
        raw_info['id']
      end

      info do
        {
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          time_zone: raw_info['time_zone'],
          screenname: raw_info['screen_name'] || raw_info['first_name'],
          country_code: raw_info['country_code'],
          worker: raw_info['worker'],
          epam: raw_info['epam']
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get("/v2/users/me").body)
      end
    end
  end
end
