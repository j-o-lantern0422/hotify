module Hotify
  class Cli < Thor
    desc "dump", "onelogin-role"
    def dump
      Hotify::Role.new.dump_role
    end

    desc "dump [Path]", "yaml output"
    method_options path: :string
    def dump(path) 
      if path.nil?
        path = "#{Dir.pwd}/roles_users.yml"
      end
      role = Hotify::Role.new

      YAML.dump(role_in_user_dump(role.role_in_user), File.open(path, "w"))
    end


    desc "apply [Path]", "apply user and role"
    method_options path: :string
    def apply(path)
      add_role_by_yaml(path)
      remove_role_by_yaml(path)
    end


    private

    def add_role_by_yaml(file_path)
      role_file = YAML.load_file(file_path)
      hotify_role = Hotify::Role.new
      role_file.each do | role_name, user_emails |
        user_emails.each do | user_email |
          user = Hotify::Users.find_by(email: user_email)
          user_role_names = hotify_role.roles_from(user: user).map{|user_role| user_role.name}
          unless user_role_names.include?(role_name)
            add!(user, role_name)
          end
        end
      end
    end

    def remove_role_by_yaml(file_path)
      role_file = YAML.load_file(file_path)
      hotify_role = Hotify::Role.new
      onelogin_roles = hotify_role.role_in_user
      onelogin_roles.each do | role_name, users |
        users.each do | user |
          unless role_file[role_name].include?(user.email)
            remove!(user, role_name)
          end
        end
      end
    end

    def add!(user, role_name)
      hotify_role = Hotify::Role.new
      hotify_role.add_role(user, hotify_role.find_by_name(role_name))
      puts "#{user.email} added to #{role_name}"
    end

    def remove!(user, role_name)
      hotify_role = Hotify::Role.new
      hotify_role.leave_role(user, hotify_role.find_by_name(role_name))
      puts "#{user.email} removed by #{role_name}"
    end

    def role_in_user_dump(role_in_user)
      dump = Hash.new { |h,k| h[k] = [] }
      role_in_user.each do | role_name, users |
        users.each do | user |
          dump[role_name].push(user.email)
        end
      end

      dump
    end
  end
end
