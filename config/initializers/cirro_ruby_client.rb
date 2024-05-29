require 'cirro_io/client'
require 'cirro_io_v2/client'

args = {
  client_id: Settings.cirro.app_id,
  site: Settings.cirro.site
}

if Rails.env.production?
  args[:private_key] = ENV.fetch("cirro_private_key")
else
  args[:private_key_path] = './key.pem'
end

CIRRO_V2_CLIENT = CirroIOV2::Client.new(**args)