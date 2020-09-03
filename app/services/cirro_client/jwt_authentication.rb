require 'jwt'
require 'openssl'

module CirroClient
  class JwtAuthentication < Faraday::Middleware
    def call(env)
      path = Rails.env.development? ? './key.pem' : './storage/cirro.pem'
      private_pem = File.read(path)
      private_key = OpenSSL::PKey::RSA.new(private_pem)

      payload = {
        # JWT expiration time (10 minute maximum)
        exp: Time.now.to_i + (10 * 60),
        # App client id
        iss: Settings.cirro.app_id
      }

      token = JWT.encode(payload, private_key, 'RS256')

      env[:request_headers]["Authorization"] = "Bearer #{token}"
      @app.call(env)
    end
  end
end
