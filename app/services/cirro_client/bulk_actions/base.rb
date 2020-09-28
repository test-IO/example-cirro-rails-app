require 'jwt'
require 'openssl'

module CirroClient
  module BulkActions
    class Base
      SITE = "#{Settings.cirro.site}/#{Settings.cirro.api_version}/bulk"
      KEY_PATH = Rails.env.development? ? './key.pem' : './storage/cirro.pem'
      PRIVATE_PEM = File.read(KEY_PATH)

      def self.headers
        private_key = OpenSSL::PKey::RSA.new(PRIVATE_PEM)

        payload = {
          # JWT expiration time (10 minute maximum)
          exp: Time.now.to_i + (10 * 60),
          # App client id
          iss: Settings.cirro.app_id
        }

        token = JWT.encode(payload, private_key, 'RS256')
        { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
      end
    end
  end
end
