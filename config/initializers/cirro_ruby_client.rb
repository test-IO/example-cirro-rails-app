require 'cirro_io/client'
require 'cirro_io_v2/client'

private_key = Rails.env.production? ? './storage/cirro.pem' : './key.pem'

CirroIO::Client.configure do |c|
  c.app_id Settings.cirro.app_id
  c.private_key_path private_key
  c.site Settings.cirro.site
end

CIRRO_V2_CLIENT = CirroIOV2::Client.new(private_key_path: private_key,
                                        client_id: Settings.cirro.app_id,
                                        site: Settings.cirro.site)
