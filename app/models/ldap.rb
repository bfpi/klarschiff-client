class Ldap
  class << self
    def config
      @@config ||= Settings::Ldap
    end

    def login(username, pwd)
      ldap = conn
      ldap.auth "cn=#{ username },#{ config.users[:base] }", pwd
      if ldap.bind && (
          obj = ldap.search(base: config.users[:base], filter: "cn=#{ username }").try(:first))
        return user(ldap, obj)
      end
    end

    def login2(name)
      ldap = conn
      if config.username.present? && config.password.present?
        ldap.auth config.username, config.password
      end
      if ldap.bind && (
          obj = ldap.search(base: config.users[:base], filter: "#{ mapping(:name) }=#{ name }").try(:first))
        return user(ldap, obj)
      end
    end

    def user(ldap, obj)
      User.new name: obj.send(mapping(:name)).try(:first), email: obj.send(mapping(:email)).try(:first),
        field_service_team: ldap.search(base: config.groups[:base],
                                        filter: config.groups[:search_pattern] % obj.dn
                                       ).try(:first).try(:cn).try(:first).presence
    end

    private
    def conn
      Net::LDAP.new host: config.host, port: config.port, encryption: config.encryption
    end

    def mapping(name)
      (@@mapping ||= {}.with_indifferent_access.tap do |m|
        config.users[:attributes_mapping].split(',').map { |v| v.split '=' }.each do |n, attr|
          m[n] = attr.to_sym
        end
      end)[name]
    end
  end
end
