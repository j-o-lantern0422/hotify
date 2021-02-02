module Hotify
  class Users
    def self.find_by(email:)
      users = user_filter_by(email: email)
      if users.size > 1
        raise("#{email}: Found Multiple User Entry")
      elsif users.empty?
        raise("#{email}: User Not Found")
      end

      users.first
    end

    def all_users
      @_all_users ||= client.get_users

      @_all_users
    end

    private

    def self.user_filter_by(email:)
      query_parameters = {
        email: email
      }
      users_filtered = Hotify::Auth.new.client.get_users(query_parameters)
      users = users_filtered.map{ |user| user }

      users
    end

    def client
      @_client ||= Hotify::Auth.new.client
    end
  end
end
