module CirroClient
  class AppWorker < Base
    has_many :gig_invitations, class_name: 'CirroClient::GigInvitation'

    def self.resource_name
      'app-workers'
    end
  end
end
