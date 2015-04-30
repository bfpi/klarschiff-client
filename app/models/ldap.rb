class Ldap
  class << self
    def config
      @@config ||= File.open(Rails.root.join('config', 'settings.yml')) { |file|
        YAML::load file }['ldap'].with_indifferent_access
    end

    def login(username, pwd)
      ldap = Net::LDAP.new(config.slice(:host, :port, :encryption))
      ldap.auth "cn=#{ username },#{ config[:base][:users] }", pwd
      if ldap.bind && (
          obj = ldap.search(base: config[:base][:users], filter: "cn=#{ username }").try(:first))
        return user(ldap, obj)
      end
    end

    def login2(name)
      ldap = Net::LDAP.new(config.slice(:host, :port, :encryption))
      ldap.auth *config.slice(:username, :password).values
      if ldap.bind && (
          obj = ldap.search(base: config[:base][:users], filter: "displayname=#{ name }").try(:first))
        return user(ldap, obj)
      end
    end

    def user(ldap, obj)
      User.new name: obj.displayname.first, email: obj.mail.first,
        field_service_team: ldap.search(base: config[:base][:groups],
                                        filter: config[:group_search_pattern] % obj.dn
                                       ).try(:first).try(:cn).try(:first).presence
    end
  end
end
