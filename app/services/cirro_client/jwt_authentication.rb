require 'jwt'
require 'openssl'

module CirroClient
  class JwtAuthentication < Faraday::Middleware
    def call(env)
      private_pem = File.read('./key.pem')
      private_key = OpenSSL::PKey::RSA.new(private_pem)

      payload = {
        # JWT expiration time (10 minute maximum)
        exp: Time.now.to_i + (10 * 60),
        # App client id
        iss: 'WULnc6Y0rlaTBCSiHAb0kGWKFuIxPWBXJysyZeG3Rtw'
      }

      token = JWT.encode(payload, private_key, 'RS256')

      env[:request_headers]["Authorization"] = "Bearer #{token}"
      @app.call(env)
    end
  end
end
