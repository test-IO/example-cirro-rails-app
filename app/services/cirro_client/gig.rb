module CirroClient
  class Gig < Base
    has_one :worker_invitation_filter

    def self.resource_name
      'gigs'
    end
  end
end
