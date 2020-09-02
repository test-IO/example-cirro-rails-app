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
        {
          email: raw_info.dig('data', 'attributes', 'worker-document', 'email')
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get("/v1/app-workers/me.json").body)
      end
    end
  end
end
