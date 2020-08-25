module OmniAuth
  module Strategies
    class Cirro < OmniAuth::Strategies::OAuth2
      option :name, :cirro

      option :client_options,
             site: ENV["CIRRO_APP_URL"],
             authorize_url: "http://localhost:3000/oauth/authorize"

      uid do
        raw_info['data']['id']
      end

      info do
        {
          email: raw_info['data']['attributes']['worker-document']['email']
        }
      end

      def raw_info
        @raw_info ||= JSON.parse(access_token.get("/v1/app-workers/1.json").body)
      end
    end
  end
end
