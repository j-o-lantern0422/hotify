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

    def onelogin_role_in_user
      @_onelogin_role_in_user ||= role_in_user_dump(hotify_role.role_in_user)
    end

    def add_role_by_yaml(hotify_role_users_hash)
      users_and_roles_will_add = Hash.new { |h,k| h[k] = [] }
      hotify_role_users_hash.each do | hotify_role_name, hotify_user_emails |
        hotify_user_emails.each do | hotify_user_email |
          unless onelogin_role_in_user[hotify_role_name].include?(hotify_user_email)
            users_and_roles_will_add[hotify_user_email].push(hotify_role_name)
          end
        end
      end

      add!(users_and_roles_will_add)
    end

    def remove_role_by_yaml(hotify_role_users_hash)
      users_and_roles_will_remove = Hash.new { |h,k| h[k] = [] }
      hotify_role_users_hash.each do | hotify_role_name, hotify_user_emails |
        onelogin_role_in_user[hotify_role_name].each do | onelogin_user_email |
          unless hotify_user_emails.include?(onelogin_user_email)
            users_and_roles_will_remove[onelogin_user_email].push(hotify_role_name)
          end
        end
      end

      remove!(users_and_roles_will_remove)
    end

    def add!(users_and_roles_will_add)
      users_and_roles_will_add.each do |user_email, role_names|
        if options[:dry_run]
          puts "#{user_email} will add to:"
          role_names.each { | role_name | puts role_name }
        else
          role_ids = role_names.map{ |role_name| role_id_by(role_name) }
          hotify_role.add_role(user_email, role_ids)
          puts "#{user_email} added to #{role_name}"
        end
      end
    end

    def remove!(users_and_roles_will_remove)
      users_and_roles_will_remove.each do |user_email, role_names|
        if options[:dry_run]
          puts "#{user_email} will remove by:"
          role_names.each { | role_name | puts role_name }
        else
          role_ids = role_names.map{ |role_name| role_id_by(role_name) }
          hotify_role.leave_role(user_email, role_ids)
          puts "#{user_email} removed by #{role_name}"
        end
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
