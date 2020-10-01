module CirroClient
  class GigTimeActivity < Base
    has_one :gig
    has_one :app_worker

    def self.resource_name
      'gig-time-activities'
    end
  end
end
