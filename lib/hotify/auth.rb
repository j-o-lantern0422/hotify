module Hotify
  class Auth
    def initialize
      @client = OneLogin::Api::Client.new(
        client_id: ENV["ONELOGIN_ID"],
        client_secret: ENV["ONELOGIN_SECRET"],
        region: 'us'
      )
    end

    def client
      @client
    end
  end
end
