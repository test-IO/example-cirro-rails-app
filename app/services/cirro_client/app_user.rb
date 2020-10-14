module CirroClient
  class AppUser < Base
    has_one :app_worker, class_name: 'CirroClient::AppWorker'

    def self.resource_name
      'app-users'
    end
  end
end
