module CirroClient
  class GigInvitation < Base
    def self.resource_name
      'gig-invitations'
    end

    def self.table_name
      'gig-invitation'
    end
  end
end
