module OmniAuth
  module Strategies
    class Cirro < OmniAuth::Strategies::OAuth2
      option :name, :cirro

      option :client_options,
             site: Settings.cirro.site,
             authorize_url: Settings.cirro.authorize_url

      uid do
        raw_info.dig('data', 'id')
      end

      info do
        email = raw_info.dig('data', 'attributes', 'email')
        {
          first_name: raw_info.dig('data', 'attributes', 'first-name'),
          last_name: raw_info.dig('data', 'attributes', 'last-name'),
          time_zone: raw_info.dig('data', 'attributes', 'time-zone'),
          email: email,
          screenname: raw_info.dig('data', 'attributes', 'screenname') || email.split('@').first
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get("/v1/app-users/me.json?include=app-worker").body)
      end
    end
  end
end
