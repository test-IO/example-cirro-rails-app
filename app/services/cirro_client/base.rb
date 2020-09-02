module CirroClient
  # this is an "abstract" base class that
  class Base < JsonApiClient::Resource
    # set the api base url in an abstract base class
    self.site = "#{Settings.cirro.site}/#{Settings.cirro.api_version}"
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
