module Artichoke
  class Connection
    include ActiveSupport::Configurable

    config_accessor :username, :password

    def self.client_username
      config.username || raise("Please configure a username")
    end

    def self.client_password
      config.password || raise("Please configure a password")
    end
  end
end