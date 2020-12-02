require 'cirro_io/client'

private_key = Rails.env.production? ? './storage/cirro.pem' : './key.pem'

CirroIO::Client.configure do |c|
  c.app_id Settings.cirro.app_id
  c.private_key_path private_key
  c.site Settings.cirro.site
end
