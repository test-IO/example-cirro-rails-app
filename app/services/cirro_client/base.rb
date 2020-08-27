module CirroClient
  # this is an "abstract" base class that
  class Base < JsonApiClient::Resource
    # set the api base url in an abstract base class
    self.site = "http://api.app.localhost:3000/v1/"
  end

  class AppWorker < Base
  end
end

CirroClient::Base.connection do |connection|
  # set OAuth2 headers
  # connection.use FaradayMiddleware::OAuth2, 'MYTOKEN'
  connection.use CirroClient::JwtAuthentication

  # log responses
  connection.use Faraday::Response::Logger

  # connection.use MyCustomMiddleware
end
