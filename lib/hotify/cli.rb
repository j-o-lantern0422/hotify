module Hotify
  class Cli < Thor
    class_option :dry_run, :type => :boolean, :default => false

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
      role_file = YAML.load_file(path)
      add_role_by_yaml(role_file)
      remove_role_by_yaml(role_file)
    end

    private

    def hotify_role
      @_hotify_role ||= Hotify::Role.new
    end

    def role_id_names
      @_role_id_names ||= hotify_role.all_roles.map{ | role | { id: role.id, name: role.name} }
    end

    def role_id_by(name)
      role_id_names.each do | role_id_name |
        return role_id_name[:id] if role_id_name[:name] == name
      end

      nil
    end

    def add_role_by_yaml(hotify_role_users_hash)
      hotify_role = Hotify::Role.new
      hotify_role_users_hash.each do | role_name, user_emails |
        role_id = role_id_by(role_name)
        user_emails.each do | user_email |
          user = Hotify::Users.find_by(email: user_email)
          onelogin_user_role_ids = hotify_role.role_ids_from(user: user)
          unless onelogin_user_role_ids.include?(role_id)
            add!(user, role_name)
          end
        end
      end
    end

    def remove_role_by_yaml(hotify_role_users_hash)
      hotify_role = Hotify::Role.new
      onelogin_roles = hotify_role.role_in_user
      onelogin_roles.each do | onelogin_role_name, onelogin_users |
        onelogin_users.each do | user |
          unless hotify_role_users_hash[onelogin_role_name].include?(user.email)
            remove!(user, onelogin_role_name)
          end
        end
      end
    end

    def add!(user, role_name)
      hotify_role = Hotify::Role.new
      if options[:dry_run]
        puts "#{user.email} will add to #{role_name}"
      else
        hotify_role.add_role(user, hotify_role.find_by_name(role_name))
        puts "#{user.email} added to #{role_name}"
      end
    end

    def remove!(user, role_name)
      hotify_role = Hotify::Role.new
      if options[:dry_run]
        puts "#{user.email} will remove by #{role_name}"
      else
        hotify_role.leave_role(user, hotify_role.find_by_name(role_name))
        puts "#{user.email} removed by #{role_name}"
      end
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
