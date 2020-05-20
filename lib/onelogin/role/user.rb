module Onelogin
  module Role
    class Users
      def initialize
        @client = Onelogin::Role::Auth.new.client
      end

      def self.find_by(email:)
        users = user_filter_by(email: email) 
        if users.size > 1
          raise("Found Multiple User Entry")
        elsif users.empty?
          raise("User Not Found")
        end

        users.first
      end

      def all_users
        if ENV["ENV"] == "development"
          return  [Onelogin::Role::Users.find_by(email: "test@pepabo.com"),Onelogin::Role::Users.find_by(email: "test@pepabo.com") ]
        end

        @client.get_users
      end

      private

      def self.user_filter_by(email:)
        query_parameters = {
          email: email
        }
        users_filtered = Onelogin::Role::Auth.new.client.get_users(query_parameters)
        users = users_filtered.map{ |user| user }
    
        users
      end
    end
  end
end