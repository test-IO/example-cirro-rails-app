module CirroClient
  class Gig < Base
    has_one :worker_invitation_filter
    has_many :gig_tasks

    def self.resource_name
      'gigs'
    end
  end
end
