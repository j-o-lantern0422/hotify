require "onelogin"
require "thor"
require "hotify/version"
require "hotify/cli"
require "hotify/auth"
require "hotify/user"

if ENV["ENV"] == "development"
  require "dotenv"
  require "byebug"
  require "pry"
  Dotenv.load
end

module Hotify
  class Error < StandardError; end
  class Role
    def initialize
      @client = Hotify::Auth.new.client
    end

    def all_role
      @client.get_roles.to_a
    end

    def dump_role
      all_role.each{ |role| p role }
    end

    def roles_from(user: )
      role_ids = @client.get_user_roles(user.id)
      role_ids.map do | role_id |
        @client.get_role(role_id)
      end
    end

    def dump_all_users_and_roles
      users = Hotify::Users.new
      all_users_and_roles = users.all_users.map do | user |
        { user: user, roles: roles_from(user: user) }
      end

      all_users_and_roles
    end

    def role_in_user
      all_users_and_roles = dump_all_users_and_roles
      all_roles = all_role
      role_user = Hash.new { |h,k| h[k] = [] }


      all_role.each do | role |
        all_users_and_roles.each do | user_and_roles |
          user_and_roles[:roles].each do | role |
            role_user[role.name].push(user_and_roles[:user])
          end
        end
      end

      role_user.each do | role_name , users |
        users.uniq!
      end

      role_user
    end
  end
end
