module Onelogin
  module Role
    class Cli < Thor
      desc "dump", "onelogin-role"
      def dump
        Onelogin::Role::Role.new.dump_role
      end

      desc "yaml", "yaml output"
      def pry
        role = Onelogin::Role::Role.new
        role.role_in_user.each do | role_name, users |
          puts "#{role_name}:"
          users.each do | user |
            puts " - #{user.username}"
          end
        end
      end
    end
  end
end
