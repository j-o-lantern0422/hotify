require "onelogin"
require "thor"
require "parallel"
require "hotify/version"
require "hotify/cli"
require "hotify/auth"
require "hotify/user"

if ENV["ENV"] == "development"
  require "dotenv"
  require "byebug"
  require "pry"
  Dotenv.load(".development.env")
end

module Hotify
  class Error < StandardError; end
  class Role
    def dump_role
      client.get_roles.to_a.each{ |role| p role }
    end

    def all_roles
      @_all_roles ||= client.get_roles.to_a
    end

    def roles_from(user: )
      role_ids = client.get_user_roles(user.id)
      role_ids.map do | role_id |
        client.get_role(role_id)
      end
    end

    def role_ids_from(user: )
      client.get_user_roles(user.id)
    end

    def users
      @_users ||= Hotify::Users.new
    end

    def all_users
      @_all_users ||= users.all_users
    end

    def all_users_and_roles
      @_all_users_and_roles ||= all_users.map do | user |
        { user: user, role_ids: role_ids_from(user: user) }
      end
    end

    def role_in_user
      role_user = Hash.new { |h,k| h[k] = [] }

      all_roles.each do | role |
        all_users_and_roles.each do | user_and_role_ids |
          user_and_role_ids[:role_ids].each do | role_id |
            if role.id == role_id
              role_user[role.name].push(user_and_role_ids[:user])
            end
          end
        end
      end

      role_user.each do | role_name , users |
        users.uniq!
      end

      role_user
    end

    def add_role(user_email, role_ids)
      user = Hotify::Users.find_by(email: user_email)
      client.assign_role_to_user(user.id, role_ids)
    end

    def leave_role(user_email, role_ids)
      user = Hotify::Users.find_by(email: user_email)
      client.remove_role_from_user(user.id, role_ids)
    end

    def find_by_name(name)
      name = "?name=#{name}"
      client.get_role(name)
    end

    def find_by(id)
      client.get_role(id)
    end

    private

    def client
      @_client ||= Hotify::Auth.new.client
    end
  end
end
